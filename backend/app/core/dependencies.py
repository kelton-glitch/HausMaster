from typing import Annotated

import jwt
from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.errors import InvalidToken
from app.core.security import decode_token
from app.models.manager import Manager

_bearer = HTTPBearer()


def get_current_manager(
    creds: Annotated[HTTPAuthorizationCredentials, Depends(_bearer)],
    db: Annotated[Session, Depends(get_db)],
) -> Manager:
    try:
        manager_id = int(decode_token(creds.credentials, "access"))
    except (jwt.InvalidTokenError, ValueError):
        raise InvalidToken
    manager = db.get(Manager, manager_id)
    if manager is None or not manager.is_active:
        raise InvalidToken
    return manager


CurrentManager = Annotated[Manager, Depends(get_current_manager)]
