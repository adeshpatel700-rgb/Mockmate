"""
app/db/session.py

Database engine, session factory, and get_db dependency.

PostgreSQL-ready configuration with connection pooling.
"""

from sqlalchemy import create_engine, event
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import QueuePool
from typing import Generator

from app.core.config import settings

# ── Engine ───────────────────────────────────────────────────────────────────
# QueuePool (default for non-SQLite) manages a pool of reusable connections.
#
# pool_size=5      → Keep 5 connections open at all times
# max_overflow=10  → Allow up to 10 extra connections under heavy load
# pool_pre_ping=True → Test connections before using (handles DB restarts)
#
# SQLite needs check_same_thread=False (threading quirk).
# PostgreSQL does not need this — it handles threads natively.

is_sqlite = settings.DATABASE_URL.startswith("sqlite")

engine = create_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,  # Prints SQL queries to console in DEBUG mode
    connect_args={"check_same_thread": False} if is_sqlite else {},
    # For PostgreSQL only — connection pool settings:
    **({"pool_size": 5, "max_overflow": 10, "pool_pre_ping": True} if not is_sqlite else {}),
)

# ── Session Factory ───────────────────────────────────────────────────────────
# autocommit=False → We manually call db.commit() — safer, more control
# autoflush=False  → Changes are not sent to DB until we flush() or commit()
SessionLocal = sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=False,
)

# ── Declarative Base ─────────────────────────────────────────────────────────
# All models must inherit from Base for SQLAlchemy to know about them.
# Base.metadata holds the table definitions — used by Alembic for migrations.
Base = declarative_base()


# ── Dependency ────────────────────────────────────────────────────────────────
def get_db() -> Generator[Session, None, None]:
    """
    FastAPI dependency that provides a database session.

    Opens a session at request start, yields it to the endpoint,
    and ALWAYS closes it in the finally block — even if an exception occurs.
    This prevents connection leaks.

    Usage in any endpoint:
        db: Session = Depends(get_db)
    """
    db = SessionLocal()
    try:
        yield db
    except Exception:
        db.rollback()  # Rollback any uncommitted changes on error
        raise
    finally:
        db.close()
