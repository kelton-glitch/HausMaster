from datetime import datetime

from sqlalchemy import ForeignKey, String, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Tenant(Base):
    """A person who occupies a unit (FR-08).

    Property-scoped: a lease binds a tenant to a unit of one property, so the
    profile lives next to that property and is guarded by the same `authorize`.
    Never deleted -- rent history must stay readable (NFR-05); `deactivate`
    retires a tenant who moved out.
    """

    __tablename__ = "tenants"
    __table_args__ = (UniqueConstraint("property_id", "phone"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    property_id: Mapped[int] = mapped_column(
        ForeignKey("properties.id", ondelete="CASCADE"), index=True
    )
    full_name: Mapped[str] = mapped_column(String(120))
    phone: Mapped[str] = mapped_column(String(32))
    email: Mapped[str | None] = mapped_column(String(255))
    national_id: Mapped[str | None] = mapped_column(String(64))
    emergency_contact: Mapped[str | None] = mapped_column(String(160))
    is_active: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
