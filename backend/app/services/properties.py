"""Property + access management (FR-04, FR-05). No HTTP dependencies (NFR-12)."""
from dataclasses import dataclass

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.access import authorize
from app.core.errors import ConflictError, NotFoundError
from app.core.events import bus
from app.core.policy import Action, Role
from app.events import AccessGranted, AccessRevoked, PropertyCreated, PropertyDeactivated
from app.models.manager import Manager
from app.models.property import Property, PropertyAccess
from app.models.unit import Unit, UnitStatus


class ManagerNotFound(NotFoundError):
    code = "manager_not_found"
    message = "No account exists for that email"


class AlreadyHasAccess(ConflictError):
    code = "already_has_access"
    message = "This manager already has access to the property"


class LastOwner(ConflictError):
    code = "last_owner"
    message = "A property must keep at least one owner"


@dataclass(frozen=True)
class PropertyView:
    property: Property
    role: Role  # the *requesting* manager's role
    unit_count: int
    occupied_count: int


@dataclass(frozen=True)
class AccessEntry:
    manager_id: int
    full_name: str
    email: str
    role: Role


def _views_query(manager_id: int):
    units = select(func.count(Unit.id)).where(Unit.property_id == Property.id)
    occupied = units.where(Unit.status == UnitStatus.OCCUPIED)
    return (
        select(
            Property,
            PropertyAccess.role,
            units.scalar_subquery(),
            occupied.scalar_subquery(),
        )
        .join(PropertyAccess, PropertyAccess.property_id == Property.id)
        .where(PropertyAccess.manager_id == manager_id)
    )


def _to_view(row) -> PropertyView:
    prop, role, unit_count, occupied = row
    return PropertyView(prop, role, unit_count or 0, occupied or 0)


def _view(db: Session, manager_id: int, property_id: int) -> PropertyView:
    return _to_view(db.execute(_views_query(manager_id).where(Property.id == property_id)).one())


def create_property(
    db: Session, manager_id: int, *, name: str, address: str | None = None, city: str | None = None
) -> PropertyView:
    prop = Property(name=name.strip(), address=address, city=city)
    db.add(prop)
    db.flush()
    # The creator becomes owner in the same transaction: no ownerless property can exist.
    db.add(PropertyAccess(property_id=prop.id, manager_id=manager_id, role=Role.OWNER))
    db.commit()
    bus.publish(PropertyCreated(property_id=prop.id, owner_id=manager_id))
    return _view(db, manager_id, prop.id)


def list_properties(
    db: Session, manager_id: int, *, include_inactive: bool = False
) -> list[PropertyView]:
    stmt = _views_query(manager_id).order_by(Property.name)
    if not include_inactive:
        stmt = stmt.where(Property.is_active.is_(True))
    return [_to_view(r) for r in db.execute(stmt)]


def get_property(db: Session, manager_id: int, property_id: int) -> PropertyView:
    authorize(db, manager_id, property_id, Action.VIEW_PROPERTY)
    return _view(db, manager_id, property_id)


def update_property(db: Session, manager_id: int, property_id: int, **fields) -> PropertyView:
    prop, _ = authorize(db, manager_id, property_id, Action.EDIT_PROPERTY)
    for key in ("name", "address", "city"):
        if key in fields:
            setattr(prop, key, fields[key])
    db.commit()
    return _view(db, manager_id, property_id)


def deactivate_property(db: Session, manager_id: int, property_id: int) -> PropertyView:
    prop, _ = authorize(db, manager_id, property_id, Action.DEACTIVATE_PROPERTY)
    prop.is_active = False
    db.commit()
    bus.publish(PropertyDeactivated(property_id=property_id, by_manager_id=manager_id))
    return _view(db, manager_id, property_id)


def list_access(db: Session, manager_id: int, property_id: int) -> list[AccessEntry]:
    authorize(db, manager_id, property_id, Action.VIEW_PROPERTY)
    rows = db.execute(
        select(Manager.id, Manager.full_name, Manager.email, PropertyAccess.role)
        .join(PropertyAccess, PropertyAccess.manager_id == Manager.id)
        .where(PropertyAccess.property_id == property_id)
        .order_by(Manager.full_name)
    )
    return [AccessEntry(*r) for r in rows]


def grant_access(
    db: Session, manager_id: int, property_id: int, *, email: str, role: Role
) -> AccessEntry:
    authorize(db, manager_id, property_id, Action.MANAGE_ACCESS)
    target = db.scalar(select(Manager).where(Manager.email == email.lower()))
    if target is None or not target.is_active:
        raise ManagerNotFound
    exists = db.scalar(
        select(PropertyAccess.id).where(
            PropertyAccess.property_id == property_id, PropertyAccess.manager_id == target.id
        )
    )
    if exists:
        raise AlreadyHasAccess
    db.add(PropertyAccess(property_id=property_id, manager_id=target.id, role=role))
    db.commit()
    bus.publish(
        AccessGranted(
            property_id=property_id, manager_id=target.id, role=role.value, by_manager_id=manager_id
        )
    )
    return AccessEntry(target.id, target.full_name, target.email, role)


def revoke_access(db: Session, manager_id: int, property_id: int, target_manager_id: int) -> None:
    authorize(db, manager_id, property_id, Action.MANAGE_ACCESS)
    access = db.scalar(
        select(PropertyAccess).where(
            PropertyAccess.property_id == property_id,
            PropertyAccess.manager_id == target_manager_id,
        )
    )
    if access is None:
        raise ManagerNotFound("That manager has no access to this property")
    if access.role is Role.OWNER:
        owners = db.scalar(
            select(func.count(PropertyAccess.id)).where(
                PropertyAccess.property_id == property_id, PropertyAccess.role == Role.OWNER
            )
        )
        if owners <= 1:
            raise LastOwner
    db.delete(access)
    db.commit()
    bus.publish(
        AccessRevoked(
            property_id=property_id, manager_id=target_manager_id, by_manager_id=manager_id
        )
    )
