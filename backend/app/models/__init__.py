# Import every model here so Alembic autogenerate discovers them.
from app.models.manager import Manager  # noqa: F401
from app.models.property import Property, PropertyAccess  # noqa: F401
from app.models.unit import Unit, UnitStatus, UnitType  # noqa: F401
