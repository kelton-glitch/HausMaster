from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.core.errors import (
    ConflictError,
    DomainError,
    ForbiddenError,
    NotFoundError,
    UnauthorizedError,
)

# The only place where domain error kinds meet HTTP status codes.
_STATUS: list[tuple[type[DomainError], int]] = [
    (NotFoundError, 404),
    (ForbiddenError, 403),
    (ConflictError, 409),
    (UnauthorizedError, 401),
]


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(DomainError)
    async def _domain_error(_: Request, exc: DomainError) -> JSONResponse:
        status = next((s for kind, s in _STATUS if isinstance(exc, kind)), 400)
        headers = {"WWW-Authenticate": "Bearer"} if status == 401 else None
        return JSONResponse(
            status_code=status,
            content={"detail": exc.message, "code": exc.code},
            headers=headers,
        )
