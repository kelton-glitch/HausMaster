"""Facts the system announces. Plain data; no behaviour.

Keep payloads to ids and primitives so subscribers stay decoupled from ORM models.
"""

from dataclasses import dataclass

from app.core.events import DomainEvent


@dataclass(frozen=True, kw_only=True)
class PropertyCreated(DomainEvent):
    property_id: int
    owner_id: int


@dataclass(frozen=True, kw_only=True)
class PropertyDeactivated(DomainEvent):
    property_id: int
    by_manager_id: int


@dataclass(frozen=True, kw_only=True)
class AccessGranted(DomainEvent):
    property_id: int
    manager_id: int
    role: str
    by_manager_id: int


@dataclass(frozen=True, kw_only=True)
class AccessRevoked(DomainEvent):
    property_id: int
    manager_id: int
    by_manager_id: int


@dataclass(frozen=True, kw_only=True)
class UnitCreated(DomainEvent):
    property_id: int
    unit_id: int
    by_manager_id: int


@dataclass(frozen=True, kw_only=True)
class TenantCreated(DomainEvent):
    property_id: int
    tenant_id: int
    by_manager_id: int


@dataclass(frozen=True, kw_only=True)
class TenantDeactivated(DomainEvent):
    property_id: int
    tenant_id: int
    by_manager_id: int


@dataclass(frozen=True, kw_only=True)
class LeaseCreated(DomainEvent):
    property_id: int
    lease_id: int
    unit_id: int
    tenant_id: int
    by_manager_id: int


@dataclass(frozen=True, kw_only=True)
class LeaseTerminated(DomainEvent):
    property_id: int
    lease_id: int
    unit_id: int
    tenant_id: int
    by_manager_id: int


@dataclass(frozen=True, kw_only=True)
class UnitOccupancyChanged(DomainEvent):
    """A unit became occupied or vacant. Carries no status: subscribers re-read
    it if they care, and this event means "occupancy moved", nothing more."""

    property_id: int
    unit_id: int
    occupied: bool
    by_manager_id: int
