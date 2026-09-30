"""HTTP only: validate input, call one service function, shape the output."""
from typing import Annotated

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentManager
from app.schemas.auth import LoginRequest, ManagerOut, RefreshRequest, RegisterRequest, TokenPair
from app.services import auth as auth_service

router = APIRouter(prefix="/auth", tags=["auth"])
DB = Annotated[Session, Depends(get_db)]


@router.post("/register", response_model=ManagerOut, status_code=status.HTTP_201_CREATED)
def register(body: RegisterRequest, db: DB):
    return auth_service.register_manager(db, **body.model_dump())


@router.post("/login", response_model=TokenPair)
def login(body: LoginRequest, db: DB):
    return auth_service.login(db, email=body.email, password=body.password)


@router.post("/refresh", response_model=TokenPair)
def refresh(body: RefreshRequest, db: DB):
    return auth_service.refresh(db, refresh_token=body.refresh_token)


@router.get("/me", response_model=ManagerOut)
def me(manager: CurrentManager):
    return manager
