"""
app/services/auth_service.py

🧠 WHAT THIS IS:
   The AuthService contains the BUSINESS LOGIC for authentication.
   
   The service layer is where real work happens:
   - Check if email already exists
   - Hash the password
   - Create the user record
   - Verify credentials on login
   - Generate the JWT token
   
   Services NEVER deal with HTTP (no Request, no Response objects).
   Services NEVER know about endpoints.
   Services talk to the database via the Session object.
   
🏭 WHY INDUSTRY SEPARATES SERVICES FROM ENDPOINTS:
   Your endpoint (api layer) handles: receiving HTTP request, returning HTTP response
   Your service handles: business logic
   
   Benefits:
   1. You can test business logic without HTTP
   2. You can use the same service from multiple endpoints
   3. Logic changes in ONE place, not scattered in 10 endpoint files
"""

from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.models.user import User
from app.schemas.auth import UserRegister, UserLogin, UserResponse, TokenResponse
from app.core.security import hash_password, verify_password, create_access_token

import uuid


class AuthService:
    """
    All authentication business logic.
    Instantiated per-request (stateless — it only takes a DB session).
    """

    def __init__(self, db: Session):
        self.db = db

    def register(self, data: UserRegister) -> TokenResponse:
        """
        Register a new user.
        
        Steps:
        1. Check if email is already taken
        2. Hash the password (NEVER store plain text)
        3. Create User record in database
        4. Generate JWT token
        5. Return token + user info
        
        Raises HTTPException 400 if email already registered.
        """
        # Step 1: Check for duplicate email
        existing = self.db.query(User).filter(User.email == data.email).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="An account with this email already exists.",
            )

        # Step 2: Hash the password BEFORE storing
        hashed = hash_password(data.password)

        # Step 3: Create the User ORM object and save to DB
        user = User(
            id=str(uuid.uuid4()),
            email=data.email,
            name=data.name,
            hashed_password=hashed,
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)  # Refresh loads DB-generated fields (created_at, etc.)

        # Step 4: Generate JWT with user ID as the subject
        token = create_access_token(subject=user.id)

        # Step 5: Return the token + user info
        return TokenResponse(
            access_token=token,
            user=UserResponse.model_validate(user),
        )

    def login(self, data: UserLogin) -> TokenResponse:
        """
        Authenticate an existing user.
        
        Steps:
        1. Find user by email
        2. Verify their password against the stored hash
        3. Check account is active
        4. Generate JWT token
        5. Return token + user info
        
        IMPORTANT SECURITY: We return the SAME error for
        "email not found" and "wrong password". This prevents
        attackers from using your API to discover which emails
        are registered (user enumeration attack).
        """
        # Generic error message — same for both bad email AND bad password
        invalid_credentials_error = HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )

        # Step 1: Find user by email
        user = self.db.query(User).filter(User.email == data.email).first()
        if not user:
            raise invalid_credentials_error

        # Step 2: Verify password against stored hash
        if not verify_password(data.password, user.hashed_password):
            raise invalid_credentials_error

        # Step 3: Check account status
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Your account has been disabled. Please contact support.",
            )

        # Step 4 + 5: Generate token and return
        token = create_access_token(subject=user.id)
        return TokenResponse(
            access_token=token,
            user=UserResponse.model_validate(user),
        )

    def get_user_by_id(self, user_id: str) -> User:
        """
        Fetch a user by their ID.
        Used by the auth dependency to get the current authenticated user.
        
        Raises 404 if user not found.
        """
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found.",
            )
        return user
