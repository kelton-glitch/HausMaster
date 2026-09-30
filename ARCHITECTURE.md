# HausMaster architecture: one orchestra, loosely bound instruments

Each feature is self-contained (high cohesion). Features only meet through a few
shared seams (low coupling), so a new feature plugs in without editing old ones.

## The shared score (seams)

| Seam | Backend | Flutter |
|---|---|---|
| **Permissions** | `core/policy.py` (`Role`, `Action`, `can`) + `core/access.py` (`authorize`) | `features/properties/domain/policy.dart` mirrors it to *show/hide* controls |
| **Events** | `core/events.py` bus, facts in `events.py`, listeners in `subscribers/` | `core/events/app_events.dart` bus + `ref.refreshOn<Event>()` |
| **Errors** | `core/errors.py` kinds + stable `code`; one handler `api/errors.py` | `core/network/failure.dart` maps `code` to localized text |
| **Loading UI** | n/a | `core/widgets/async_view.dart` (skeleton / error+retry / empty / pull-to-refresh) |
| **Forms** | Pydantic schemas | `core/widgets/form_sheet.dart` (validation, loading, errors, haptics) |
| **Registry** | `api/v1/router.py` `FEATURE_ROUTERS` | providers + `AsyncView` per screen |

Rules that keep it loose:
- Routers/screens are thin. Business rules live in `services/` (backend) and repositories/providers (Flutter).
- A service announces *what happened* after commit. It never calls another feature.
- Every property-scoped service starts with `authorize(...)`; nothing checks roles itself.
- The server is authoritative. The Flutter policy only decides what to display.
- Features talk to each other by **ids and events**, never by importing each other's internals.

## Add an instrument (recipes)

**A new backend feature (e.g. tenants)**
1. `models/tenant.py` and import it in `models/__init__.py`, then `alembic revision --autogenerate`.
2. `schemas/tenants.py`, `services/tenants.py` (call `authorize(..., Action.X)`; raise errors with a `code`; publish an event).
3. `api/v1/routers/tenants.py` (thin), then add it to `FEATURE_ROUTERS`.
4. New permission? Add an `Action` and list it per `Role` in `policy.py` (and mirror in Flutter).

**React to something without touching the source feature**
- Backend: write `subscribers/notifications.py` that subscribes to e.g. `UnitCreated`; add one line in `subscribers/__init__.py`.
- Flutter: in a provider, `ref.refreshOn<UnitsChanged>(where: ...)`.

**A new Flutter feature**
1. `features/<name>/{domain,data,presentation}`; repository uses `guardApi(...)`.
2. Providers with `FutureProvider`; call `ref.refreshOn<...>()` for the events that affect it.
3. Screens render through `AsyncView`; forms through `FormSheet`; errors through `failureText`.
4. Emit an `AppEvent` after writes so other features can react.
5. Strings go in **both** `lib/l10n/app_fr.arb` and `app_en.arb`, then `flutter gen-l10n`.

## Planned next instruments
Tenants -> Leases (will set `Unit.status`, inside one transaction, then publish `UnitOccupancyChanged`)
-> Rent ledger (APScheduler job subscribes to lease events) -> Payments -> Bills -> Notifications (subscriber).
