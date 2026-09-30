from app.core.events import EventBus
from app.subscribers import audit


def register_all(bus: EventBus) -> None:
    """The one list of subscribers. Add a module here to add an instrument."""
    audit.register(bus)
