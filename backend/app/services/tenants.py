"""Tenant profiles (FR-08). No HTTP dependencies (NFR-12).

Tenants are property-scoped, so every entry point starts with `authorize` and
inherits the role and inactive-property rules of the properties feature.
Records are never deleted -- past ledger rows must stay readable (NFR-05);
`deactivate` retires a tenant who moved out.
"""

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.access import authorize
from app.core.errors import ConflictError, NotFoundError
from app.core.events import bus
from app.core.policy import Action
from app.events import TenantCreated, TenantDeactivated
from app.models.tenant import Tenant


class TenantNotFound(NotFoundError):
    code = "tenant_not_found"
    message = "Tenant not found"


class TenantPhoneTaken(ConflictError):
    code = "tenant_phone_taken"
    message = "A tenant with this phone number already exists in the property"


def _strip_optional(value: str | None) -> str | None:
    return value.strip() or None if isinstance(value, str) else value


def _tenant(db: Session, property_id: int, tenant_id: int) -> Tenant:
    tenant = db.scalar(
        select(Tenant).where(Tenant.id == tenant_id, Tenant.property_id == property_id)
    )
    if tenant is None:
        raise TenantNotFound
    return tenant


def _phone_taken(
    db: Session, property_id: int, phone: str, *, exclude_id: int | None = None
) -> bool:
    """Phone is how a landlord tells tenants apart in the field, so it identifies
    a tenant uniquely inside one property."""
    stmt = select(Tenant.id).where(Tenant.property_id == property_id, Tenant.phone == phone)
    if exclude_id is not None:
        stmt = stmt.where(Tenant.id != exclude_id)
    return db.scalar(stmt) is not None


def create_tenant(
    db: Session,
    manager_id: int,
    property_id: int,
    *,
    full_name: str,
    phone: str,
    email: str | None = None,
    national_id: str | None = None,
    emergency_contact: str | None = None,
) -> Tenant:
    authorize(db, manager_id, property_id, Action.MANAGE_TENANTS)
    phone = phone.strip()
    if _phone_taken(db, property_id, phone):
        raise TenantPhoneTaken
    tenant = Tenant(
        property_id=property_id,
        full_name=full_name.strip(),
        phone=phone,
        email=email,
        national_id=_strip_optional(national_id),
        emergency_contact=_strip_optional(emergency_contact),
    )
    db.add(tenant)
    db.commit()
    bus.publish(
        TenantCreated(property_id=property_id, tenant_id=tenant.id, by_manager_id=manager_id)
    )
    return tenant


def list_tenants(
    db: Session, manager_id: int, property_id: int, *, include_inactive: bool = False
) -> list[Tenant]:
    authorize(db, manager_id, property_id, Action.VIEW_PROPERTY)
    stmt = select(Tenant).where(Tenant.property_id == property_id)
    if not include_inactive:
        stmt = stmt.where(Tenant.is_active.is_(True))
    return list(db.scalars(stmt.order_by(Tenant.full_name)))


def get_tenant(db: Session, manager_id: int, property_id: int, tenant_id: int) -> Tenant:
    authorize(db, manager_id, property_id, Action.VIEW_PROPERTY)
    return _tenant(db, property_id, tenant_id)


def update_tenant(
    db: Session, manager_id: int, property_id: int, tenant_id: int, **fields
) -> Tenant:
    authorize(db, manager_id, property_id, Action.MANAGE_TENANTS)
    tenant = _tenant(db, property_id, tenant_id)
    if "phone" in fields:
        phone = fields["phone"].strip()
        if _phone_taken(db, property_id, phone, exclude_id=tenant.id):
            raise TenantPhoneTaken
        tenant.phone = phone
    if "full_name" in fields:
        tenant.full_name = fields["full_name"].strip()
    if "email" in fields:
        tenant.email = fields["email"]
    for key in ("national_id", "emergency_contact"):
        if key in fields:
            setattr(tenant, key, _strip_optional(fields[key]))
    db.commit()
    return tenant


def deactivate_tenant(db: Session, manager_id: int, property_id: int, tenant_id: int) -> Tenant:
    authorize(db, manager_id, property_id, Action.MANAGE_TENANTS)
    tenant = _tenant(db, property_id, tenant_id)
    tenant.is_active = False  # never deleted: leases still reference it
    db.commit()
    bus.publish(
        TenantDeactivated(property_id=property_id, tenant_id=tenant_id, by_manager_id=manager_id)
    )
    return tenant
