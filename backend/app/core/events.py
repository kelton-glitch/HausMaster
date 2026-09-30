"""A tiny in-process event bus: the "orchestra" wiring.

Services *announce* facts (`PropertyCreated`, ...) after their transaction has
committed. Other modules *subscribe* (audit log today; notifications and the
rent ledger later) without the publisher knowing they exist. Adding an
instrument = adding a subscriber; no existing service changes.

Handlers are isolated: one failing handler never breaks the request or the
other handlers. Handlers that need the database must open their own session.
"""
import logging
from collections import defaultdict
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, TypeVar

log = logging.getLogger("hausmaster.events")

E = TypeVar("E", bound="DomainEvent")


@dataclass(frozen=True, kw_only=True)
class DomainEvent:
    occurred_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))


class EventBus:
    def __init__(self) -> None:
        self._handlers: dict[type, list[Callable[[Any], None]]] = defaultdict(list)

    def subscribe(self, event_type: type[E], handler: Callable[[E], None]) -> None:
        """Subscribe to an event type. Subscribing to `DomainEvent` receives everything."""
        self._handlers[event_type].append(handler)

    def unsubscribe(self, event_type: type[E], handler: Callable[[E], None]) -> None:
        if handler in self._handlers.get(event_type, ()):
            self._handlers[event_type].remove(handler)

    def on(self, event_type: type[E]) -> Callable[[Callable[[E], None]], Callable[[E], None]]:
        def decorator(handler: Callable[[E], None]) -> Callable[[E], None]:
            self.subscribe(event_type, handler)
            return handler

        return decorator

    def publish(self, event: DomainEvent) -> None:
        for event_type in type(event).__mro__:
            for handler in list(self._handlers.get(event_type, ())):
                try:
                    handler(event)
                except Exception:  # isolate subscribers from each other and the caller
                    log.exception("Event handler %r failed for %s", handler, type(event).__name__)

    def clear(self) -> None:
        self._handlers.clear()


bus = EventBus()
