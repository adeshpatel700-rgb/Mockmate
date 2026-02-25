"""
app/schemas/auth.py

🧠 WHAT THIS IS:
   Pydantic schemas define the shape of data coming IN and going OUT
   of your API. They are NOT database models.

📖 SCHEMA vs MODEL:
   Model  (SQLAlchemy) = how data is stored in the DATABASE
   Schema (Pydantic)   = how data looks in the API REQUEST/RESPONSE

   Example:
   User model has "hashed_password" column.
   UserResponse schema has no password at all — you NEVER send the hash back.
   
   This separation is critical for security.

🏭 WHY INDUSTRY USES PYDANTIC:
   1. Automatic validation (email format, min/max length, etc.)
   2. Automatic serialization to/from JSON
   3. Self-documenting — FastAPI uses schemas to build /docs
   4. Type safety — catches bugs at schema definition time

📖 PYDANTIC INHERITANCE PATTERN:
   UserBase   → shared fields (email, name)
   UserCreate → UserBase + password (for registration input)
   UserLogin  → email + password only
   UserResponse → UserBase + id (for API output, no password)
   
   This avoids copy-pasting the same fields everywhere.
"""

from pydantic import BaseModel, EmailStr, Field, field_validator
from datetime import datetime


# ── Shared Base ───────────────────────────────────────────────────────────────

class UserBase(BaseModel):
    """Fields shared by all user schemas."""
    email: EmailStr                              # Pydantic validates email format
    name: str = Field(..., min_length=2, max_length=100)


# ── Request Schemas (incoming data) ──────────────────────────────────────────

class UserRegister(UserBase):
    """
    What the Flutter app sends when creating an account.
    POST /api/v1/auth/register
    
    {
        "email": "adesh@example.com",
        "name": "Adesh Patel",
        "password": "securepassword123"
    }
    """
    password: str = Field(..., min_length=8, max_length=100)

    @field_validator("password")
    @classmethod
    def password_must_have_letter(cls, v: str) -> str:
        """Extra validation — password must contain at least one letter."""
        if not any(c.isalpha() for c in v):
            raise ValueError("Password must contain at least one letter")
        return v


class UserLogin(BaseModel):
    """
    What the Flutter app sends when logging in.
    POST /api/v1/auth/login
    
    {
        "email": "adesh@example.com",
        "password": "securepassword123"
    }
    """
    email: EmailStr
    password: str


class ChangePassword(BaseModel):
    """For future password change endpoint."""
    current_password: str
    new_password: str = Field(..., min_length=8)


# ── Response Schemas (outgoing data) ─────────────────────────────────────────

class UserResponse(UserBase):
    """
    What we send BACK to Flutter.
    Notice: NO password field — we never expose it.
    
    {
        "id": "uuid-here",
        "email": "adesh@example.com",
        "name": "Adesh Patel",
        "is_active": true,
        "created_at": "2026-02-23T..."
    }
    """
    id: str
    is_active: bool
    created_at: datetime

    class Config:
        # This allows Pydantic to read from SQLAlchemy model attributes
        # Without this, UserResponse(user_orm_object) would fail
        from_attributes = True


class TokenResponse(BaseModel):
    """
    Returned after successful login or registration.
    Flutter stores the access_token in FlutterSecureStorage.
    
    {
        "access_token": "eyJhbGci...",
        "token_type": "bearer",
        "user": { ...UserResponse... }
    }
    """
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class TokenData(BaseModel):
    """
    Represents the data extracted from a decoded JWT.
    Used internally by the auth dependency.
    """
    user_id: str | None = None
