"""HTTP only: validate input, call one service function, shape the output."""

from typing import Annotated

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentManager
from app.schemas.tenants import TenantCreate, TenantOut, TenantUpdate
from app.services import tenants as svc

router = APIRouter(prefix="/properties/{property_id}", tags=["tenants"])
DB = Annotated[Session, Depends(get_db)]


@router.get("/tenants", response_model=list[TenantOut])
def list_tenants(property_id: int, me: CurrentManager, db: DB, include_inactive: bool = False):
    return svc.list_tenants(db, me.id, property_id, include_inactive=include_inactive)


@router.post("/tenants", response_model=TenantOut, status_code=status.HTTP_201_CREATED)
def create_tenant(property_id: int, body: TenantCreate, me: CurrentManager, db: DB):
    return svc.create_tenant(db, me.id, property_id, **body.model_dump())


@router.get("/tenants/{tenant_id}", response_model=TenantOut)
def get_tenant(property_id: int, tenant_id: int, me: CurrentManager, db: DB):
    return svc.get_tenant(db, me.id, property_id, tenant_id)


@router.patch("/tenants/{tenant_id}", response_model=TenantOut)
def update_tenant(property_id: int, tenant_id: int, body: TenantUpdate, me: CurrentManager, db: DB):
    return svc.update_tenant(
        db, me.id, property_id, tenant_id, **body.model_dump(exclude_unset=True)
    )


@router.post("/tenants/{tenant_id}/deactivate", response_model=TenantOut)
def deactivate_tenant(property_id: int, tenant_id: int, me: CurrentManager, db: DB):
    return svc.deactivate_tenant(db, me.id, property_id, tenant_id)
