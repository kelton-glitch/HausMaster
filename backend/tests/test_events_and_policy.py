"""Unit tests for the shared building blocks: no HTTP, no DB."""
from app.core.events import DomainEvent, EventBus
from app.core.policy import POLICY, Action, Role, can
from app.events import PropertyCreated, UnitCreated


def test_bus_delivers_to_exact_and_base_type_subscribers():
    bus = EventBus()
    exact, everything = [], []
    bus.subscribe(PropertyCreated, exact.append)
    bus.subscribe(DomainEvent, everything.append)

    bus.publish(PropertyCreated(property_id=1, owner_id=2))
    bus.publish(UnitCreated(property_id=1, unit_id=3, by_manager_id=2))

    assert len(exact) == 1
    assert len(everything) == 2


def test_bus_isolates_failing_handler():
    bus = EventBus()
    seen = []

    def boom(_):
        raise RuntimeError("subscriber bug")

    bus.subscribe(DomainEvent, boom)
    bus.subscribe(DomainEvent, seen.append)
    bus.publish(PropertyCreated(property_id=1, owner_id=1))  # must not raise
    assert len(seen) == 1


def test_bus_unsubscribe():
    bus = EventBus()
    seen = []
    bus.subscribe(DomainEvent, seen.append)
    bus.unsubscribe(DomainEvent, seen.append)
    bus.publish(PropertyCreated(property_id=1, owner_id=1))
    assert seen == []


def test_policy_every_role_is_covered_and_owner_can_do_everything():
    assert set(POLICY) == set(Role)
    assert all(can(Role.OWNER, a) for a in Action)


def test_co_manager_is_operational_only():
    assert can(Role.CO_MANAGER, Action.VIEW_PROPERTY)
    assert can(Role.CO_MANAGER, Action.MANAGE_UNITS)
    assert not can(Role.CO_MANAGER, Action.MANAGE_ACCESS)
    assert not can(Role.CO_MANAGER, Action.EDIT_PROPERTY)
    assert not can(Role.CO_MANAGER, Action.DEACTIVATE_PROPERTY)
