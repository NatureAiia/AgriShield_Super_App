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

    @property
    def gee_configured(self) -> bool:
        return bool(self.gee_service_account_json)

    @property
    def africastalking_configured(self) -> bool:
        return bool(self.africastalking_username and self.africastalking_api_key)


settings = Settings()
