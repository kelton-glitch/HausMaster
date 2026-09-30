PAYLOAD = {"full_name": "Ada Njoh", "email": "ada@example.com", "password": "password123"}


def _register(client, **over):
    return client.post("/api/v1/auth/register", json={**PAYLOAD, **over})


def _login(client, password="password123", email="ada@example.com"):
    return client.post("/api/v1/auth/login", json={"email": email, "password": password})


def test_register_ok_and_no_password_leak(client):
    r = _register(client)
    assert r.status_code == 201
    assert "password" not in r.text and "password_hash" not in r.text


def test_register_duplicate_email(client):
    _register(client)
    assert _register(client, email="ADA@example.com").status_code == 409


def test_register_short_password(client):
    assert _register(client, password="short").status_code == 422


def test_login_returns_tokens(client):
    _register(client)
    r = _login(client)
    assert r.status_code == 200
    assert {"access_token", "refresh_token"} <= r.json().keys()


def test_login_wrong_password_same_as_unknown_email(client):
    _register(client)
    a = _login(client, password="wrongpass1")
    b = _login(client, email="nobody@example.com")
    assert a.status_code == b.status_code == 401
    assert a.json() == b.json()


def test_refresh_issues_new_pair(client):
    _register(client)
    tokens = _login(client).json()
    r = client.post("/api/v1/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r.status_code == 200


def test_access_token_rejected_as_refresh(client):
    _register(client)
    tokens = _login(client).json()
    r = client.post("/api/v1/auth/refresh", json={"refresh_token": tokens["access_token"]})
    assert r.status_code == 401


def test_me_requires_bearer_and_refresh_token_is_not_access(client):
    _register(client)
    tokens = _login(client).json()
    assert client.get("/api/v1/auth/me").status_code == 401
    bad = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {tokens['refresh_token']}"})
    assert bad.status_code == 401
    ok = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {tokens['access_token']}"})
    assert ok.status_code == 200 and ok.json()["email"] == "ada@example.com"
