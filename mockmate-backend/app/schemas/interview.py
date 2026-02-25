"""
app/schemas/interview.py

Pydantic schemas for the Interview feature endpoints.
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


# ── Interview Session Schemas ─────────────────────────────────────────────────

class StartInterviewRequest(BaseModel):
    """
    Flutter sends this when user taps "Start Interview".
    POST /api/v1/interviews/start
    """
    role: str = Field(..., min_length=2, max_length=100)
    difficulty: str = Field(..., pattern="^(Easy|Intermediate|Hard)$")
    question_count: int = Field(..., ge=3, le=10)  # Between 3 and 10


class QuestionResponse(BaseModel):
    """A single question as returned by the API."""
    id: str
    question_text: str
    order_index: int
    user_answer: Optional[str] = None

    class Config:
        from_attributes = True


class FeedbackResponse(BaseModel):
    """AI feedback for one question."""
    id: str
    score: int
    overall_feedback: str
    strengths: list[str]
    improvements: list[str]

    class Config:
        from_attributes = True


class SessionResponse(BaseModel):
    """Full session returned to Flutter."""
    id: str
    role: str
    difficulty: str
    question_count: int
    final_score: Optional[float] = None
    is_completed: str
    created_at: datetime
    questions: list[QuestionResponse] = []

    class Config:
        from_attributes = True


# ── Submit Answer Schemas ─────────────────────────────────────────────────────

class SubmitAnswerRequest(BaseModel):
    """
    Flutter sends this when user submits an answer.
    POST /api/v1/interviews/{session_id}/questions/{question_id}/answer
    """
    answer: str = Field(..., min_length=1, max_length=5000)


class SubmitAnswerResponse(BaseModel):
    """Returned after AI evaluates the answer."""
    question_id: str
    feedback: FeedbackResponse
    is_last_question: bool
    session_complete: bool


# ── Analytics Schemas ─────────────────────────────────────────────────────────

class AnalyticsResponse(BaseModel):
    """Dashboard analytics returned to Flutter."""
    total_sessions: int
    average_score: float
    best_score: float
    weekly_scores: list[float]  # 7 values, Mon–Sun


class SessionHistoryItem(BaseModel):
    """One item in the session history list."""
    id: str
    role: str
    difficulty: str
    question_count: int
    score: float
    completed_at: datetime

    class Config:
        from_attributes = True
