from fastapi import FastAPI

from app.api.errors import register_error_handlers
from app.api.v1.router import api_router
from app.core.events import bus
from app.subscribers import register_all

app = FastAPI(title="HausMaster API", version="0.1.0")
register_error_handlers(app)
register_all(bus)
app.include_router(api_router)
