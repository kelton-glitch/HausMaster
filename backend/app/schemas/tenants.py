from pydantic import BaseModel, EmailStr, Field, field_validator


def _strip(v: str | None) -> str | None:
    """Blank optional text becomes None instead of an empty string."""
    return v.strip() or None if isinstance(v, str) else v


def _strip_required(v: str | None) -> str | None:
    """Same, but a blank required value is rejected.

    Runs *before* the length constraints, so `"   "` fails `min_length=1`
    instead of sneaking through as an empty string. None passes through, which
    is what an omitted field on an update looks like.
    """
    if isinstance(v, str):
        v = v.strip()
        if not v:
            raise ValueError("must not be blank")
    return v


class TenantCreate(BaseModel):
    full_name: str = Field(min_length=1, max_length=120)
    phone: str = Field(min_length=1, max_length=32)
    email: EmailStr | None = None
    national_id: str | None = Field(default=None, max_length=64)
    emergency_contact: str | None = Field(default=None, max_length=160)

    _clean_required = field_validator("full_name", "phone", mode="before")(_strip_required)
    _clean = field_validator("national_id", "emergency_contact", mode="before")(_strip)


class TenantUpdate(BaseModel):
    full_name: str | None = Field(default=None, min_length=1, max_length=120)
    phone: str | None = Field(default=None, min_length=1, max_length=32)
    email: EmailStr | None = None
    national_id: str | None = Field(default=None, max_length=64)
    emergency_contact: str | None = Field(default=None, max_length=160)

    _clean_required = field_validator("full_name", "phone", mode="before")(_strip_required)
    _clean = field_validator("national_id", "emergency_contact", mode="before")(_strip)


class TenantOut(BaseModel):
    id: int
    property_id: int
    full_name: str
    phone: str
    email: str | None
    national_id: str | None
    emergency_contact: str | None
    is_active: bool
