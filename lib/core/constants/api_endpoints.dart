/// API endpoint constants for all network calls.
///
/// WHY SEPARATE FILE?
/// Keeps all URLs in one place. If your backend changes a route,
/// you update it here — not in 20 different files.
library;

class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth Endpoints ────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // ── Interview Endpoints ───────────────────────────────────────────────────
  static const String generateQuestions = '/interview/generate';
  static const String submitAnswer = '/interview/submit';
  static const String getSession = '/interview/session';

  // ── Dashboard Endpoints ───────────────────────────────────────────────────
  static const String history = '/dashboard/history';
  static const String analytics = '/dashboard/analytics';

  // ── Groq API Endpoints ────────────────────────────────────────────────────
  // The Groq API is OpenAI-compatible, so we use the same endpoint format.
  static const String groqChatCompletions = '/chat/completions';
}
