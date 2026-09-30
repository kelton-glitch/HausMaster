"""Unit types and units (FR-06, FR-07). No HTTP dependencies (NFR-12).

Every entry point first passes through `authorize`, so property-level rules
(roles, inactive properties) are enforced identically to the properties feature.
Occupancy (`Unit.status`) is owned by the lease feature; here it is read-only.
"""
from dataclasses import dataclass

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.access import authorize
from app.core.errors import ConflictError, NotFoundError
from app.core.events import bus
from app.core.policy import Action
from app.events import UnitCreated
from app.models.unit import Unit, UnitType


class UnitTypeNotFound(NotFoundError):
    code = "unit_type_not_found"
    message = "Unit type not found"


class UnitNotFound(NotFoundError):
    code = "unit_not_found"
    message = "Unit not found"


class UnitTypeNameTaken(ConflictError):
    code = "unit_type_name_taken"
    message = "A unit type with this name already exists in the property"


class UnitLabelTaken(ConflictError):
    code = "unit_label_taken"
    message = "A unit with this label already exists in the property"


@dataclass(frozen=True)
class UnitView:
    unit: Unit
    unit_type_name: str


# ---- unit types ----------------------------------------------------------


def _unit_type(db: Session, property_id: int, unit_type_id: int) -> UnitType:
    ut = db.scalar(
        select(UnitType).where(UnitType.id == unit_type_id, UnitType.property_id == property_id)
    )
    if ut is None:
        raise UnitTypeNotFound
    return ut


def _type_name_taken(db: Session, property_id: int, name: str, *, exclude_id: int | None = None):
    stmt = select(UnitType.id).where(
        UnitType.property_id == property_id, func.lower(UnitType.name) == name.lower()
    )
    if exclude_id is not None:
        stmt = stmt.where(UnitType.id != exclude_id)
    return db.scalar(stmt) is not None


def create_unit_type(
    db: Session, manager_id: int, property_id: int, *, name: str, room_count: int, base_rent: int
) -> UnitType:
    authorize(db, manager_id, property_id, Action.MANAGE_UNITS)
    name = name.strip()
    if _type_name_taken(db, property_id, name):
        raise UnitTypeNameTaken
    ut = UnitType(property_id=property_id, name=name, room_count=room_count, base_rent=base_rent)
    db.add(ut)
    db.commit()
    return ut


def list_unit_types(
    db: Session, manager_id: int, property_id: int, *, include_inactive: bool = False
) -> list[UnitType]:
    authorize(db, manager_id, property_id, Action.VIEW_PROPERTY)
    stmt = select(UnitType).where(UnitType.property_id == property_id).order_by(UnitType.name)
    if not include_inactive:
        stmt = stmt.where(UnitType.is_active.is_(True))
    return list(db.scalars(stmt))


def update_unit_type(
    db: Session, manager_id: int, property_id: int, unit_type_id: int, **fields
) -> UnitType:
    authorize(db, manager_id, property_id, Action.MANAGE_UNITS)
    ut = _unit_type(db, property_id, unit_type_id)
    if "name" in fields:
        name = fields["name"].strip()
        if _type_name_taken(db, property_id, name, exclude_id=ut.id):
            raise UnitTypeNameTaken
        ut.name = name
    for key in ("room_count", "base_rent"):
        if key in fields:
            setattr(ut, key, fields[key])
    db.commit()
    return ut


def deactivate_unit_type(
    db: Session, manager_id: int, property_id: int, unit_type_id: int
) -> UnitType:
    authorize(db, manager_id, property_id, Action.MANAGE_UNITS)
    ut = _unit_type(db, property_id, unit_type_id)
    ut.is_active = False  # never deleted: existing units/leases still reference it
    db.commit()
    return ut


# ---- units ---------------------------------------------------------------


def _label_taken(db: Session, property_id: int, label: str, *, exclude_id: int | None = None):
    stmt = select(Unit.id).where(
        Unit.property_id == property_id, func.lower(Unit.label) == label.lower()
    )
    if exclude_id is not None:
        stmt = stmt.where(Unit.id != exclude_id)
    return db.scalar(stmt) is not None


def _unit_view(db: Session, property_id: int, unit_id: int) -> UnitView:
    row = db.execute(
        select(Unit, UnitType.name)
        .join(UnitType, UnitType.id == Unit.unit_type_id)
        .where(Unit.id == unit_id, Unit.property_id == property_id)
    ).first()
    if row is None:
        raise UnitNotFound
    return UnitView(*row)


def create_unit(
    db: Session, manager_id: int, property_id: int, *, label: str, unit_type_id: int
) -> UnitView:
    authorize(db, manager_id, property_id, Action.MANAGE_UNITS)
    ut = _unit_type(db, property_id, unit_type_id)
    if not ut.is_active:
        raise UnitTypeNotFound
    label = label.strip()
    if _label_taken(db, property_id, label):
        raise UnitLabelTaken
    unit = Unit(property_id=property_id, unit_type_id=ut.id, label=label)
    db.add(unit)
    db.commit()
    bus.publish(UnitCreated(property_id=property_id, unit_id=unit.id, by_manager_id=manager_id))
    return _unit_view(db, property_id, unit.id)


def list_units(db: Session, manager_id: int, property_id: int) -> list[UnitView]:
    authorize(db, manager_id, property_id, Action.VIEW_PROPERTY)
    rows = db.execute(
        select(Unit, UnitType.name)
        .join(UnitType, UnitType.id == Unit.unit_type_id)
        .where(Unit.property_id == property_id)
        .order_by(Unit.label)
    )
    return [UnitView(*r) for r in rows]


def get_unit(db: Session, manager_id: int, property_id: int, unit_id: int) -> UnitView:
    authorize(db, manager_id, property_id, Action.VIEW_PROPERTY)
    return _unit_view(db, property_id, unit_id)


def update_unit(
    db: Session, manager_id: int, property_id: int, unit_id: int, **fields
) -> UnitView:
    authorize(db, manager_id, property_id, Action.MANAGE_UNITS)
    unit = _unit_view(db, property_id, unit_id).unit
    if "label" in fields:
        label = fields["label"].strip()
        if _label_taken(db, property_id, label, exclude_id=unit.id):
            raise UnitLabelTaken
        unit.label = label
    if "unit_type_id" in fields and fields["unit_type_id"] != unit.unit_type_id:
        # Only a *change* of type must target an active type; a unit may keep
        # a type that was deactivated after it was assigned.
        ut = _unit_type(db, property_id, fields["unit_type_id"])
        if not ut.is_active:
            raise UnitTypeNotFound
        unit.unit_type_id = ut.id
    db.commit()
    return _unit_view(db, property_id, unit_id)
