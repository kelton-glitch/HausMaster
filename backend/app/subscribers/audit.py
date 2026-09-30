"""First instrument in the orchestra: logs every domain event.

Shows the pattern. A notification sender or ledger generator would be another
module like this, registered in `subscribers/__init__.py`.
"""
import logging
from dataclasses import asdict

from app.core.events import DomainEvent, EventBus

log = logging.getLogger("hausmaster.audit")


def _log_event(event: DomainEvent) -> None:
    data = asdict(event)
    data.pop("occurred_at", None)
    log.info("%s %s at %s", type(event).__name__, data, event.occurred_at.isoformat())


def register(bus: EventBus) -> None:
    bus.subscribe(DomainEvent, _log_event)
