"""
app/core/config.py

🧠 WHAT THIS IS:
   Pydantic BaseSettings reads environment variables from your .env file
   and validates them automatically. If a required variable is missing,
   the app crashes at startup — not halfway through a request. That's
   the correct behaviour for production.

🏭 WHY INDUSTRY USES THIS PATTERN:
   1. Central single source of truth for all config
   2. Type-safe (PORT is an int, not a string)
   3. Auto-reads from .env without manual os.getenv() everywhere
   4. Easy to override per environment (dev / staging / production)
"""

from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # ── App ────────────────────────────────────────────────────────────
    APP_NAME: str = "MockMate API"
    APP_VERSION: str = "1.0.0"
    APP_ENV: str = "development"
    DEBUG: bool = True

    # ── Server ─────────────────────────────────────────────────────────
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # ── Database (we'll fill this in Phase 2) ──────────────────────────
    DATABASE_URL: str = "sqlite:///./mockmate_dev.db"  # Temp for now

    # ── JWT (we'll fill this in Phase 3) ───────────────────────────────
    SECRET_KEY: str = "change-me-in-production-please"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours

    # ── Groq AI (we'll fill this in Phase 5) ───────────────────────────
    GROQ_API_KEY: str = ""
    GROQ_BASE_URL: str = "https://api.groq.com/openai/v1"
    GROQ_MODEL: str = "llama3-70b-8192"

    # ── CORS ────────────────────────────────────────────────────────────
    # Which domains are allowed to call this API
    # * means everyone — OK for development, restrict in production
    ALLOWED_ORIGINS: list[str] = ["*"]

    class Config:
        # Tell Pydantic where to read env variables from
        env_file = ".env"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    """
    lru_cache means this function is only called ONCE.
    After the first call, it returns the cached Settings object.
    
    This is important — we don't want to re-read the .env file
    on every single API request. That would be slow.
    """
    return Settings()


# Convenient module-level access: from app.core.config import settings
settings = get_settings()
