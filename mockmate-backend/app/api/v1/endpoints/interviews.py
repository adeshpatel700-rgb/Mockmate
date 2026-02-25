"""
app/api/v1/endpoints/interviews.py — Interview session endpoints.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.schemas.interview import (
    StartInterviewRequest, SessionResponse,
    SubmitAnswerRequest, SubmitAnswerResponse,
    AnalyticsResponse, SessionHistoryItem,
)
from app.services.interview_service import InterviewService

router = APIRouter(prefix="/interviews", tags=["Interviews"])


@router.post("/start", response_model=SessionResponse, status_code=201)
def start_interview(
    data: StartInterviewRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Start a new interview session.
    Calls Groq AI to generate questions.
    Returns the session with all questions ready.
    """
    return InterviewService(db).start_session(current_user.id, data)


@router.post(
    "/{session_id}/questions/{question_id}/answer",
    response_model=SubmitAnswerResponse,
)
def submit_answer(
    session_id: str,
    question_id: str,
    data: SubmitAnswerRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Submit an answer to a question.
    Calls Groq AI to evaluate the answer.
    Returns feedback + whether session is complete.
    """
    return InterviewService(db).submit_answer(
        session_id=session_id,
        question_id=question_id,
        user_id=current_user.id,
        data=data,
    )


@router.get("/analytics", response_model=AnalyticsResponse)
def get_analytics(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Dashboard analytics: total sessions, avg score, best score, weekly trend."""
    return InterviewService(db).get_analytics(current_user.id)


@router.get("/history", response_model=list[SessionHistoryItem])
def get_history(
    limit: int = 20,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Returns the user's most recent completed sessions."""
    return InterviewService(db).get_history(current_user.id, limit=limit)
