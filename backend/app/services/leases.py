"""Leases (FR-09). No HTTP dependencies (NFR-12).

A lease is the snapshot of an agreement: the date range and `monthly_rent` are
copied at signing and never edited. Changing the rent means terminating the
lease and signing a new one, which keeps every past ledger row correct
(snapshot pattern).

`Unit.status` is owned by this feature -- `services/units.py` treats it as
read-only. It is *derived* here from the presence of an open lease and written
in the same transaction as the lease change (NFR-05), then announced as
`UnitOccupancyChanged`.
"""

from dataclasses import dataclass
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.access import authorize
from app.core.errors import ConflictError, NotFoundError
from app.core.events import bus
from app.core.policy import Action
from app.events import LeaseCreated, LeaseTerminated, UnitOccupancyChanged
from app.models.lease import Lease
from app.models.tenant import Tenant
from app.models.unit import Unit, UnitStatus


class LeaseNotFound(NotFoundError):
    code = "lease_not_found"
    message = "Lease not found"


class UnitNotFound(NotFoundError):
    code = "unit_not_found"
    message = "Unit not found"


class TenantNotFound(NotFoundError):
    code = "tenant_not_found"
    message = "Tenant not found"


class UnitAlreadyLeased(ConflictError):
    code = "unit_already_leased"
    message = "This unit already has an open lease. Terminate it before signing a new one."


class LeaseAlreadyTerminated(ConflictError):
    code = "lease_already_terminated"
    message = "This lease has already been terminated"


@dataclass(frozen=True)
class LeaseView:
    lease: Lease
    unit_label: str
    tenant_name: str


def _lease(db: Session, property_id: int, lease_id: int) -> Lease:
    lease = db.scalar(select(Lease).where(Lease.id == lease_id, Lease.property_id == property_id))
    if lease is None:
        raise LeaseNotFound
    return lease


def _view(db: Session, lease_id: int) -> LeaseView:
    row = db.execute(
        select(Lease, Unit.label, Tenant.full_name)
        .join(Unit, Unit.id == Lease.unit_id)
        .join(Tenant, Tenant.id == Lease.tenant_id)
        .where(Lease.id == lease_id)
    ).first()
    return LeaseView(*row)


def _has_open_lease(db: Session, unit_id: int) -> bool:
    return (
        db.scalar(select(Lease.id).where(Lease.unit_id == unit_id, Lease.is_active.is_(True)))
        is not None
    )


def _sync_occupancy(db: Session, unit: Unit) -> None:
    """Occupancy is derived, never set by hand: a unit is occupied while it holds
    at least one open lease.

    Callers must `flush()` first -- the session runs with `autoflush=False`, so a
    pending lease would otherwise be invisible to the lookup below and the unit
    would be left wrongly vacant.
    """
    unit.status = UnitStatus.OCCUPIED if _has_open_lease(db, unit.id) else UnitStatus.VACANT


def create_lease(
    db: Session,
    manager_id: int,
    property_id: int,
    *,
    unit_id: int,
    tenant_id: int,
    start_date,
    end_date,
    monthly_rent: int,
) -> LeaseView:
    authorize(db, manager_id, property_id, Action.MANAGE_LEASES)
    unit = db.scalar(select(Unit).where(Unit.id == unit_id, Unit.property_id == property_id))
    if unit is None:
        raise UnitNotFound
    tenant = db.scalar(
        select(Tenant).where(Tenant.id == tenant_id, Tenant.property_id == property_id)
    )
    if tenant is None or not tenant.is_active:
        # An inactive tenant reads as absent so it cannot be picked for a new
        # lease, mirroring how units treat a deactivated unit type.
        raise TenantNotFound

    if _has_open_lease(db, unit.id):
        raise UnitAlreadyLeased

    lease = Lease(
        property_id=property_id,
        unit_id=unit.id,
        tenant_id=tenant.id,
        start_date=start_date,
        end_date=end_date,
        monthly_rent=monthly_rent,
    )
    db.add(lease)
    try:
        db.flush()  # materialise the lease so occupancy and the index see it
        _sync_occupancy(db, unit)
        db.commit()
    except IntegrityError:
        # The check above is a courtesy; the partial unique index is the
        # authority, because two concurrent requests can both pass a SELECT.
        db.rollback()
        raise UnitAlreadyLeased from None

    bus.publish(
        LeaseCreated(
            property_id=property_id,
            lease_id=lease.id,
            unit_id=unit.id,
            tenant_id=tenant.id,
            by_manager_id=manager_id,
        )
    )
    bus.publish(
        UnitOccupancyChanged(
            property_id=property_id,
            unit_id=unit.id,
            occupied=unit.status == UnitStatus.OCCUPIED,
            by_manager_id=manager_id,
        )
    )
    return _view(db, lease.id)


def list_leases(
    db: Session, manager_id: int, property_id: int, *, include_terminated: bool = False
) -> list[LeaseView]:
    authorize(db, manager_id, property_id, Action.VIEW_PROPERTY)
    stmt = (
        select(Lease, Unit.label, Tenant.full_name)
        .join(Unit, Unit.id == Lease.unit_id)
        .join(Tenant, Tenant.id == Lease.tenant_id)
        .where(Lease.property_id == property_id)
        .order_by(Lease.start_date.desc(), Lease.id.desc())
    )
    if not include_terminated:
        stmt = stmt.where(Lease.is_active.is_(True))
    return [LeaseView(*row) for row in db.execute(stmt)]


def get_lease(db: Session, manager_id: int, property_id: int, lease_id: int) -> LeaseView:
    authorize(db, manager_id, property_id, Action.VIEW_PROPERTY)
    _lease(db, property_id, lease_id)
    return _view(db, lease_id)


def terminate_lease(db: Session, manager_id: int, property_id: int, lease_id: int) -> LeaseView:
    """End a lease early. The contractual `end_date` is preserved as signed; the
    actual cut-off is `terminated_at`, which is what future billing reads."""
    authorize(db, manager_id, property_id, Action.MANAGE_LEASES)
    lease = _lease(db, property_id, lease_id)
    if not lease.is_active:
        raise LeaseAlreadyTerminated

    lease.is_active = False
    lease.terminated_at = datetime.now(timezone.utc)
    unit = db.get(Unit, lease.unit_id)
    db.flush()  # the lookup below runs against the database, not the memory
    _sync_occupancy(db, unit)
    db.commit()

    bus.publish(
        LeaseTerminated(
            property_id=property_id,
            lease_id=lease_id,
            unit_id=lease.unit_id,
            tenant_id=lease.tenant_id,
            by_manager_id=manager_id,
        )
    )
    bus.publish(
        UnitOccupancyChanged(
            property_id=property_id,
            unit_id=unit.id,
            occupied=unit.status == UnitStatus.OCCUPIED,
            by_manager_id=manager_id,
        )
    )
    return _view(db, lease_id)
