from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql+psycopg://hausmaster:hausmaster@localhost:5432/hausmaster"
    secret_key: str = "dev-only-change-me"
    algorithm: str = "HS256"
    access_token_minutes: int = 15
    refresh_token_days: int = 30


settings = Settings()
