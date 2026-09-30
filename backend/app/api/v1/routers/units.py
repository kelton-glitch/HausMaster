"""HTTP only: validate input, call one service function, shape the output."""
from typing import Annotated

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentManager
from app.schemas.units import (
    UnitCreate,
    UnitOut,
    UnitTypeCreate,
    UnitTypeOut,
    UnitTypeUpdate,
    UnitUpdate,
)
from app.services import units as svc

router = APIRouter(prefix="/properties/{property_id}", tags=["units"])
DB = Annotated[Session, Depends(get_db)]


def _unit(v: svc.UnitView) -> UnitOut:
    u = v.unit
    return UnitOut(
        id=u.id,
        property_id=u.property_id,
        label=u.label,
        unit_type_id=u.unit_type_id,
        unit_type_name=v.unit_type_name,
        status=u.status,
    )


@router.get("/unit-types", response_model=list[UnitTypeOut])
def list_unit_types(property_id: int, me: CurrentManager, db: DB, include_inactive: bool = False):
    return svc.list_unit_types(db, me.id, property_id, include_inactive=include_inactive)


@router.post("/unit-types", response_model=UnitTypeOut, status_code=status.HTTP_201_CREATED)
def create_unit_type(property_id: int, body: UnitTypeCreate, me: CurrentManager, db: DB):
    return svc.create_unit_type(db, me.id, property_id, **body.model_dump())


@router.patch("/unit-types/{unit_type_id}", response_model=UnitTypeOut)
def update_unit_type(
    property_id: int, unit_type_id: int, body: UnitTypeUpdate, me: CurrentManager, db: DB
):
    return svc.update_unit_type(
        db, me.id, property_id, unit_type_id, **body.model_dump(exclude_unset=True)
    )


@router.post("/unit-types/{unit_type_id}/deactivate", response_model=UnitTypeOut)
def deactivate_unit_type(property_id: int, unit_type_id: int, me: CurrentManager, db: DB):
    return svc.deactivate_unit_type(db, me.id, property_id, unit_type_id)


@router.get("/units", response_model=list[UnitOut])
def list_units(property_id: int, me: CurrentManager, db: DB):
    return [_unit(v) for v in svc.list_units(db, me.id, property_id)]


@router.post("/units", response_model=UnitOut, status_code=status.HTTP_201_CREATED)
def create_unit(property_id: int, body: UnitCreate, me: CurrentManager, db: DB):
    return _unit(svc.create_unit(db, me.id, property_id, **body.model_dump()))


@router.get("/units/{unit_id}", response_model=UnitOut)
def get_unit(property_id: int, unit_id: int, me: CurrentManager, db: DB):
    return _unit(svc.get_unit(db, me.id, property_id, unit_id))


@router.patch("/units/{unit_id}", response_model=UnitOut)
def update_unit(property_id: int, unit_id: int, body: UnitUpdate, me: CurrentManager, db: DB):
    return _unit(
        svc.update_unit(db, me.id, property_id, unit_id, **body.model_dump(exclude_unset=True))
    )
