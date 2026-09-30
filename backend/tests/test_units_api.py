from app.events import UnitCreated

P = "/api/v1/properties"


def _property(client, headers, name="Résidence Bonanjo"):
    return client.post(P, json={"name": name}, headers=headers).json()["id"]


def _type(client, headers, pid, name="Studio", rooms=1, rent=85000):
    r = client.post(
        f"{P}/{pid}/unit-types",
        json={"name": name, "room_count": rooms, "base_rent": rent},
        headers=headers,
    )
    assert r.status_code == 201, r.text
    return r.json()


def _unit(client, headers, pid, type_id, label="A1"):
    r = client.post(
        f"{P}/{pid}/units", json={"label": label, "unit_type_id": type_id}, headers=headers
    )
    assert r.status_code == 201, r.text
    return r.json()


def test_unit_type_crud_and_int_rent(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _type(client, h, pid, rent=85000)
    assert t["base_rent"] == 85000 and isinstance(t["base_rent"], int)

    r = client.patch(f"{P}/{pid}/unit-types/{t['id']}", json={"base_rent": 90000}, headers=h)
    assert r.json()["base_rent"] == 90000
    assert r.json()["name"] == "Studio"  # untouched fields stay


def test_unit_type_validation_and_duplicate_name(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    bad = client.post(
        f"{P}/{pid}/unit-types", json={"name": "x", "room_count": 0, "base_rent": -1}, headers=h
    )
    assert bad.status_code == 422
    _type(client, h, pid, name="Studio")
    r = client.post(
        f"{P}/{pid}/unit-types",
        json={"name": "studio", "room_count": 1, "base_rent": 1},
        headers=h,
    )
    assert (r.status_code, r.json()["code"]) == (409, "unit_type_name_taken")


def test_units_show_type_name_and_start_vacant_and_publish(client, make_manager, events):
    owner_id, _, h = make_manager()
    pid = _property(client, h)
    t = _type(client, h, pid, name="2 pièces", rooms=2)
    u = _unit(client, h, pid, t["id"], label="A1")
    assert (u["status"], u["unit_type_name"]) == ("vacant", "2 pièces")
    assert UnitCreated in {type(e) for e in events}
    assert len(client.get(f"{P}/{pid}/units", headers=h).json()) == 1


def test_duplicate_unit_label(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _type(client, h, pid)
    _unit(client, h, pid, t["id"], label="A1")
    r = client.post(f"{P}/{pid}/units", json={"label": "a1", "unit_type_id": t["id"]}, headers=h)
    assert (r.status_code, r.json()["code"]) == (409, "unit_label_taken")


def test_property_counts_follow_units(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _type(client, h, pid)
    _unit(client, h, pid, t["id"], "A1")
    _unit(client, h, pid, t["id"], "A2")
    p = client.get(f"{P}/{pid}", headers=h).json()
    assert (p["unit_count"], p["occupied_count"]) == (2, 0)


def test_unit_type_from_another_property_is_rejected(client, make_manager):
    _, _, h = make_manager()
    p1, p2 = _property(client, h, "P1"), _property(client, h, "P2")
    t2 = _type(client, h, p2)
    r = client.post(f"{P}/{p1}/units", json={"label": "A1", "unit_type_id": t2["id"]}, headers=h)
    assert (r.status_code, r.json()["code"]) == (404, "unit_type_not_found")


def test_deactivated_type_cannot_get_new_units_but_keeps_existing(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _type(client, h, pid)
    _unit(client, h, pid, t["id"], "A1")
    client.post(f"{P}/{pid}/unit-types/{t['id']}/deactivate", headers=h)
    r = client.post(f"{P}/{pid}/units", json={"label": "A2", "unit_type_id": t["id"]}, headers=h)
    assert r.status_code == 404
    assert len(client.get(f"{P}/{pid}/units", headers=h).json()) == 1
    assert client.get(f"{P}/{pid}/unit-types", headers=h).json() == []


def test_update_unit(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t1 = _type(client, h, pid, name="Studio")
    t2 = _type(client, h, pid, name="2 pièces", rooms=2)
    u = _unit(client, h, pid, t1["id"])
    r = client.patch(
        f"{P}/{pid}/units/{u['id']}", json={"label": "B7", "unit_type_id": t2["id"]}, headers=h
    )
    assert (r.json()["label"], r.json()["unit_type_name"]) == ("B7", "2 pièces")


def test_co_manager_can_manage_units_but_outsider_cannot_even_see(client, make_manager):
    _, _, owner = make_manager()
    _, co_email, co = make_manager()
    _, _, outsider = make_manager()
    pid = _property(client, owner)
    client.post(f"{P}/{pid}/managers", json={"email": co_email}, headers=owner)

    t = _type(client, co, pid)  # co-manager: operational access
    _unit(client, co, pid, t["id"])

    assert client.get(f"{P}/{pid}/units", headers=outsider).status_code == 404
    r = client.post(
        f"{P}/{pid}/unit-types",
        json={"name": "x", "room_count": 1, "base_rent": 1},
        headers=outsider,
    )
    assert r.status_code == 404


def test_inactive_property_blocks_unit_changes(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    client.post(f"{P}/{pid}/deactivate", headers=h)
    r = client.post(
        f"{P}/{pid}/unit-types", json={"name": "x", "room_count": 1, "base_rent": 1}, headers=h
    )
    assert (r.status_code, r.json()["code"]) == (409, "property_inactive")


def test_can_rename_unit_whose_type_was_deactivated(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _type(client, h, pid)
    u = _unit(client, h, pid, t["id"], "A1")
    client.post(f"{P}/{pid}/unit-types/{t['id']}/deactivate", headers=h)
    # Same (now inactive) type id is sent back unchanged: must not be rejected.
    r = client.patch(
        f"{P}/{pid}/units/{u['id']}", json={"label": "A1-bis", "unit_type_id": t["id"]}, headers=h
    )
    assert r.status_code == 200, r.text
    assert r.json()["label"] == "A1-bis"
