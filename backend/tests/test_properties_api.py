from app.events import AccessGranted, AccessRevoked, PropertyCreated, PropertyDeactivated

API = "/api/v1/properties"


def _create(client, headers, name="Résidence Bonanjo", **extra):
    r = client.post(API, json={"name": name, **extra}, headers=headers)
    assert r.status_code == 201, r.text
    return r.json()


def test_create_makes_creator_owner_and_publishes_event(client, make_manager, events):
    owner_id, _, h = make_manager()
    p = _create(client, h, city="Douala")
    assert p["role"] == "owner"
    assert p["city"] == "Douala"
    assert (p["unit_count"], p["occupied_count"]) == (0, 0)
    assert [type(e) for e in events] == [PropertyCreated]
    assert events[0].owner_id == owner_id


def test_requires_auth(client):
    assert client.get(API).status_code == 401


def test_validation(client, make_manager):
    _, _, h = make_manager()
    assert client.post(API, json={"name": ""}, headers=h).status_code == 422


def test_list_only_returns_my_properties(client, make_manager):
    _, _, a = make_manager()
    _, _, b = make_manager()
    _create(client, a, name="A1")
    _create(client, b, name="B1")
    names = [p["name"] for p in client.get(API, headers=a).json()]
    assert names == ["A1"]


def test_other_managers_property_is_404_not_403(client, make_manager):
    _, _, a = make_manager()
    _, _, b = make_manager()
    pid = _create(client, a)["id"]
    r = client.get(f"{API}/{pid}", headers=b)
    assert r.status_code == 404
    assert r.json()["code"] == "property_not_found"


def test_update_and_deactivate(client, make_manager, events):
    _, _, h = make_manager()
    pid = _create(client, h)["id"]
    r = client.patch(f"{API}/{pid}", json={"name": "Renamed"}, headers=h)
    assert r.json()["name"] == "Renamed"

    r = client.post(f"{API}/{pid}/deactivate", headers=h)
    assert r.json()["is_active"] is False
    assert PropertyDeactivated in {type(e) for e in events}

    assert client.get(API, headers=h).json() == []
    assert len(client.get(API, params={"include_inactive": True}, headers=h).json()) == 1
    # Inactive properties are read-only.
    r = client.patch(f"{API}/{pid}", json={"name": "x"}, headers=h)
    assert (r.status_code, r.json()["code"]) == (409, "property_inactive")


def test_grant_access_to_co_manager_with_limited_rights(client, make_manager, events):
    _, _, owner = make_manager()
    co_id, co_email, co = make_manager()
    pid = _create(client, owner)["id"]

    r = client.post(f"{API}/{pid}/managers", json={"email": co_email.upper()}, headers=owner)
    assert r.status_code == 201
    assert r.json()["role"] == "co_manager"
    assert AccessGranted in {type(e) for e in events}

    # The co-manager now sees the property, with their own role...
    seen = client.get(f"{API}/{pid}", headers=co).json()
    assert seen["role"] == "co_manager"
    # ...but cannot edit it, deactivate it, or manage access.
    for req in (
        client.patch(f"{API}/{pid}", json={"name": "x"}, headers=co),
        client.post(f"{API}/{pid}/deactivate", headers=co),
        client.post(f"{API}/{pid}/managers", json={"email": "a@b.co"}, headers=co),
    ):
        assert (req.status_code, req.json()["code"]) == (403, "access_denied")


def test_grant_access_errors(client, make_manager):
    _, _, owner = make_manager()
    _, co_email, _ = make_manager()
    pid = _create(client, owner)["id"]
    r = client.post(f"{API}/{pid}/managers", json={"email": "nobody@example.com"}, headers=owner)
    assert (r.status_code, r.json()["code"]) == (404, "manager_not_found")
    client.post(f"{API}/{pid}/managers", json={"email": co_email}, headers=owner)
    r = client.post(f"{API}/{pid}/managers", json={"email": co_email}, headers=owner)
    assert (r.status_code, r.json()["code"]) == (409, "already_has_access")


def test_list_and_revoke_access(client, make_manager, events):
    owner_id, _, owner = make_manager()
    co_id, co_email, co = make_manager()
    pid = _create(client, owner)["id"]
    client.post(f"{API}/{pid}/managers", json={"email": co_email}, headers=owner)

    assert len(client.get(f"{API}/{pid}/managers", headers=owner).json()) == 2
    assert client.delete(f"{API}/{pid}/managers/{co_id}", headers=owner).status_code == 204
    assert AccessRevoked in {type(e) for e in events}
    assert client.get(f"{API}/{pid}", headers=co).status_code == 404  # access gone


def test_cannot_remove_last_owner(client, make_manager):
    owner_id, _, owner = make_manager()
    pid = _create(client, owner)["id"]
    r = client.delete(f"{API}/{pid}/managers/{owner_id}", headers=owner)
    assert (r.status_code, r.json()["code"]) == (409, "last_owner")
