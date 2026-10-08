P = "/api/v1/properties"


def _property(client, headers, name="Résidence Bonanjo"):
    return client.post(P, json={"name": name}, headers=headers).json()["id"]


def _tenant(client, headers, pid, phone="691234567", name="Ada Njoh", **extra):
    r = client.post(
        f"{P}/{pid}/tenants",
        json={"full_name": name, "phone": phone, **extra},
        headers=headers,
    )
    assert r.status_code == 201, r.text
    return r.json()


def test_tenant_crud(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _tenant(client, h, pid, national_id="CMR-1234", email="ada@example.com")
    assert (t["full_name"], t["phone"], t["is_active"]) == ("Ada Njoh", "691234567", True)
    assert t["national_id"] == "CMR-1234"

    r = client.patch(f"{P}/{pid}/tenants/{t['id']}", json={"phone": "699999999"}, headers=h)
    assert r.status_code == 200, r.text
    assert (r.json()["phone"], r.json()["full_name"]) == ("699999999", "Ada Njoh")

    assert len(client.get(f"{P}/{pid}/tenants", headers=h).json()) == 1
    assert client.get(f"{P}/{pid}/tenants/{t['id']}", headers=h).json()["phone"] == "699999999"


def test_only_required_fields_are_needed(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _tenant(client, h, pid)
    assert (t["email"], t["national_id"], t["emergency_contact"]) == (None, None, None)


def test_tenant_validation(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    bad = client.post(
        f"{P}/{pid}/tenants",
        json={"full_name": "  ", "phone": "691234567", "email": "not-an-email"},
        headers=h,
    )
    assert bad.status_code == 422
    assert (
        client.post(f"{P}/{pid}/tenants", json={"phone": "691234567"}, headers=h).status_code == 422
    )


def test_whitespace_only_update_is_rejected(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _tenant(client, h, pid)
    r = client.patch(f"{P}/{pid}/tenants/{t['id']}", json={"full_name": "   "}, headers=h)
    assert r.status_code == 422


def test_blank_optional_field_is_cleared(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _tenant(client, h, pid, national_id="CMR-1234")
    r = client.patch(f"{P}/{pid}/tenants/{t['id']}", json={"national_id": "  "}, headers=h)
    assert r.status_code == 200, r.text
    assert r.json()["national_id"] is None


def test_duplicate_phone_in_same_property(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    _tenant(client, h, pid, phone="691234567")
    r = client.post(
        f"{P}/{pid}/tenants", json={"full_name": "Autre", "phone": "691234567"}, headers=h
    )
    assert (r.status_code, r.json()["code"]) == (409, "tenant_phone_taken")


def test_same_phone_allowed_in_another_property(client, make_manager):
    _, _, h = make_manager()
    p1, p2 = _property(client, h, "P1"), _property(client, h, "P2")
    _tenant(client, h, p1, phone="691234567")
    assert _tenant(client, h, p2, phone="691234567")["phone"] == "691234567"


def test_tenant_can_keep_its_own_phone_on_update(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _tenant(client, h, pid, phone="691234567")
    r = client.patch(
        f"{P}/{pid}/tenants/{t['id']}",
        json={"phone": "691234567", "full_name": "Ada N. Njoh"},
        headers=h,
    )
    assert r.status_code == 200, r.text


def test_deactivated_tenant_leaves_the_list_but_keeps_the_record(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _tenant(client, h, pid)
    r = client.post(f"{P}/{pid}/tenants/{t['id']}/deactivate", headers=h)
    assert (r.status_code, r.json()["is_active"]) == (200, False)

    assert client.get(f"{P}/{pid}/tenants", headers=h).json() == []
    assert len(client.get(f"{P}/{pid}/tenants?include_inactive=true", headers=h).json()) == 1
    # Still readable by id: history must stay resolvable.
    assert client.get(f"{P}/{pid}/tenants/{t['id']}", headers=h).status_code == 200


def test_tenant_from_another_property_is_not_found(client, make_manager):
    _, _, h = make_manager()
    p1, p2 = _property(client, h, "P1"), _property(client, h, "P2")
    t2 = _tenant(client, h, p2)
    for method, url in (
        ("get", f"{P}/{p1}/tenants/{t2['id']}"),
        ("patch", f"{P}/{p1}/tenants/{t2['id']}"),
    ):
        r = getattr(client, method)(
            url, headers=h, **({"json": {"phone": "6"}} if method == "patch" else {})
        )
        assert (r.status_code, r.json()["code"]) == (404, "tenant_not_found")
    r = client.post(f"{P}/{p1}/tenants/{t2['id']}/deactivate", headers=h)
    assert r.status_code == 404


def test_co_manager_can_manage_tenants_but_outsider_sees_nothing(client, make_manager):
    _, _, owner = make_manager()
    _, co_email, co = make_manager()
    _, _, outsider = make_manager()
    pid = _property(client, owner)
    client.post(f"{P}/{pid}/managers", json={"email": co_email}, headers=owner)

    t = _tenant(client, co, pid)  # co-manager: operational access

    assert client.get(f"{P}/{pid}/tenants", headers=outsider).status_code == 404
    r = client.post(
        f"{P}/{pid}/tenants", json={"full_name": "X", "phone": "600000000"}, headers=outsider
    )
    assert r.status_code == 404
    assert client.get(f"{P}/{pid}/tenants/{t['id']}", headers=co).status_code == 200


def test_inactive_property_blocks_tenant_changes(client, make_manager):
    _, _, h = make_manager()
    pid = _property(client, h)
    t = _tenant(client, h, pid)
    client.post(f"{P}/{pid}/deactivate", headers=h)
    for r in (
        client.post(f"{P}/{pid}/tenants", json={"full_name": "X", "phone": "600000000"}, headers=h),
        client.patch(f"{P}/{pid}/tenants/{t['id']}", json={"full_name": "X"}, headers=h),
        client.post(f"{P}/{pid}/tenants/{t['id']}/deactivate", headers=h),
    ):
        assert (r.status_code, r.json()["code"]) == (409, "property_inactive")
    # Read-only stays possible.
    assert client.get(f"{P}/{pid}/tenants", headers=h).status_code == 200


def test_tenant_created_event(client, make_manager, events):
    from app.events import TenantCreated

    _, _, h = make_manager()
    pid = _property(client, h)
    _tenant(client, h, pid)
    assert TenantCreated in {type(e) for e in events}


def test_tenant_deactivated_event(client, make_manager, events):
    from app.events import TenantDeactivated

    _, _, h = make_manager()
    pid = _property(client, h)
    t = _tenant(client, h, pid)
    client.post(f"{P}/{pid}/tenants/{t['id']}/deactivate", headers=h)
    assert TenantDeactivated in {type(e) for e in events}
