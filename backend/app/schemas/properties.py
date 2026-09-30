from pydantic import BaseModel, EmailStr, Field, field_validator

from app.core.policy import Role


def _strip(v: str | None) -> str | None:
    return v.strip() or None if isinstance(v, str) else v


class PropertyCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    address: str | None = Field(default=None, max_length=255)
    city: str | None = Field(default=None, max_length=80)

    _clean = field_validator("address", "city")(_strip)


class PropertyUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    address: str | None = Field(default=None, max_length=255)
    city: str | None = Field(default=None, max_length=80)

    _clean = field_validator("address", "city")(_strip)


class PropertyOut(BaseModel):
    id: int
    name: str
    address: str | None
    city: str | None
    is_active: bool
    role: Role  # the requesting manager's role on this property
    unit_count: int
    occupied_count: int


class AccessGrant(BaseModel):
    email: EmailStr
    role: Role = Role.CO_MANAGER


class AccessOut(BaseModel):
    manager_id: int
    full_name: str
    email: EmailStr
    role: Role
