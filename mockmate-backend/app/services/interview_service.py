"""
app/services/interview_service.py

Business logic for the interview session lifecycle:
1. Start a session (generate questions via AI)
2. Submit an answer (evaluate via AI, store feedback)
3. Complete the session (calculate final score)
4. Retrieve history
5. Calculate analytics
"""

from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException, status
from datetime import datetime, timezone, timedelta

import uuid

from app.models.user import User
from app.models.interview import InterviewSession, InterviewQuestion, QuestionFeedback
from app.schemas.interview import (
    StartInterviewRequest, SessionResponse,
    SubmitAnswerRequest, SubmitAnswerResponse,
    AnalyticsResponse, SessionHistoryItem,
)
from app.services.ai_service import AIService


class InterviewService:
    """Orchestrates the interview session lifecycle."""

    def __init__(self, db: Session):
        self.db = db
        self.ai = AIService()

    # ── Start Interview ───────────────────────────────────────────────

    def start_session(self, user_id: str, data: StartInterviewRequest) -> SessionResponse:
        """
        1. Create session record
        2. Call AI to generate questions
        3. Store questions in DB
        4. Return session with all questions
        """
        # Create the session
        session = InterviewSession(
            id=str(uuid.uuid4()),
            user_id=user_id,
            role=data.role,
            difficulty=data.difficulty,
            question_count=data.question_count,
        )
        self.db.add(session)
        self.db.flush()  # flush assigns the ID without committing

        # Generate questions via Groq AI
        question_texts = self.ai.generate_questions(
            role=data.role,
            difficulty=data.difficulty,
            count=data.question_count,
        )

        # Store each question
        for idx, text in enumerate(question_texts):
            question = InterviewQuestion(
                id=str(uuid.uuid4()),
                session_id=session.id,
                question_text=text,
                order_index=idx,
            )
            self.db.add(question)

        self.db.commit()
        self.db.refresh(session)
        return SessionResponse.model_validate(session)

    # ── Submit Answer ─────────────────────────────────────────────────

    def submit_answer(
        self,
        session_id: str,
        question_id: str,
        user_id: str,
        data: SubmitAnswerRequest,
    ) -> SubmitAnswerResponse:
        """
        1. Verify session belongs to this user
        2. Save the user's answer
        3. Call AI to evaluate
        4. Store feedback
        5. Check if it's the last question → complete session
        """
        # Verify session ownership (security: users can't submit to other sessions)
        session = self._get_session_for_user(session_id, user_id)

        # Get the question
        question = self.db.query(InterviewQuestion).filter(
            InterviewQuestion.id == question_id,
            InterviewQuestion.session_id == session_id,
        ).first()
        if not question:
            raise HTTPException(status_code=404, detail="Question not found.")

        # Don't allow re-submission
        if question.user_answer:
            raise HTTPException(status_code=400, detail="This question has already been answered.")

        # Save the answer
        question.user_answer = data.answer

        # Get AI feedback
        feedback_data = self.ai.evaluate_answer(
            question=question.question_text,
            answer=data.answer,
            role=session.role,
            difficulty=session.difficulty,
        )

        # Store feedback
        feedback = QuestionFeedback(
            id=str(uuid.uuid4()),
            question_id=question.id,
            score=feedback_data["score"],
            overall_feedback=feedback_data["overall_feedback"],
            strengths=feedback_data["strengths"],
            improvements=feedback_data["improvements"],
        )
        self.db.add(feedback)

        # Check if all questions are answered
        answered_count = self.db.query(InterviewQuestion).filter(
            InterviewQuestion.session_id == session_id,
            InterviewQuestion.user_answer.isnot(None),
        ).count()

        is_last = answered_count >= session.question_count

        # If last question, compute and store final score
        if is_last:
            all_feedback = (
                self.db.query(QuestionFeedback)
                .join(InterviewQuestion)
                .filter(InterviewQuestion.session_id == session_id)
                .all()
            )
            # Add the current feedback to list for calculation
            all_scores = [f.score for f in all_feedback] + [feedback_data["score"]]
            session.final_score = sum(all_scores) / len(all_scores)
            session.is_completed = "true"

        self.db.commit()
        self.db.refresh(feedback)

        from app.schemas.interview import FeedbackResponse
        return SubmitAnswerResponse(
            question_id=question_id,
            feedback=FeedbackResponse.model_validate(feedback),
            is_last_question=is_last,
            session_complete=is_last,
        )

    # ── Analytics ─────────────────────────────────────────────────────

    def get_analytics(self, user_id: str) -> AnalyticsResponse:
        """
        Aggregated stats for the dashboard.
        Uses SQL aggregate functions for efficiency — we don't
        load all sessions into Python memory.
        """
        completed = self.db.query(InterviewSession).filter(
            InterviewSession.user_id == user_id,
            InterviewSession.is_completed == "true",
            InterviewSession.final_score.isnot(None),
        )

        total = completed.count()

        if total == 0:
            return AnalyticsResponse(
                total_sessions=0,
                average_score=0.0,
                best_score=0.0,
                weekly_scores=[0.0] * 7,
            )

        agg = completed.with_entities(
            func.avg(InterviewSession.final_score),
            func.max(InterviewSession.final_score),
        ).first()

        avg_score = round(float(agg[0] or 0), 1)
        best_score = round(float(agg[1] or 0), 1)
        weekly = self._get_weekly_scores(user_id)

        return AnalyticsResponse(
            total_sessions=total,
            average_score=avg_score,
            best_score=best_score,
            weekly_scores=weekly,
        )

    def _get_weekly_scores(self, user_id: str) -> list[float]:
        """Get average scores for each day of the past 7 days."""
        result = []
        today = datetime.now(timezone.utc).date()

        for i in range(6, -1, -1):  # 6 days ago → today
            day = today - timedelta(days=i)
            day_start = datetime(day.year, day.month, day.day, tzinfo=timezone.utc)
            day_end = day_start + timedelta(days=1)

            day_avg = self.db.query(func.avg(InterviewSession.final_score)).filter(
                InterviewSession.user_id == user_id,
                InterviewSession.is_completed == "true",
                InterviewSession.created_at >= day_start,
                InterviewSession.created_at < day_end,
            ).scalar()

            result.append(round(float(day_avg or 0), 1))

        return result

    def get_history(self, user_id: str, limit: int = 20) -> list[SessionHistoryItem]:
        """Return most recent completed sessions."""
        sessions = (
            self.db.query(InterviewSession)
            .filter(
                InterviewSession.user_id == user_id,
                InterviewSession.is_completed == "true",
            )
            .order_by(InterviewSession.created_at.desc())
            .limit(limit)
            .all()
        )

        return [
            SessionHistoryItem(
                id=s.id,
                role=s.role,
                difficulty=s.difficulty,
                question_count=s.question_count,
                score=s.final_score or 0.0,
                completed_at=s.created_at,
            )
            for s in sessions
        ]

    # ── Helpers ───────────────────────────────────────────────────────

    def _get_session_for_user(self, session_id: str, user_id: str) -> InterviewSession:
        """
        Verify a session exists AND belongs to the requesting user.
        This prevents IDOR (Insecure Direct Object Reference) attacks:
        User A cannot access User B's sessions by guessing the session ID.
        """
        session = self.db.query(InterviewSession).filter(
            InterviewSession.id == session_id,
            InterviewSession.user_id == user_id,
        ).first()

        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session not found.",
            )
        return session
