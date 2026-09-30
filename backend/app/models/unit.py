from datetime import datetime
from decimal import Decimal
from enum import StrEnum

from sqlalchemy import ForeignKey, Numeric, String, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.types import enum_column


class UnitStatus(StrEnum):
    VACANT = "vacant"
    OCCUPIED = "occupied"


class UnitType(Base):
    """Template for a room category (FR-06). Leases will snapshot its rent, so
    editing a type never changes an active lease."""

    __tablename__ = "unit_types"
    __table_args__ = (UniqueConstraint("property_id", "name"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    property_id: Mapped[int] = mapped_column(
        ForeignKey("properties.id", ondelete="CASCADE"), index=True
    )
    name: Mapped[str] = mapped_column(String(80))
    room_count: Mapped[int]
    base_rent: Mapped[Decimal] = mapped_column(Numeric(12, 0))  # XAF has no minor unit
    is_active: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())


class Unit(Base):
    """A physical, individually rentable space (FR-07)."""

    __tablename__ = "units"
    __table_args__ = (UniqueConstraint("property_id", "label"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    property_id: Mapped[int] = mapped_column(
        ForeignKey("properties.id", ondelete="CASCADE"), index=True
    )
    unit_type_id: Mapped[int] = mapped_column(ForeignKey("unit_types.id"), index=True)
    label: Mapped[str] = mapped_column(String(40))
    status: Mapped[UnitStatus] = enum_column(UnitStatus, default=UnitStatus.VACANT)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
