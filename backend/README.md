# HausMaster Backend

FastAPI + SQLAlchemy 2.0 + Alembic + PostgreSQL 18.

```
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload     # Swagger UI at /docs
pytest
```

## PostgreSQL 15+ note (R-04)

The `public` schema no longer grants CREATE to all users:

```sql
CREATE USER hausmaster WITH PASSWORD 'hausmaster';
CREATE DATABASE hausmaster OWNER hausmaster;
\c hausmaster
GRANT ALL ON SCHEMA public TO hausmaster;
```

## Layout

`routers/` (HTTP only) -> `services/` (business logic) -> `models/` (SQLAlchemy).
See section 4.3 of the design PDF.
