from datetime import date, datetime

from pydantic import BaseModel, Field, model_validator

from app.schemas.units import MAX_RENT  # XAF has no minor unit; same ceiling


class LeaseCreate(BaseModel):
    unit_id: int
    tenant_id: int
    start_date: date
    end_date: date
    monthly_rent: int = Field(ge=0, le=MAX_RENT)

    @model_validator(mode="after")
    def _range_is_ordered(self) -> "LeaseCreate":
        if self.end_date < self.start_date:
            raise ValueError("end_date must be on or after start_date")
        return self


class LeaseOut(BaseModel):
    """`unit_label` / `tenant_name` are joined in for display so the app never
    has to fetch three resources to draw a lease row."""

    id: int
    property_id: int
    unit_id: int
    unit_label: str
    tenant_id: int
    tenant_name: str
    start_date: date
    end_date: date
    monthly_rent: int
    is_active: bool
    terminated_at: datetime | None
    created_at: datetime
