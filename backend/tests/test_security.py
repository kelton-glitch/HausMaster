import jwt
import pytest

from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)


def test_password_roundtrip():
    h = hash_password("secret123")
    assert verify_password("secret123", h)
    assert not verify_password("wrong", h)


def test_access_token_cannot_be_used_as_refresh():
    with pytest.raises(jwt.InvalidTokenError):
        decode_token(create_access_token("1"), "refresh")
    assert decode_token(create_refresh_token("1"), "refresh") == "1"
