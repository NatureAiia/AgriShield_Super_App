from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Everything defaults to mock mode — an empty value for a real
    credential is what tells the corresponding service to use its mock
    implementation instead of failing to start."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "sqlite:///./agrishield.db"

    gee_service_account_json: str = ""

    africastalking_username: str = ""
    africastalking_api_key: str = ""

    anthropic_api_key: str = ""
    anthropic_model: str = "claude-3-5-sonnet-20241022"

    # Comma-separated list of browser origins allowed to call the API
    # (the hosted webapp URL in prod). Empty = allow all — fine for a
    # demo, tighten before handling real farmer data.
    cors_origins: str = ""

    @field_validator("database_url")
    @classmethod
    def _normalize_database_url(cls, v: str) -> str:
        # Hosted Postgres (Render/Supabase) hands out postgres:// URLs;
        # SQLAlchemy + pg8000 needs postgresql+pg8000://. Rewrite so the
        # same .env shape works locally and in prod.
        if v.startswith("postgres://"):
            v = "postgresql+pg8000://" + v[len("postgres://"):]
        elif v.startswith("postgresql://"):
            v = "postgresql+pg8000://" + v[len("postgresql://"):]
        # Supabase's dashboard pooler string appends ?pgbouncer=true (meant
        # for other clients): pg8000 has no such connect kwarg, and neither
        # does it take sslmode — TLS comes from database.py's ssl_context.
        # Strip the query string so pasting the dashboard URI just works.
        return v.split("?", 1)[0]

    @property
    def gee_configured(self) -> bool:
        return bool(self.gee_service_account_json)

    @property
    def africastalking_configured(self) -> bool:
        return bool(self.africastalking_username and self.africastalking_api_key)

    @property
    def anthropic_configured(self) -> bool:
        return bool(self.anthropic_api_key)


settings = Settings()
