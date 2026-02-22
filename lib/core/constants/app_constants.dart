/// Core application constants used throughout MockMate.
///
/// WHY CONSTANTS CLASS?
/// Instead of hardcoding strings/numbers everywhere (which causes bugs
/// when you need to change them), we keep them in one place.
/// This is the DRY principle — Don't Repeat Yourself.
library;

class AppConstants {
  // Private constructor prevents instantiation — all fields are static.
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'MockMate';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Ace Every Interview';

  // ── Secure Storage Keys ───────────────────────────────────────────────────
  // Keys used when storing/retrieving data from flutter_secure_storage.
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';

  // ── SharedPreferences Keys ────────────────────────────────────────────────
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_seen';

  // ── Groq Model Config ─────────────────────────────────────────────────────
  // llama3-8b-8192 is fast and free on Groq's API.
  static const String groqModel = 'llama3-8b-8192';
  static const int groqMaxTokens = 1024;
  static const double groqTemperature = 0.7;

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 10;

  // ── API Timeouts (milliseconds) ───────────────────────────────────────────
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 30000;

  // ── Job Roles ─────────────────────────────────────────────────────────────
  static const List<String> jobRoles = [
    'Flutter Developer',
    'Backend Developer',
    'DevOps Engineer',
    'Frontend Developer',
    'Data Scientist',
    'Full Stack Developer',
    'Product Manager',
    'System Design',
    'Machine Learning Engineer',
  ];

  // ── Difficulty Levels ─────────────────────────────────────────────────────
  static const List<String> difficultyLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  // ── Number of Questions Per Session ──────────────────────────────────────
  static const List<int> questionCounts = [5, 10, 15];
}
