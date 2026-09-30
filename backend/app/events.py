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
