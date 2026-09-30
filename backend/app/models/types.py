from enum import Enum

from sqlalchemy import Enum as SAEnum
from sqlalchemy.orm import MappedColumn, mapped_column


def enum_column(enum_cls: type[Enum], length: int = 20, **kwargs) -> MappedColumn:
    """Store a Python enum as VARCHAR of its *values*.

    Avoids native Postgres ENUM types, which are painful to migrate when a
    value is added later.
    """
    return mapped_column(
        SAEnum(
            enum_cls,
            native_enum=False,
            length=length,
            validate_strings=True,
            values_callable=lambda e: [m.value for m in e],
        ),
        **kwargs,
    )
