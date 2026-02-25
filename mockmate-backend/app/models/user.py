"""
app/models/user.py

🧠 WHAT THIS IS:
   The User model represents the "users" table in your database.
   Each instance = one row in the table.
   Each class attribute = one column in the table.

🏭 WHY INDUSTRY USES ORM:
   Without ORM, you'd write raw SQL everywhere:
     cursor.execute("INSERT INTO users (id, email) VALUES (?, ?)", [id, email])
   
   With SQLAlchemy ORM, you write Python:
     user = User(email="test@example.com")
     db.add(user)
     db.commit()
   
   This is safer (prevents SQL injection), cleaner, and testable.

📖 WHAT IS A MODEL?
   A Model = a Python class that maps to a database table.
   SQLAlchemy reads your class and creates the SQL table for you.
   
   Think of it as a blueprint: the class = the blueprint, 
   each instance = a building made from that blueprint.
"""

import uuid
from sqlalchemy import Column, String, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.session import Base
from app.models.base_model import TimestampMixin


class User(Base, TimestampMixin):
    """
    Represents the 'users' table.
    
    Columns:
    - id          → UUID primary key (more secure than auto-increment int)
    - email       → unique, used for login
    - name        → display name
    - hashed_password → bcrypt hash, NEVER plain text
    - is_active   → soft-disable accounts without deleting
    - is_verified → email verification (future feature)
    
    Relationships:
    - sessions    → one user has many interview sessions
    """

    __tablename__ = "users"

    # Primary Key: UUID instead of integer
    # Why UUID? Int IDs are guessable (user/1, user/2...).
    # UUIDs are random — attackers can't enumerate your users.
    id = Column(
        String(36),  # SQLite compatible (PostgreSQL would use UUID type)
        primary_key=True,
        default=lambda: str(uuid.uuid4()),
        index=True,
    )

    # Email must be unique — it's the login identifier
    email = Column(String(255), unique=True, nullable=False, index=True)

    # Full name for display
    name = Column(String(255), nullable=False)

    # NEVER store plain passwords. Always store the bcrypt hash.
    hashed_password = Column(String(255), nullable=False)

    # Soft delete / disable pattern: mark inactive instead of deleting
    is_active = Column(Boolean, default=True, nullable=False)

    # Future: email verification flow
    is_verified = Column(Boolean, default=False, nullable=False)

    # ── Relationships ─────────────────────────────────────────────────
    # "One user has many interview sessions"
    # This doesn't create a column — it tells SQLAlchemy how to JOIN the tables
    # back_populates creates the reverse: session.user → gives you the User object
    sessions = relationship(
        "InterviewSession",
        back_populates="user",
        cascade="all, delete-orphan",  # Deleting user deletes their sessions too
    )

    def __repr__(self) -> str:
        return f"<User id={self.id} email={self.email}>"
