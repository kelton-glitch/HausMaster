import itertools

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

import app.models  # noqa: F401
from app.core.database import Base, get_db
from app.core.events import DomainEvent, bus
from app.main import app


@pytest.fixture
def db_session():
    # In-memory SQLite keeps the suite fast; swap for a Postgres test DB later.
    engine = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
    )
    Base.metadata.create_all(engine)
    with sessionmaker(bind=engine, expire_on_commit=False)() as session:
        yield session


@pytest.fixture
def client(db_session):
    app.dependency_overrides[get_db] = lambda: db_session
    yield TestClient(app)
    app.dependency_overrides.clear()


_counter = itertools.count(1)


@pytest.fixture
def make_manager(client):
    """Registers + logs in a new manager; returns (id, email, auth_headers)."""

    def _make(email: str | None = None):
        email = email or f"manager{next(_counter)}@example.com"
        client.post(
            "/api/v1/auth/register",
            json={"full_name": email.split("@")[0].title(), "email": email, "password": "password123"},
        )
        tokens = client.post(
            "/api/v1/auth/login", json={"email": email, "password": "password123"}
        ).json()
        headers = {"Authorization": f"Bearer {tokens['access_token']}"}
        me = client.get("/api/v1/auth/me", headers=headers).json()
        return me["id"], email, headers

    return _make


@pytest.fixture
def events():
    """Captures every domain event published during a test."""
    captured: list[DomainEvent] = []
    bus.subscribe(DomainEvent, captured.append)
    yield captured
    bus.unsubscribe(DomainEvent, captured.append)
