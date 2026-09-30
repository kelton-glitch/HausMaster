"""The single gate every property-scoped feature goes through.

    prop, role = authorize(db, manager_id, property_id, Action.MANAGE_UNITS)

Returns 404 (not 403) when the manager has no access at all, so the existence
of other people's properties is never revealed.
"""
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import ConflictError, ForbiddenError, NotFoundError
from app.core.policy import Action, Role, can
from app.models.property import Property, PropertyAccess


class PropertyNotFound(NotFoundError):
    code = "property_not_found"
    message = "Property not found"


class AccessDenied(ForbiddenError):
    code = "access_denied"
    message = "You do not have permission to do this on this property"


class PropertyInactive(ConflictError):
    code = "property_inactive"
    message = "This property is deactivated"


def authorize(
    db: Session, manager_id: int, property_id: int, action: Action
) -> tuple[Property, Role]:
    row = db.execute(
        select(Property, PropertyAccess.role)
        .join(PropertyAccess, PropertyAccess.property_id == Property.id)
        .where(Property.id == property_id, PropertyAccess.manager_id == manager_id)
    ).first()
    if row is None:
        raise PropertyNotFound
    prop, role = row
    if not can(role, action):
        raise AccessDenied
    if not prop.is_active and action is not Action.VIEW_PROPERTY:
        raise PropertyInactive
    return prop, role
