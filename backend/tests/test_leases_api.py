P = "/api/v1/properties"


def _property(client, headers, name="Résidence Bonanjo"):
    return client.post(P, json={"name": name}, headers=headers).json()["id"]


def _type(client, headers, pid, name="Studio", rent=85000):
    r = client.post(
        f"{P}/{pid}/unit-types",
        json={"name": name, "room_count": 1, "base_rent": rent},
        headers=headers,
    )
    assert r.status_code == 201, r.text
    return r.json()


def _unit(client, headers, pid, label="A1"):
    t = _type(client, headers, pid)
    return _unit_of_type(client, headers, pid, t["id"], label)


def _unit_of_type(client, headers, pid, type_id, label="A1"):
    r = client.post(
        f"{P}/{pid}/units", json={"label": label, "unit_type_id": type_id}, headers=headers
    )
    assert r.status_code == 201, r.text
    return r.json()


def _tenant(client, headers, pid, phone="691234567", name="Ada Njoh"):
    r = client.post(f"{P}/{pid}/tenants", json={"full_name": name, "phone": phone}, headers=headers)
    assert r.status_code == 201, r.text
    return r.json()


def _lease(
    client, headers, pid, unit_id, tenant_id, rent=85000, start="2026-01-01", end="2026-12-31"
):
    r = client.post(
        f"{P}/{pid}/leases",
        json={
            "unit_id": unit_id,
            "tenant_id": tenant_id,
            "start_date": start,
            "end_date": end,
            "monthly_rent": rent,
        },
        headers=headers,
    )
    return r


def _status(client, headers, pid, unit_id):
    return client.get(f"{P}/{pid}/units/{unit_id}", headers=headers).json()["status"]


