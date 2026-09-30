from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import CurrentManager
from app.schemas.auth import LoginRequest, ManagerOut, RefreshRequest, RegisterRequest, TokenPair
from app.services import auth as auth_service

router = APIRouter(prefix="/auth", tags=["auth"])
DB = Annotated[Session, Depends(get_db)]


@router.post("/register", response_model=ManagerOut, status_code=status.HTTP_201_CREATED)
def register(body: RegisterRequest, db: DB):
    try:
        return auth_service.register_manager(db, **body.model_dump())
    except auth_service.EmailAlreadyRegistered:
        raise HTTPException(status.HTTP_409_CONFLICT, "Email already registered")


@router.post("/login", response_model=TokenPair)
def login(body: LoginRequest, db: DB):
    try:
        return auth_service.login(db, email=body.email, password=body.password)
    except auth_service.InvalidCredentials:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid email or password")


@router.post("/refresh", response_model=TokenPair)
def refresh(body: RefreshRequest, db: DB):
    try:
        return auth_service.refresh(db, refresh_token=body.refresh_token)
    except auth_service.InvalidCredentials:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid refresh token")


@router.get("/me", response_model=ManagerOut)
def me(manager: CurrentManager):
    return manager
