"""initial_schema_users_and_interviews

This migration creates the initial database schema with:
  - users table
  - interview_sessions table
  - interview_questions table
  - question_feedback table

🧠 HOW ALEMBIC MIGRATIONS WORK:
  Every migration file has two functions:
  
  upgrade()   → runs when you apply this migration (going forward)
  downgrade() → runs when you revert this migration (going backward)
  
  This makes every schema change REVERSIBLE.
  
  The "revision" and "down_revision" chain all migrations together:
  None ← ef572e2f6aff ← (next migration) ← (next) ← ...
  
  Alembic tracks which revision is currently applied in a special
  "alembic_version" table it creates in your database.

Revision ID: ef572e2f6aff
Revises: (None — this is the first migration)
Create Date: 2026-02-25
"""

from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

# revision identifiers used by Alembic
revision: str = 'ef572e2f6aff'
down_revision: Union[str, None] = None     # None = first migration, no parent
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """
    CREATE all tables.
    This runs when you execute: alembic upgrade head
    """

    # ── users table ──────────────────────────────────────────────────
    op.create_table(
        'users',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('email', sa.String(255), nullable=False),
        sa.Column('name', sa.String(255), nullable=False),
        sa.Column('hashed_password', sa.String(255), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('is_verified', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    # Create index on email for fast login lookups
    op.create_index('ix_users_email', 'users', ['email'], unique=True)
    op.create_index('ix_users_id', 'users', ['id'])

    # ── interview_sessions table ──────────────────────────────────────
    op.create_table(
        'interview_sessions',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('user_id', sa.String(36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('role', sa.String(100), nullable=False),
        sa.Column('difficulty', sa.String(20), nullable=False),
        sa.Column('question_count', sa.Integer(), nullable=False),
        sa.Column('final_score', sa.Float(), nullable=True),
        sa.Column('is_completed', sa.String(10), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index('ix_interview_sessions_user_id', 'interview_sessions', ['user_id'])

    # ── interview_questions table ─────────────────────────────────────
    op.create_table(
        'interview_questions',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('session_id', sa.String(36), sa.ForeignKey('interview_sessions.id', ondelete='CASCADE'), nullable=False),
        sa.Column('question_text', sa.Text(), nullable=False),
        sa.Column('user_answer', sa.Text(), nullable=True),
        sa.Column('order_index', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index('ix_interview_questions_session_id', 'interview_questions', ['session_id'])

    # ── question_feedback table ───────────────────────────────────────
    op.create_table(
        'question_feedback',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('question_id', sa.String(36), sa.ForeignKey('interview_questions.id', ondelete='CASCADE'), nullable=False),
        sa.Column('score', sa.Integer(), nullable=False),
        sa.Column('overall_feedback', sa.Text(), nullable=False),
        sa.Column('strengths', sa.JSON(), nullable=False),
        sa.Column('improvements', sa.JSON(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index('ix_question_feedback_question_id', 'question_feedback', ['question_id'], unique=True)


def downgrade() -> None:
    """
    DROP all tables in REVERSE order (child tables first, then parent).
    
    🧠 WHY REVERSE ORDER?
    Foreign key constraints prevent dropping a parent table while
    child rows still reference it. Drop children first:
    
    question_feedback → interview_questions → interview_sessions → users
    """
    op.drop_table('question_feedback')
    op.drop_table('interview_questions')
    op.drop_table('interview_sessions')
    op.drop_table('users')
