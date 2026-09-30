from pydantic import BaseModel, ConfigDict, Field

from app.models.unit import UnitStatus

# XAF has no minor unit, so amounts travel as whole-number JSON integers.
MAX_RENT = 10**10


class UnitTypeCreate(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    room_count: int = Field(ge=1, le=100)
    base_rent: int = Field(ge=0, le=MAX_RENT)


class UnitTypeUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=80)
    room_count: int | None = Field(default=None, ge=1, le=100)
    base_rent: int | None = Field(default=None, ge=0, le=MAX_RENT)


class UnitTypeOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    property_id: int
    name: str
    room_count: int
    base_rent: int
    is_active: bool


class UnitCreate(BaseModel):
    label: str = Field(min_length=1, max_length=40)
    unit_type_id: int


class UnitUpdate(BaseModel):
    label: str | None = Field(default=None, min_length=1, max_length=40)
    unit_type_id: int | None = None


class UnitOut(BaseModel):
    id: int
    property_id: int
    label: str
    unit_type_id: int
    unit_type_name: str
    status: UnitStatus
