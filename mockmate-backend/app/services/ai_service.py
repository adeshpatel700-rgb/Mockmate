"""
app/services/ai_service.py

🧠 WHAT THIS IS:
   The AI proxy layer. Instead of Flutter calling Groq directly,
   this service makes the Groq API calls FROM the backend.

📖 WHY BACKEND AI PROXY? (This is a critical architecture concept)

   ❌ BAD (what most beginners do):
      Flutter app → Groq API directly
      
      Problems:
      - Your GROQ_API_KEY is compiled into the app binary
      - Anyone can decompile your APK and steal the key
      - You pay for ALL requests — even from bots/scrapers
      - No rate limiting, no abuse prevention
      - No logging of what prompts are being sent

   ✅ CORRECT (production approach):
      Flutter app → Your Backend → Groq API
      
      Benefits:
      - Key stays on server, never exposed
      - Add rate limiting (10 requests/user/hour)
      - Log and monitor AI usage
      - Validate input BEFORE sending to AI (save tokens)
      - Cache repetitive questions
      - Swap AI providers (Groq → OpenAI) without touching Flutter

🏭 WHY httpx INSTEAD OF requests:
   httpx supports async natively. requests blocks the thread.
   FastAPI is async — blocking calls make it slow under load.
"""

import json
import httpx
from fastapi import HTTPException, status

from app.core.config import settings


class AIService:
    """Handles all communication with the Groq AI API."""

    HEADERS = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {settings.GROQ_API_KEY}",
    }
    ENDPOINT = f"{settings.GROQ_BASE_URL}/chat/completions"

    def _build_payload(self, prompt: str, max_tokens: int = 1024) -> dict:
        """
        Build the standard Groq API request body.
        Centralised here so all calls use consistent settings.
        """
        return {
            "model": settings.GROQ_MODEL,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.7,
            "max_tokens": max_tokens,
            "response_format": {"type": "json_object"},  # Forces valid JSON
        }

    def _extract_json(self, response: httpx.Response, context: str) -> dict:
        """
        Extract and parse JSON from a Groq API response.
        Handles invalid JSON gracefully.
        """
        try:
            response.raise_for_status()  # Raises exception for 4xx / 5xx status
            content = response.json()
            raw_text = content["choices"][0]["message"]["content"]
            return json.loads(raw_text)
        except (json.JSONDecodeError, KeyError) as e:
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"AI returned invalid response during {context}: {str(e)}",
            )
        except httpx.HTTPStatusError as e:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail=f"AI service error: {str(e)}",
            )

    def generate_questions(self, role: str, difficulty: str, count: int) -> list[str]:
        """
        Generate interview questions for a given role and difficulty.
        
        Returns a list of question strings:
        ["What is the widget tree in Flutter?", "Explain async/await...", ...]
        
        Raises HTTPException if:
        - Groq API is down (503)
        - Response is not valid JSON (502)
        - API key is invalid (502)
        """
        prompt = f"""You are an expert technical interviewer for {role} positions.
Generate exactly {count} interview questions for a {difficulty} level candidate.
Focus on practical, real-world scenarios and technical depth appropriate for {difficulty}.

Return ONLY valid JSON with this exact structure:
{{
  "questions": ["question 1 here", "question 2 here", ...]
}}

Do not include any explanation, markdown, or text outside the JSON."""

        with httpx.Client(timeout=30.0) as client:
            response = client.post(
                self.ENDPOINT,
                headers=self.HEADERS,
                json=self._build_payload(prompt, max_tokens=512),
            )

        data = self._extract_json(response, "question generation")
        questions = data.get("questions", [])

        if not questions or len(questions) < count:
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="AI did not return the expected number of questions.",
            )

        return questions[:count]  # Safety: never return more than requested

    def evaluate_answer(
        self, question: str, answer: str, role: str, difficulty: str
    ) -> dict:
        """
        Evaluate a user's answer to an interview question.
        
        Returns a dict matching QuestionFeedback structure:
        {
            "score": 75,
            "overall_feedback": "Good answer but missing...",
            "strengths": ["Clear structure", "Good example used"],
            "improvements": ["Could explain X better"]
        }
        
        Raises HTTPException if AI response is invalid.
        """
        prompt = f"""You are a senior {role} technical interviewer evaluating a candidate's answer.
Candidate level: {difficulty}

Question: {question}

Candidate's Answer: {answer}

Be constructive, specific, and fair. Score based on technical accuracy, clarity, and completeness.

Return ONLY valid JSON with this exact structure:
{{
  "score": <integer 0-100>,
  "overall_feedback": "<2-3 sentences of constructive feedback>",
  "strengths": ["<specific strength 1>", "<specific strength 2>"],
  "improvements": ["<specific area to improve 1>", "<specific area to improve 2>"]
}}"""

        with httpx.Client(timeout=30.0) as client:
            response = client.post(
                self.ENDPOINT,
                headers=self.HEADERS,
                json=self._build_payload(prompt, max_tokens=768),
            )

        data = self._extract_json(response, "answer evaluation")

        # Validate required fields
        required_keys = {"score", "overall_feedback", "strengths", "improvements"}
        if not required_keys.issubset(data.keys()):
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="AI response missing required feedback fields.",
            )

        # Clamp score to valid range
        data["score"] = max(0, min(100, int(data["score"])))
        data["strengths"] = data.get("strengths", [])[:5]      # Max 5 items
        data["improvements"] = data.get("improvements", [])[:5]

        return data
