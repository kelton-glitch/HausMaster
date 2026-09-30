from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal


@dataclass(frozen=True)
class BillResult:
    consumed: Decimal
    subtotal: Decimal
    vat: Decimal
    total: Decimal


def calculate_bill(prev: Decimal, curr: Decimal, rate: Decimal, vat_rate: Decimal) -> BillResult:
    """FR-14. Pure function: no DB, no side effects. vat_rate is a percentage (19.25)."""
    if curr < prev:
        raise ValueError("current reading must be >= previous reading")
    xaf = Decimal("1")  # XAF has no minor unit
    consumed = curr - prev
    subtotal = (consumed * rate).quantize(xaf, ROUND_HALF_UP)
    vat = (subtotal * vat_rate / 100).quantize(xaf, ROUND_HALF_UP)
    return BillResult(consumed, subtotal, vat, subtotal + vat)
