"""
app/models/base_model.py

🧠 WHAT THIS IS:
   A shared TimestampMixin that every model in our app will use.
   It automatically adds created_at and updated_at to every table.

🏭 WHY INDUSTRY USES THIS:
   Every production table should have timestamps.
   They're critical for:
   - Debugging ("when did this record change?")
   - Analytics ("orders placed this week")
   - Auditing ("who changed what and when?")
   
   A mixin avoids copy-pasting the same columns into every model.
"""

from datetime import datetime, timezone
from sqlalchemy import Column, DateTime
from sqlalchemy.sql import func


class TimestampMixin:
    """
    Add this as a parent class to any SQLAlchemy model to get
    automatic created_at and updated_at columns.
    
    Usage:
        class User(Base, TimestampMixin):
            __tablename__ = "users"
            ...
    """

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),  # DB sets this on INSERT
        nullable=False,
    )

    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),        # DB updates this on every UPDATE
        nullable=False,
    )
