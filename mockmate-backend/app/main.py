"""
app/main.py — Application entry point.

This is where the FastAPI app is created and configured.
Everything comes together here:
  - App metadata (name, version, docs)
  - Middleware (CORS, logging)
  - Router registration
  - Startup events (DB table creation)
  - Health check endpoint
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api.v1.router import api_router
from app.db.session import engine, Base

# Import models so SQLAlchemy discovers them and creates their tables
# These imports must happen BEFORE Base.metadata.create_all()
import app.models.user        # noqa: F401
import app.models.interview   # noqa: F401


# ── Lifespan (startup + shutdown events) ─────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Startup + shutdown lifecycle handler.

    🧠 WHY NO create_all() HERE?
    In development tutorials you often see:
        Base.metadata.create_all(bind=engine)
    
    This creates tables if they don't exist — but it NEVER modifies them.
    Add a new column to your model? create_all() ignores it silently.
    This causes production bugs that are hard to debug.
    
    The CORRECT approach: use Alembic migrations.
    Run `alembic upgrade head` before starting the server.
    Alembic tracks every schema change and applies only the new ones.
    """
    print(f"🚀 Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    print(f"🌍 Environment: {settings.APP_ENV}")
    print(f"🗄️  Database: {settings.DATABASE_URL}")
    print("✅ Server ready — ensure 'alembic upgrade head' has been run")

    yield  # App runs here

    print("🛑 Shutting down...")


# ── Create the FastAPI Application ───────────────────────────────────────────

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="""
## MockMate Backend API

AI-powered interview practice platform.

### Authentication
All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <your_token_here>
```

Get your token from `/api/v1/auth/login` or `/api/v1/auth/register`.

### Endpoints
- **Auth** — Register, login, get current user
- **Interviews** — Start sessions, submit answers, get analytics & history
    """,
    docs_url="/docs",          # Swagger UI at http://localhost:8000/docs
    redoc_url="/redoc",        # ReDoc alternative at http://localhost:8000/redoc
    openapi_url="/openapi.json",
    lifespan=lifespan,
)


# ── CORS Middleware ───────────────────────────────────────────────────────────
# CORS = Cross-Origin Resource Sharing
# Browsers block requests from a different domain unless the server allows it.
# Flutter mobile apps are NOT browsers, so this matters less for mobile.
# But if you ever add a web dashboard, you need CORS configured properly.

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,   # ["*"] in dev, restrict in prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Include API Routes ────────────────────────────────────────────────────────

app.include_router(api_router)


# ── Health Check (no auth required) ──────────────────────────────────────────

@app.get("/health", tags=["System"])
def health_check():
    """
    Simple health check endpoint.
    Used by:
    - Load balancers to check if the server is alive
    - Docker healthcheck in docker-compose
    - Monitoring tools like UptimeRobot
    
    Returns 200 OK if the server is running.
    """
    return {
        "status": "ok",
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "environment": settings.APP_ENV,
    }


@app.get("/", tags=["System"])
def root():
    """API root — redirects developers to docs."""
    return {
        "message": f"Welcome to {settings.APP_NAME}",
        "docs": "/docs",
        "health": "/health",
        "version": settings.APP_VERSION,
    }
