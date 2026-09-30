"""Auth business logic. No HTTP dependencies (NFR-12)."""
import jwt
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.models.manager import Manager


class EmailAlreadyRegistered(Exception):
    pass


class InvalidCredentials(Exception):
    """Raised for unknown email, wrong password and bad refresh token alike."""


def register_manager(
    db: Session, *, full_name: str, email: str, password: str, phone: str | None = None
) -> Manager:
    email = email.lower()
    if db.scalar(select(Manager).where(Manager.email == email)):
        raise EmailAlreadyRegistered
    manager = Manager(
        full_name=full_name, email=email, phone=phone, password_hash=hash_password(password)
    )
    db.add(manager)
    db.commit()
    return manager


def _token_pair(manager: Manager) -> dict[str, str]:
    sub = str(manager.id)
    return {"access_token": create_access_token(sub), "refresh_token": create_refresh_token(sub)}


def login(db: Session, *, email: str, password: str) -> dict[str, str]:
    manager = db.scalar(select(Manager).where(Manager.email == email.lower()))
    if manager is None or not manager.is_active or not verify_password(password, manager.password_hash):
        raise InvalidCredentials
    return _token_pair(manager)


def refresh(db: Session, *, refresh_token: str) -> dict[str, str]:
    try:
        manager_id = int(decode_token(refresh_token, "refresh"))
    except (jwt.InvalidTokenError, ValueError):
        raise InvalidCredentials
    manager = db.get(Manager, manager_id)
    if manager is None or not manager.is_active:
        raise InvalidCredentials
    return _token_pair(manager)
