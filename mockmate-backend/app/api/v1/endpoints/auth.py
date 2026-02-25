"""
app/api/v1/endpoints/auth.py — Auth endpoints (register + login).
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.auth import UserRegister, UserLogin, TokenResponse, UserResponse
from app.services.auth_service import AuthService
from app.dependencies.auth import get_current_user
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=TokenResponse, status_code=201)
def register(data: UserRegister, db: Session = Depends(get_db)):
    """
    Create a new account.
    Returns JWT access_token + user profile.
    Flutter stores the token in FlutterSecureStorage.
    """
    return AuthService(db).register(data)


@router.post("/login", response_model=TokenResponse)
def login(data: UserLogin, db: Session = Depends(get_db)):
    """
    Authenticate an existing user.
    Returns JWT access_token + user profile.
    """
    return AuthService(db).login(data)


@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    """
    Get the currently authenticated user.
    This is a protected endpoint — requires valid JWT.
    Flutter uses this to verify the stored token is still valid on app start.
    """
    return current_user