def test_lease_creation_locks_rent_and_occupies_the_unit(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    u, t = _unit(client, h, pid), _tenant(client, h, pid)

    lease = _lease(client, h, pid, u["id"], t["id"], rent=85000).json()
    assert lease["monthly_rent"] == 85000 and isinstance(lease["monthly_rent"], int)
    assert lease["is_active"] is True and lease["terminated_at"] is None
    # Joined for display, so the app draws a row without extra round trips.
    assert (lease["unit_label"], lease["tenant_name"]) == ("A1", "Ada Njoh")
    assert _status(client, h, pid, u["id"]) == "occupied"


def test_lease_dates_must_be_ordered(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    u, t = _unit(client, h, pid), _tenant(client, h, pid)
    r = _lease(client, h, pid, u["id"], t["id"], start="2026-12-31", end="2026-01-01")
    assert r.status_code == 422


def test_lease_rejects_negative_rent_and_missing_dates(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    u, t = _unit(client, h, pid), _tenant(client, h, pid)
    body = {
        "unit_id": u["id"],
        "tenant_id": t["id"],
        "start_date": "2026-01-01",
        "end_date": "2026-12-31",
    }
    assert (
        client.post(f"{P}/{pid}/leases", json={**body, "monthly_rent": -1}, headers=h).status_code
        == 422
    )
    assert client.post(f"{P}/{pid}/leases", json=body, headers=h).status_code == 422


def test_rent_is_locked_there_is_no_update_endpoint(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    u, t = _unit(client, h, pid), _tenant(client, h, pid)
    lease = _lease(client, h, pid, u["id"], t["id"]).json()
    r = client.patch(f"{P}/{pid}/leases/{lease['id']}", json={"monthly_rent": 1}, headers=h)
    assert r.status_code == 405
    assert _lease(client, h, pid, u["id"], t["id"]).status_code == 409  # still the original


def test_a_unit_cannot_hold_two_open_leases(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    u = _unit(client, h, pid)
    t1, t2 = _tenant(client, h, pid, phone="691234567"), _tenant(client, h, pid, phone="699999999")

    assert _lease(client, h, pid, u["id"], t1["id"]).status_code == 201
    r = _lease(client, h, pid, u["id"], t2["id"])
    assert (r.status_code, r.json()["code"]) == (409, "unit_already_leased")
    assert len(client.get(f"{P}/{pid}/leases", headers=h).json()) == 1


def test_same_tenant_may_lease_several_units(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _type(client, h, pid)
    u1 = _unit_of_type(client, h, pid, t["id"], "A1")
    u2 = _unit_of_type(client, h, pid, t["id"], "A2")
    tenant = _tenant(client, h, pid)
    assert _lease(client, h, pid, u1["id"], tenant["id"]).status_code == 201
    assert _lease(client, h, pid, u2["id"], tenant["id"]).status_code == 201


def test_terminate_frees_the_unit_and_keeps_history(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    u, t = _unit(client, h, pid), _tenant(client, h, pid)
    lease = _lease(client, h, pid, u["id"], t["id"]).json()

    r = client.post(f"{P}/{pid}/leases/{lease['id']}/terminate", headers=h)
    assert r.status_code == 200, r.text
    assert r.json()["is_active"] is False and r.json()["terminated_at"] is not None
    # The contractual end date is preserved as signed.
    assert r.json()["end_date"] == lease["end_date"]
    assert _status(client, h, pid, u["id"]) == "vacant"

    assert client.get(f"{P}/{pid}/leases", headers=h).json() == []
    history = client.get(f"{P}/{pid}/leases?include_terminated=true", headers=h).json()
    assert len(history) == 1 and history[0]["monthly_rent"] == 85000


def test_terminate_twice_is_rejected(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    u, t = _unit(client, h, pid), _tenant(client, h, pid)
    lease = _lease(client, h, pid, u["id"], t["id"]).json()
    client.post(f"{P}/{pid}/leases/{lease['id']}/terminate", headers=h)
    r = client.post(f"{P}/{pid}/leases/{lease['id']}/terminate", headers=h)
    assert (r.status_code, r.json()["code"]) == (409, "lease_already_terminated")


def test_renewal_flow_terminate_then_sign_again(client, make_manager):
    """A rent change is a new agreement, not an edit of the old one."""
    _, _, h = make_manager()
    pid = _property(client, h)
    u = _unit(client, h, pid)
    t1, t2 = _tenant(client, h, pid, phone="691234567"), _tenant(client, h, pid, phone="699999999")

    old = _lease(client, h, pid, u["id"], t1["id"], rent=85000).json()
    client.post(f"{P}/{pid}/leases/{old['id']}/terminate", headers=h)
    new = _lease(client, h, pid, u["id"], t2["id"], rent=90000)
    assert new.status_code == 201, new.text

    history = client.get(f"{P}/{pid}/leases?include_terminated=true", headers=h).json()
    assert sorted(x["monthly_rent"] for x in history) == [85000, 90000]
    assert _status(client, h, pid, u["id"]) == "occupied"


def test_unit_and_tenant_from_another_property_are_rejected(client, make_manager):
    _, _, h = make_manager()
    p1, p2 = _property(client, h, "P1"), _property(client, h, "P2")
    u1, u2 = _unit(client, h, p1, "A1"), _unit(client, h, p2, "A1")
    t2 = _tenant(client, h, p2)

    r = _lease(client, h, p1, u1["id"], t2["id"])
    assert (r.status_code, r.json()["code"]) == (404, "tenant_not_found")
    r = _lease(client, h, p1, u2["id"], t2["id"])
    assert (r.status_code, r.json()["code"]) == (404, "unit_not_found")


def test_deactivated_tenant_cannot_sign_a_new_lease(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    u, t = _unit(client, h, pid), _tenant(client, h, pid)
    client.post(f"{P}/{pid}/tenants/{t['id']}/deactivate", headers=h)
    r = _lease(client, h, pid, u["id"], t["id"])
    assert (r.status_code, r.json()["code"]) == (404, "tenant_not_found")
    assert _status(client, h, pid, u["id"]) == "vacant"


def test_a_deactivated_tenant_keeps_an_existing_lease(client, make_manager):
    """Retiring a profile must not silently void money already owed."""
    _, _, h = make_manager()
    pid = _property(client, h)
    u, t = _unit(client, h, pid), _tenant(client, h, pid)
    _lease(client, h, pid, u["id"], t["id"])
    client.post(f"{P}/{pid}/tenants/{t['id']}/deactivate", headers=h)
    assert _status(client, h, pid, u["id"]) == "occupied"
    assert len(client.get(f"{P}/{pid}/leases", headers=h).json()) == 1


def test_failed_lease_writes_nothing(client, make_manager):
    """NFR-05: a rejected lease leaves no partial row behind."""
    _, _, h = make_manager()
    pid = _property(client, h)
    u = _unit(client, h, pid)
    t1, t2 = _tenant(client, h, pid, phone="691234567"), _tenant(client, h, pid, phone="699999999")
    _lease(client, h, pid, u["id"], t1["id"])

    assert _lease(client, h, pid, u["id"], t2["id"], start="2026-13-45").status_code == 422
    assert len(client.get(f"{P}/{pid}/leases?include_terminated=true", headers=h).json()) == 1


def test_property_occupancy_counts_follow_leases(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _type(client, h, pid)
    u1 = _unit_of_type(client, h, pid, t["id"], "A1")
    _unit_of_type(client, h, pid, t["id"], "A2")  # second unit stays vacant
    tenant = _tenant(client, h, pid)
    _lease(client, h, pid, u1["id"], tenant["id"])

    p = client.get(f"{P}/{pid}", headers=h).json()
    assert (p["unit_count"], p["occupied_count"]) == (2, 1)


def test_co_manager_can_manage_leases_but_outsider_sees_nothing(client, make_manager):
    _, _, owner = make_manager()
    _, co_email, co = make_manager()
    _, _, outsider = make_manager()
    pid = _property(client, owner)
    client.post(f"{P}/{pid}/managers", json={"email": co_email}, headers=owner)
    u, t = _unit(client, co, pid), _tenant(client, co, pid)

    lease = _lease(client, co, pid, u["id"], t["id"])
    assert lease.status_code == 201, lease.text
    assert client.get(f"{P}/{pid}/leases", headers=outsider).status_code == 404
    assert _lease(client, outsider, pid, u["id"], t["id"]).status_code == 404
    # ...and an outsider's attempt changed nothing.
    assert len(client.get(f"{P}/{pid}/leases", headers=co).json()) == 1


def test_inactive_property_blocks_lease_changes(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    u, t = _unit(client, h, pid), _tenant(client, h, pid)
    lease = _lease(client, h, pid, u["id"], t["id"]).json()
    client.post(f"{P}/{pid}/deactivate", headers=h)

    r = client.post(f"{P}/{pid}/leases/{lease['id']}/terminate", headers=h)
    assert (r.status_code, r.json()["code"]) == (409, "property_inactive")
    assert _status(client, h, pid, u["id"]) == "occupied"
    assert client.get(f"{P}/{pid}/leases", headers=h).status_code == 200


def test_lease_and_occupancy_events(client, make_manager, events):
    from app.events import LeaseCreated, LeaseTerminated, UnitOccupancyChanged

    _, _, h = make_manager()
    pid = _property(client, h)
    u, t = _unit(client, h, pid), _tenant(client, h, pid)
    lease = _lease(client, h, pid, u["id"], t["id"]).json()
    client.post(f"{P}/{pid}/leases/{lease['id']}/terminate", headers=h)

    kinds = [type(e) for e in events]
    assert LeaseCreated in kinds and LeaseTerminated in kinds
    occupancy = [e for e in events if isinstance(e, UnitOccupancyChanged)]
    assert [e.occupied for e in occupancy] == [True, False]


def test_lease_from_another_property_is_not_found(client, make_manager):
    _, _, h = make_manager()
    p1, p2 = _property(client, h, "P1"), _property(client, h, "P2")
    u, t = _unit(client, h, p1), _tenant(client, h, p1)
    lease = _lease(client, h, p1, u["id"], t["id"]).json()

    assert client.get(f"{P}/{p2}/leases/{lease['id']}", headers=h).status_code == 404
    r = client.post(f"{P}/{p2}/leases/{lease['id']}/terminate", headers=h)
    assert (r.status_code, r.json()["code"]) == (404, "lease_not_found")
    # Still open on the property that owns it.
    assert client.get(f"{P}/{p1}/leases/{lease['id']}", headers=h).json()["is_active"] is True
