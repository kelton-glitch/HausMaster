"""HTTP only: validate input, call one service function, shape the output."""
from typing import Annotated

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentManager
from app.schemas.properties import (
    AccessGrant,
    AccessOut,
    PropertyCreate,
    PropertyOut,
    PropertyUpdate,
)
from app.services import properties as svc

router = APIRouter(prefix="/properties", tags=["properties"])
DB = Annotated[Session, Depends(get_db)]


def _out(v: svc.PropertyView) -> PropertyOut:
    p = v.property
    return PropertyOut(
        id=p.id,
        name=p.name,
        address=p.address,
        city=p.city,
        is_active=p.is_active,
        role=v.role,
        unit_count=v.unit_count,
        occupied_count=v.occupied_count,
    )


@router.post("", response_model=PropertyOut, status_code=status.HTTP_201_CREATED)
def create_property(body: PropertyCreate, me: CurrentManager, db: DB):
    return _out(svc.create_property(db, me.id, **body.model_dump()))


@router.get("", response_model=list[PropertyOut])
def list_properties(me: CurrentManager, db: DB, include_inactive: bool = False):
    return [_out(v) for v in svc.list_properties(db, me.id, include_inactive=include_inactive)]


@router.get("/{property_id}", response_model=PropertyOut)
def get_property(property_id: int, me: CurrentManager, db: DB):
    return _out(svc.get_property(db, me.id, property_id))


@router.patch("/{property_id}", response_model=PropertyOut)
def update_property(property_id: int, body: PropertyUpdate, me: CurrentManager, db: DB):
    return _out(svc.update_property(db, me.id, property_id, **body.model_dump(exclude_unset=True)))


@router.post("/{property_id}/deactivate", response_model=PropertyOut)
def deactivate_property(property_id: int, me: CurrentManager, db: DB):
    return _out(svc.deactivate_property(db, me.id, property_id))


@router.get("/{property_id}/managers", response_model=list[AccessOut])
def list_managers(property_id: int, me: CurrentManager, db: DB):
    return [AccessOut(**vars(e)) for e in svc.list_access(db, me.id, property_id)]


@router.post(
    "/{property_id}/managers", response_model=AccessOut, status_code=status.HTTP_201_CREATED
)
def grant_access(property_id: int, body: AccessGrant, me: CurrentManager, db: DB):
    return AccessOut(
        **vars(svc.grant_access(db, me.id, property_id, email=body.email, role=body.role))
    )


@router.delete("/{property_id}/managers/{manager_id}", status_code=status.HTTP_204_NO_CONTENT)
def revoke_access(property_id: int, manager_id: int, me: CurrentManager, db: DB):
    svc.revoke_access(db, me.id, property_id, manager_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
