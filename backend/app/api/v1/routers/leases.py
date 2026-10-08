"""HTTP only: validate input, call one service function, shape the output.

No update endpoint on purpose: rent and dates are locked at signing. A change of
rent is `POST /leases` after terminating the previous lease.
"""

from typing import Annotated

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentManager
from app.schemas.leases import LeaseCreate, LeaseOut
from app.services import leases as svc

router = APIRouter(prefix="/properties/{property_id}", tags=["leases"])
DB = Annotated[Session, Depends(get_db)]


def _out(v: svc.LeaseView) -> LeaseOut:
    lease = v.lease
    return LeaseOut(
        id=lease.id,
        property_id=lease.property_id,
        unit_id=lease.unit_id,
        unit_label=v.unit_label,
        tenant_id=lease.tenant_id,
        tenant_name=v.tenant_name,
        start_date=lease.start_date,
        end_date=lease.end_date,
        monthly_rent=lease.monthly_rent,
        is_active=lease.is_active,
        terminated_at=lease.terminated_at,
        created_at=lease.created_at,
    )


@router.get("/leases", response_model=list[LeaseOut])
def list_leases(property_id: int, me: CurrentManager, db: DB, include_terminated: bool = False):
    return [
        _out(v)
        for v in svc.list_leases(db, me.id, property_id, include_terminated=include_terminated)
    ]


@router.post("/leases", response_model=LeaseOut, status_code=status.HTTP_201_CREATED)
def create_lease(property_id: int, body: LeaseCreate, me: CurrentManager, db: DB):
    return _out(svc.create_lease(db, me.id, property_id, **body.model_dump()))


@router.get("/leases/{lease_id}", response_model=LeaseOut)
def get_lease(property_id: int, lease_id: int, me: CurrentManager, db: DB):
    return _out(svc.get_lease(db, me.id, property_id, lease_id))


@router.post("/leases/{lease_id}/terminate", response_model=LeaseOut)
def terminate_lease(property_id: int, lease_id: int, me: CurrentManager, db: DB):
    return _out(svc.terminate_lease(db, me.id, property_id, lease_id))
