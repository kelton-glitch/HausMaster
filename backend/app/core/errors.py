"""One error language for the whole backend.

Services raise these (no HTTP knowledge). A single handler in `app/api/errors.py`
maps the *kind* to a status code and sends `{"detail", "code"}`. The `code` is
stable and machine-readable, so clients (the Flutter app) can localize messages
without parsing English text.
"""


class DomainError(Exception):
    code = "error"
    message = "Something went wrong"

    def __init__(self, message: str | None = None):
        self.message = message or self.message
        super().__init__(self.message)


class NotFoundError(DomainError):
    code = "not_found"
    message = "Not found"


class ForbiddenError(DomainError):
    code = "forbidden"
    message = "You are not allowed to do that"


class ConflictError(DomainError):
    code = "conflict"
    message = "Conflict"


class UnauthorizedError(DomainError):
    code = "unauthorized"
    message = "Authentication required"


class InvalidToken(UnauthorizedError):
    code = "invalid_token"
    message = "Invalid or expired token"
