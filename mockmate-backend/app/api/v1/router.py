"""
app/api/v1/router.py — Combines all endpoint routers under /api/v1
"""

from fastapi import APIRouter
from app.api.v1.endpoints import auth, interviews

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(auth.router)
api_router.include_router(interviews.router)
