from fastapi import APIRouter

from app.api.v1.routers import auth, health, leases, properties, tenants, units

# The one list of features. Adding a feature = adding its router module here.
FEATURE_ROUTERS = [health, auth, properties, units, tenants, leases]

api_router = APIRouter(prefix="/api/v1")
for feature in FEATURE_ROUTERS:
    api_router.include_router(feature.router)
