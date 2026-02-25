"""
app/core/security.py

🧠 WHAT THIS IS:
   All authentication-related utilities live here:
   - Password hashing with bcrypt
   - JWT token creation and verification

   This file is NOT an endpoint. It's a toolkit used by services.

🏭 WHY INDUSTRY USES THIS PATTERN:
   Security primitives should be isolated in one place.
   If a vulnerability is found in your JWT logic, you fix it
   in ONE file, not hunt across 20 files.

📖 CONCEPTS EXPLAINED:

   HASHING vs ENCRYPTION:
   - Encryption: scramble + unscramble (reversible)
   - Hashing: scramble only (NOT reversible)
   
   Passwords are HASHED, never encrypted.
   Why? If your database is stolen, attackers can't reverse-engineer
   the original password. They only get the hash.
   
   bcrypt adds a "salt" (random noise) to each hash, so two users
   with the same password get different hashes. This defeats rainbow
   table attacks.

   JWT (JSON Web Token):
   Structure: header.payload.signature
   
   header  = {"alg": "HS256", "typ": "JWT"} (base64 encoded)
   payload = {"sub": "user_id_123", "exp": 1700000000}  (base64 encoded)
   signature = HMAC_SHA256(header + "." + payload, SECRET_KEY)
   
   The server creates the token and signs it with a SECRET_KEY.
   The client (Flutter app) stores the token and sends it with every request.
   The server verifies the signature — if it's valid, the user is who they claim.
   The server NEVER stores the token. Stateless authentication.
"""

from datetime import datetime, timedelta, timezone
from typing import Any

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

# ── Password Hashing ─────────────────────────────────────────────────────────
# CryptContext manages multiple hashing schemes and handles upgrades
# bcrypt is the industry standard — intentionally slow to prevent brute-force
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(plain_password: str) -> str:
    """
    Takes a plain-text password like "mypassword123"
    Returns a bcrypt hash like "$2b$12$K9KrD.GVeUFhc8VYcR..."
    
    The original password CANNOT be recovered from this hash.
    """
    return pwd_context.hash(plain_password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Checks if a plain password matches a stored hash.
    Returns True or False.
    
    Called during login: does the password the user typed
    match the hash we stored at registration?
    """
    return pwd_context.verify(plain_password, hashed_password)


# ── JWT Token ─────────────────────────────────────────────────────────────────

def create_access_token(subject: str | Any) -> str:
    """
    Creates a signed JWT token.
    
    subject: Usually the user's ID (e.g., "user_uuid_here")
    
    The token payload will look like:
    {
        "sub": "user_uuid_here",
        "exp": 1700086400,          ← Unix timestamp of expiry
        "iat": 1700000000           ← Issued at (when created)
    }
    
    Returns the encoded token string that Flutter will store and send.
    """
    now = datetime.now(timezone.utc)
    expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    payload = {
        "sub": str(subject),   # Subject — who this token belongs to
        "exp": expire,          # Expiration time
        "iat": now,             # Issued at
    }

    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_access_token(token: str) -> dict:
    """
    Decodes and validates a JWT token.
    
    If the token:
    - Has been tampered with → raises JWTError
    - Has expired           → raises JWTError
    - Is malformed          → raises JWTError
    
    If valid, returns the payload dict so we can extract the user ID.
    
    Raises JWTError for any invalid case — callers must handle this.
    """
    payload = jwt.decode(
        token,
        settings.SECRET_KEY,
        algorithms=[settings.ALGORITHM],
    )
    return payload
