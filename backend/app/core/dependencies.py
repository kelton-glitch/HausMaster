from typing import Annotated

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import decode_token
from app.models.manager import Manager

_bearer = HTTPBearer()


def get_current_manager(
    creds: Annotated[HTTPAuthorizationCredentials, Depends(_bearer)],
    db: Annotated[Session, Depends(get_db)],
) -> Manager:
    unauthorized = HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid or expired token")
    try:
        manager_id = decode_token(creds.credentials, "access")
    except jwt.InvalidTokenError:
        raise unauthorized
    manager = db.get(Manager, int(manager_id))
    if manager is None or not manager.is_active:
        raise unauthorized
    return manager


CurrentManager = Annotated[Manager, Depends(get_current_manager)]
