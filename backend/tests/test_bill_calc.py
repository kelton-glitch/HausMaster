from decimal import Decimal as D

import pytest

from app.utils.bill_calc import calculate_bill


def test_calculate_bill():
    r = calculate_bill(D(100), D(150), D(79), D("19.25"))
    assert (r.consumed, r.subtotal, r.vat, r.total) == (D(50), D(3950), D(760), D(4710))


def test_rejects_decreasing_reading():
    with pytest.raises(ValueError):
        calculate_bill(D(10), D(5), D(79), D("19.25"))
