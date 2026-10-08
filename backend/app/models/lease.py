from datetime import date, datetime
from decimal import Decimal

from sqlalchemy import Date, DateTime, ForeignKey, Index, Numeric, func, text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base

# A unit carries at most one *open* lease. Enforced by the database (not only by
# a SELECT in the service) so two concurrent lease creations cannot both pass the
# check. Terminated leases drop out of the index and keep their history.
# Rendered as `WHERE is_active` -- a boolean predicate, valid on Postgres and on
# the SQLite database the test suite runs against.
UQ_OPEN_LEASE_PER_UNIT = Index(
    "uq_leases_one_open_per_unit",
    "unit_id",
    unique=True,
    sqlite_where=text("is_active"),
    postgresql_where=text("is_active"),
)


class Lease(Base):
    """A tenant bound to a unit for a date range at a locked rent (FR-09).

    Snapshot pattern: `monthly_rent` and the date range are copied here at
    signing and never edited afterwards. A rent change means terminating this
    lease and signing a new one, so past ledger rows stay correct. `is_active`
    is the occupancy signal -- open lease means the unit is occupied.
    """

    __tablename__ = "leases"
    __table_args__ = (UQ_OPEN_LEASE_PER_UNIT,)

    id: Mapped[int] = mapped_column(primary_key=True)
    property_id: Mapped[int] = mapped_column(
        ForeignKey("properties.id", ondelete="CASCADE"), index=True
    )
    unit_id: Mapped[int] = mapped_column(ForeignKey("units.id"), index=True)
    tenant_id: Mapped[int] = mapped_column(ForeignKey("tenants.id"), index=True)
    start_date: Mapped[date] = mapped_column(Date)
    end_date: Mapped[date] = mapped_column(Date)
    monthly_rent: Mapped[Decimal] = mapped_column(Numeric(12, 0))  # XAF, locked
    is_active: Mapped[bool] = mapped_column(default=True)
    terminated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
