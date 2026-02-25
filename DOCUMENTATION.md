# MockMate — Complete Project Documentation

> **Author:** Adesh Patel  
> **Documented:** February 23, 2026  
> **Repository:** https://github.com/adeshpatel700-rgb/Mockmate  
> **Stack:** Flutter 3 · Dart 3 · Groq AI (Llama 3 70B) · Clean Architecture · BLoC

---

## Table of Contents

1. [Project Vision](#1-project-vision)
2. [Architecture Decision](#2-architecture-decision)
3. [Project Scaffold](#3-project-scaffold)
4. [Core Layer](#4-core-layer)
5. [Auth Feature](#5-auth-feature)
6. [Interview Feature](#6-interview-feature)
7. [Dashboard Feature](#7-dashboard-feature)
8. [Shared Widgets](#8-shared-widgets)
9. [Dependency Injection](#9-dependency-injection)
10. [Routing](#10-routing)
11. [Theme System](#11-theme-system)
12. [Groq AI Integration](#12-groq-ai-integration)
13. [Analysis & Bug Fixes](#13-analysis--bug-fixes)
14. [App Icon & Splash Screen](#14-app-icon--splash-screen)
15. [Senior UX Audit & Fixes](#15-senior-ux-audit--fixes)
16. [Build & Deployment](#16-build--deployment)
17. [Environment Configuration](#17-environment-configuration)
18. [File Structure Reference](#18-file-structure-reference)
19. [Key Design Decisions](#19-key-design-decisions)

---

## 1. Project Vision

**MockMate** is a production-grade Flutter mobile application that simulates a real technical interview experience powered by AI.

### Core User Journey
```
Launch → Animated Splash → Onboarding → Register/Login
       → Dashboard (stats + history)
       → Role Selection (pick job, difficulty, # questions)
       → Interview Session (AI asks questions, user types answers)
       → AI Feedback per answer (score 0–100, strengths, improvements)
       → Final Results Screen (animated score arc, session summary)
       → Back to Dashboard (history updated)
```

### Goals
- Give developers/candidates a safe, judgment-free space to practice
- Use cutting-edge Groq AI (Llama 3 70B) for near-instant question generation & evaluation
- Build to production quality: clean code, clean architecture, no shortcuts

---

## 2. Architecture Decision

### Why Clean Architecture?

Clean Architecture was chosen because it separates concerns into 3 layers that only depend inward:

```
┌──────────────────────────────┐
│    Presentation Layer        │  ← Widgets, Bloc, Screens
│  (Flutter UI + State Mgmt)   │
├──────────────────────────────┤
│      Domain Layer            │  ← Use Cases, Entities, Repository Interfaces
│    (Pure Dart, no Flutter)   │
├──────────────────────────────┤
│       Data Layer             │  ← Models, Remote DataSources, Repository Impls
│  (API calls, local storage)  │
└──────────────────────────────┘
```

**Benefits realised:**
- The UI never talks to the network directly
- Use cases are testable in pure Dart without Flutter
- Swapping the backend (FastAPI → Firebase, etc.) only requires changing the Data layer
- The Groq AI datasource can be replaced with any other LLM with zero UI changes

### State Management: BLoC

**flutter_bloc** was chosen over Provider/Riverpod/GetX because:
- Explicit event → state machine makes reasoning about complex async flows easy
- `BlocConsumer` cleanly separates UI rebuilds (builder) from side effects (listener: navigation, snackbars)
- Works correctly with GoRouter
- Scales well as features grow

### Navigation: GoRouter

GoRouter was chosen for:
- URL-based routing (deep link ready)
- Built-in `redirect` for auth guards — runs before every navigation
- Named routes prevent typos
- Works with the back stack correctly on Android

---

## 3. Project Scaffold

### Directory Created
```
c:\Users\ADESH\Desktop\newwwww\mockmate\
```

### Initial Setup Commands
```bash
flutter create mockmate --org com.adeshpatel --platforms android
cd mockmate
```

### pubspec.yaml — Final Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.7

  # Navigation
  go_router: ^14.6.3

  # Networking
  dio: ^5.7.0

  # AI & Environment
  flutter_dotenv: ^5.2.1

  # Storage
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.3

  # UI
  google_fonts: ^6.2.1
  gap: ^3.0.1
  fl_chart: ^0.69.0

  # Error Handling
  dartz: ^0.10.1

  # Utils
  intl: ^0.19.0
  uuid: ^4.5.1

dev_dependencies:
  flutter_launcher_icons: ^0.14.3
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### Assets Configured
```yaml
flutter:
  assets:
    - assets/images/
    - assets/animations/
    - assets/icons/
    - .env
```

### Launcher Icon Config
```yaml
flutter_launcher_icons:
  android: true
  image_path: "assets/images/logo.png"
  adaptive_icon_background: "#0F0E17"
  adaptive_icon_foreground: "assets/images/logo.png"
```

---

## 4. Core Layer

Location: `lib/core/`

### 4.1 Constants — `app_constants.dart`

Centralises all magic strings and lists:

```dart
class AppConstants {
  static const String accessTokenKey = 'access_token';
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqModel = 'llama3-70b-8192';

  static const List<String> jobRoles = [
    'Flutter Developer', 'Frontend Developer', 'Backend Developer',
    'Full Stack Developer', 'Machine Learning Engineer', 'Data Scientist',
    'DevOps Engineer', 'Product Manager', 'UI/UX Designer',
    'Android Developer', 'iOS Developer', 'QA Engineer',
  ];

  static const List<String> difficultyLevels = ['Easy', 'Intermediate', 'Hard'];
  static const List<int> questionCounts = [3, 5, 7, 10];
}
```

### 4.2 Error Handling — `failures.dart` + `exceptions.dart`

Two-tier error system:
- **Exceptions** — thrown by the Data layer (network, parsing errors)
- **Failures** — returned by the Domain layer as `Left<Failure>` via `dartz`

```dart
// Exceptions (Data layer throws these)
class ServerException extends AppException { ... }
class NetworkException extends AppException { ... }
class AIException extends AppException { ... }

// Failures (Domain layer returns these via Either)
class ServerFailure extends Failure { ... }
class NetworkFailure extends Failure { ... }
class AIFailure extends Failure { ... }
```

**Why two tiers?**  
The Domain layer must not know about network details. Exceptions are implementation details; Failures are domain concepts.

### 4.3 Network — `dio_client.dart`

```dart
// Auth interceptor automatically attaches the JWT token to every request
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
```

### 4.4 Use Case Base Class — `usecase.dart`

```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable { ... }
```

All use cases extend this, making them consistent and testable.

---

## 5. Auth Feature

Location: `lib/features/auth/`

### 5.1 Domain Layer

**User Entity:**
```dart
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? token;
}
```

**Repository Interface:**
```dart
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(String name, String email, String password);
  Future<Either<Failure, void>> logout();
}
```

**Use Cases:**
- `LoginUseCase` — validates & calls repository
- `RegisterUseCase` — same
- `LogoutUseCase` — clears secure storage token

### 5.2 Data Layer

**AuthRemoteDataSource** — calls the FastAPI backend:
```
POST /api/v1/auth/login    → returns JWT token
POST /api/v1/auth/register → creates user + returns JWT
```

**UserModel** — extends `User` entity with `fromJson`/`toJson` for API mapping.

**AuthRepositoryImpl** — wraps datasource, catches `ServerException` → returns `Left(ServerFailure(...))`.

### 5.3 Presentation Layer — AuthBloc

**Events:**
```dart
LoginRequested(email, password)
RegisterRequested(name, email, password)
LogoutRequested()
CheckAuthStatus()
```

**States:**
```dart
AuthInitial → AuthLoading → Authenticated(user)
                          → AuthError(message)
                          → Unauthenticated
```

**Screens built:**

| Screen | Key UX Details |
|--------|---------------|
| `OnboardingScreen` | Brand logo hero, staggered feature pill animations, single CTA |
| `LoginScreen` | BlocConsumer, keyboard-aware scroll, textInputAction chain, haptics |
| `RegisterScreen` | 4-field form, password confirm validation, same UX as Login |

---

## 6. Interview Feature

Location: `lib/features/interview/`

### 6.1 Domain Layer

**Entities:**
```dart
class InterviewQuestion extends Equatable {
  final String id;
  final String question;
  final String? userAnswer;
  final QuestionFeedback? feedback;
}

class QuestionFeedback extends Equatable {
  final int score;           // 0–100
  final String overallFeedback;
  final List<String> strengths;
  final List<String> improvements;
}

class InterviewSession extends Equatable {
  final String id;
  final String role;
  final String difficulty;
  final List<InterviewQuestion> questions;
  final double finalScore;
  final DateTime startedAt;
}
```

**Use Cases:**
- `StartInterviewUseCase` — generates N questions for the selected role/difficulty via Groq
- `SubmitAnswerUseCase` — sends the answer to Groq for evaluation, returns `QuestionFeedback`
- `GetSessionHistoryUseCase` — fetches past sessions from backend

### 6.2 Data Layer — Groq AI Integration

**`interview_remote_datasource.dart`** makes two types of AI calls:

**Question Generation Prompt:**
```
You are an expert technical interviewer for [role] positions.
Generate [count] interview questions for [difficulty] level.
Return ONLY valid JSON: {"questions": ["q1", "q2", ...]}
```

**Answer Evaluation Prompt:**
```
You are an expert technical interviewer evaluating an answer.
Question: [question]
Answer: [user_answer]

Evaluate and return ONLY valid JSON:
{
  "score": 0-100,
  "overall_feedback": "...",
  "strengths": ["...", "..."],
  "improvements": ["...", "..."]
}
```

**Groq API call:**
```dart
final response = await _groqDio.post('/chat/completions', data: {
  'model': AppConstants.groqModel,   // llama3-70b-8192
  'messages': [{'role': 'user', 'content': prompt}],
  'temperature': 0.7,
  'max_tokens': 1024,
  'response_format': {'type': 'json_object'},  // Forces valid JSON output
});
```

### 6.3 InterviewBloc — State Machine

```
InterviewInitial
  └─[StartInterview]──► InterviewLoading("Generating questions...")
                              └─[questions ready]──► InterviewInProgress(session, currentIndex, currentQuestion)
                                                           └─[SubmitCurrentAnswer]──► AnswerSubmitting
                                                                                           └─[feedback ready]──► FeedbackReceived(feedback, isLastQuestion)
                                                                                                                       ├─[NextQuestion] (not last)──► InterviewInProgress (next index)
                                                                                                                       └─[NextQuestion] (last)─────► InterviewCompleted(session)
                                                           └─[ResetInterview]──► InterviewInitial
```

### 6.4 Screens

| Screen | Key UX Details |
|--------|---------------|
| `RoleSelectionScreen` | Emoji role chips, colour-coded difficulty (🟢🟡🔴), estimated duration, haptics |
| `InterviewScreen` | Segmented progress bar, role+question# in AppBar, word count, pulsing AI evaluating animation |
| `FeedbackScreen` | Animated score arc (CustomPainter), score count-up animation, staggered content fade |

---

## 7. Dashboard Feature

Location: `lib/features/dashboard/`

### 7.1 Domain — Entities

```dart
class Analytics extends Equatable {
  final int totalSessions;
  final double averageScore;
  final double bestScore;
  final List<double> weeklyScores;  // 7 values (Mon–Sun)
}

class SessionHistory extends Equatable {
  final String id;
  final String role;
  final String difficulty;
  final int questionCount;
  final double score;
  final DateTime completedAt;
}
```

### 7.2 Use Cases
- `GetAnalyticsUseCase` — fetches analytics from backend (falls back to mock data)
- `GetSessionHistoryUseCase` — returns paginated list of past sessions

### 7.3 DashboardBloc States
```
DashboardInitial → DashboardLoading → DashboardLoaded(analytics, history)
                                    → DashboardError(message)
```

**Note:** The dashboard implements a **mock data fallback** — if the FastAPI backend is not running, it generates realistic mock analytics and history so the UI always shows something meaningful.

### 7.4 Dashboard Screen

**Key UI components:**
| Component | Details |
|-----------|---------|
| Pinned AppBar | Logo + "MockMate" + subtitle, logout button |
| 3 Stat Cards | Sessions, Avg Score, Best — each with trend text |
| Weekly Chart | `fl_chart` LineChart, gradient area fill, dot markers, Y-axis labels |
| Recent Sessions | Last 5 sessions, tappable with InkWell ripple |
| FAB | "New Interview" → RoleSelectionScreen |

---

## 8. Shared Widgets

Location: `lib/core/widgets/`

### `AppPrimaryButton`
- Full-width elevated button
- Built-in `isLoading` state (shows spinner, disables tap during loading)
- Optional trailing icon
- Haptic feedback
- Height: 52px, border radius: 12

### `AppOutlinedButton`
- Secondary action button
- Full-width outlined button matching primary style

### `AppTextField`
- Labelled input with prefix icon
- Password variant with show/hide toggle
- Supports: `textInputAction`, `onSubmitted`, `focusNode` for keyboard tab-chain
- Validation via `validator` param

### `AppLoader`
- Centered loading spinner
- Optional `message` text below spinner

### `AppErrorWidget`
- Error icon + message + Retry button
- Used consistently across all screens for error states

### `AppSnackBar`
- `AppSnackBar.showError(context, message)` static helper
- Floating behaviour, error colour, consistent styling

---

## 9. Dependency Injection

Location: `lib/core/di/injection_container.dart`

Uses **GetIt** as the service locator. All registrations happen in `initDependencies()`:

```dart
// External
sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
sl.registerLazySingleton<Dio>(() => DioClient.createClient(sl()));

// Data Sources
sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
sl.registerLazySingleton<InterviewRemoteDataSource>(() => InterviewRemoteDataSourceImpl());

// Repositories
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
sl.registerLazySingleton<InterviewRepository>(() => InterviewRepositoryImpl(sl()));

// Use Cases
sl.registerLazySingleton(() => LoginUseCase(sl()));
sl.registerLazySingleton(() => StartInterviewUseCase(sl()));
// ... etc

// Blocs (factory = new instance per screen)
sl.registerFactory<AuthBloc>(() => AuthBloc(loginUseCase: sl(), ...));
sl.registerFactory<InterviewBloc>(() => InterviewBloc(startInterview: sl(), ...));
sl.registerFactory<DashboardBloc>(() => DashboardBloc(getAnalytics: sl(), ...));
```

**`registerFactory` vs `registerLazySingleton`:**
- Blocs use `factory` — each screen creates its own Bloc instance, discarded on dispose
- Repositories/DataSources use `lazySingleton` — one shared instance (stateless services)

---

## 10. Routing

Location: `lib/core/router/app_router.dart`

### Route Definitions

```dart
class AppRoutes {
  static const String splash       = '/';
  static const String onboarding   = '/onboarding';
  static const String login        = '/login';
  static const String register     = '/register';
  static const String dashboard    = '/dashboard';
  static const String roleSelection= '/interview/select';
  static const String interview    = '/interview/session';
  static const String feedback     = '/interview/feedback';
  static const String history      = '/dashboard/history';
}
```

### Auth Guard

The `redirect` function runs before **every** navigation:

```dart
redirect: (context, state) async {
  final token = await secureStorage.read(key: AppConstants.accessTokenKey);
  final isLoggedIn = token != null;
  final publicRoutes = [splash, onboarding, login, register];
  final isPublic = publicRoutes.contains(state.matchedLocation);

  if (!isLoggedIn && !isPublic) return AppRoutes.login;    // Protected → login
  if (isLoggedIn && isPublic)  return AppRoutes.dashboard; // Auth screen → dashboard
  return null;  // No redirect
}
```

### Data Passing via `extra`

```dart
// Sender (RoleSelectionScreen):
context.push(AppRoutes.interview, extra: {
  'role': _selectedRole,
  'difficulty': _selectedDifficulty,
  'questionCount': _questionCount,
});

// Receiver (router):
builder: (context, state) {
  final extra = state.extra as Map<String, dynamic>?;
  return InterviewScreen(
    role: extra?['role'] ?? 'Flutter Developer',
    ...
  );
}
```

---

## 11. Theme System

Location: `lib/core/theme/app_theme.dart`

### Brand Colour Palette

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#6C63FF` | Buttons, active states, links |
| Secondary | `#03DAC6` | Teal accent, highlights |
| Error | `#CF6679` | Validation errors |
| Dark BG | `#0F0E17` | Dark mode scaffold |
| Dark Surface | `#1A1A2E` | Dark mode cards/inputs |
| Light BG | `#F8F9FE` | Light mode scaffold |

### Typography

**Inter font** (Google Fonts) used throughout:

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `displayLarge` | 32 | 800 | Onboarding headline |
| `displayMedium` | 26 | 700 | Screen headers |
| `titleLarge` | 20 | 600 | Section headers |
| `titleMedium` | 16 | 600 | Card headers |
| `bodyLarge` | 16 | 400 | Body text, question text |
| `bodyMedium` | 14 | 400 | Secondary text |
| `bodySmall` | 12 | 400 | Captions, timestamps |

### Material 3

Both dark and light themes use `useMaterial3: true` with full component theming:
- `AppBarTheme` — transparent, no elevation
- `CardThemeData` — glass-like with subtle border
- `ElevatedButtonThemeData` — brand primary, 12px radius
- `InputDecorationTheme` — filled, border-focus, 16px content padding
- `ChipThemeData` — for role selection badges

---

## 12. Groq AI Integration

### Why Groq?

- **Speed:** Groq's LPU hardware delivers tokens ~10× faster than OpenAI GPT-4
- **Free tier:** No credit card for development
- **Model:** Llama 3 70B — excellent at structured JSON output

### API Key Setup

```env
# .env (never committed to git)
GROQ_API_KEY=gsk_xxxxxxxxxxxxxxxxxxxxxxxxx
GROQ_BASE_URL=https://api.groq.com/openai/v1
```

```dart
// Loaded at app start in main.dart:
await dotenv.load(fileName: '.env');
```

### Prompt Engineering

Two carefully crafted prompts:

**1. Question Generator**
```
You are an expert technical interviewer for [ROLE] positions.
Generate exactly [N] interview questions for a [DIFFICULTY] level candidate.
Focus on practical, real-world scenarios.
Return ONLY valid JSON with this exact structure:
{"questions": ["question 1", "question 2", ...]}
Do not include any text outside the JSON.
```

**2. Answer Evaluator**
```
You are a senior technical interviewer evaluating a candidate's answer.
Be constructive, specific, and fair in your assessment.

Question: [QUESTION]
Candidate's Answer: [ANSWER]

Evaluate and return ONLY valid JSON:
{
  "score": <integer 0-100>,
  "overall_feedback": "<2-3 sentences of constructive feedback>",
  "strengths": ["<specific strength 1>", "<specific strength 2>"],
  "improvements": ["<specific area to improve 1>", "<specific area to improve 2>"]
}
```

### Error Handling for AI

```dart
try {
  final content = response.data['choices'][0]['message']['content'];
  final json = jsonDecode(content);  // May throw if AI returns invalid JSON
  return QuestionFeedbackModel.fromJson(json);
} catch (e) {
  throw AIException('Failed to parse AI response: $e');
}
```

The repository converts `AIException` → `AIFailure` → shown as snackbar to user.

---

## 13. Analysis & Bug Fixes

After the full build, `flutter analyze` was run and all issues resolved:

### Critical Errors Fixed

| Error | File | Fix Applied |
|-------|------|-------------|
| `CardTheme` used instead of `CardThemeData` | `app_theme.dart` | Changed both dark/light themes |
| Undefined class `LogoutUseCase` | `auth_bloc.dart` | Added missing import |

### Warnings Resolved

| Warning | File | Fix |
|---------|------|-----|
| Unused import `exceptions.dart` | `auth_remote_datasource.dart` | Removed import |
| Unused import `exceptions.dart` | `dashboard_remote_datasource.dart` | Removed import |
| Unused import `shimmer` | `dashboard_screen.dart` | Removed import |
| Unused import `flutter_bloc` | `main.dart` | Removed import |
| Untyped field `_router` | `main.dart` | Added `GoRouter` type annotation |
| Unused variable `feedbackText` | `interview_screen.dart` | Removed variable |
| Unnecessary cast | `interview_screen.dart` | Removed cast |
| Unused field `_dio` | `interview_remote_datasource.dart` | Added `// ignore: unused_field` |

**Final analysis result: 0 errors, 0 warnings** ✅

---

## 14. App Icon & Splash Screen

### App Icon

- **Source:** `assets/images/logo.png` (provided by user)
- **Generator:** `flutter_launcher_icons` package
- **Result:** All Android densities generated (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- **Adaptive Icon:** Background `#0F0E17` (matches dark theme), foreground = logo

```bash
dart run flutter_launcher_icons
```

### Animated Splash Screen

Location: `lib/features/splash/presentation/splash_screen.dart`

**"Intelligence Awakening" — 5-stage animation sequence:**

```
  0ms → Background: Deep dark → radial purple bloom (600ms)
300ms → Logo: Scale in with elastic spring (0 → 1.12 → 0.96 → 1.0) + purple glow halo (800ms)
700ms → Neural particles: 8 nodes orbit outward from logo with connecting lines (CustomPainter, 1200ms)
900ms → Wordmark: "MockMate" slides up + shimmer sweep across text (ShaderMask, 900ms)
1100ms→ Tagline: "Ace Every Interview" types character-by-character (45ms/char)
2600ms→ Entire screen elegantly fades out (500ms)
3000ms→ Navigate → Dashboard (if token) or Onboarding (if fresh)
```

**Technical implementation highlights:**

```dart
// 5 AnimationControllers, each with different duration
_bgController      // 600ms — background bloom
_logoController    // 800ms — elastic logo scale + glow
_particleController // 1200ms — neural network nodes
_textController    // 900ms — wordmark shimmer + tagline
_exitController    // 500ms — full screen fade out

// Neural particle network (CustomPainter)
class _NeuralParticlePainter extends CustomPainter {
  // 8 nodes at different angles/radii
  // 10 edges connecting them
  // Glow effect via MaskFilter.blur
  // Teal accent on every 3rd node
}

// Shimmer sweep (ShaderMask)
ShaderMask(
  shaderCallback: (bounds) => LinearGradient(
    stops: [...], // moves shimmer band across text
    colors: [Colors.white, Color(0xFFE8E0FF), Colors.white],
  ).createShader(bounds),
)

// Typewriter
for (int i = 0; i <= _tagline.length; i++) {
  setState(() => _visibleChars = i);
  await Future.delayed(const Duration(milliseconds: 45));
}
```

**Auth check on completion:**
```dart
Future<void> _navigate() async {
  final token = await storage.read(key: AppConstants.accessTokenKey);
  if (token != null) context.go(AppRoutes.dashboard);
  else context.go(AppRoutes.onboarding);
}
```

---

## 15. Senior UX Audit & Fixes

A comprehensive UX audit was performed across all 8 screens. Issues were categorised as Critical, Serious, or Polish.

### Critical Fixes

| # | Screen | Issue | Fix Applied |
|---|--------|-------|-------------|
| C1 | Onboarding | Generic `Icons.psychology_rounded` as hero | Replaced with real `assets/images/logo.png` + elastic scale animation |
| C2 | Interview | AppBar shows `"1 of 5"` — no role context | Now shows role on first line + `"Question N of T"` below |
| C3 | Interview | Plain thin progress bar | Segmented stepped bar (one segment per question, animated fill) |
| C4 | Final Feedback | Static score number | Animated score count-up (0→N) with animated arc (CustomPainter) |
| C5 | Dashboard | `FlexibleSpaceBar` collapse overlaps text | Replaced with pinned `SliverAppBar`, logo + subtitle always readable |
| C6 | Auth screens | `GestureDetector` on inline links (no ripple) | Replaced with `TextButton` (proper ripple, accessibility) |

### Serious Fixes

| # | Screen | Issue | Fix Applied |
|---|--------|-------|-------------|
| S1 | Role Selection | Text-only role chips (slow to scan) | Added emoji per role (`📱`, `🤖`, `☁️`, etc.) |
| S2 | Role Selection | Identical difficulty buttons | Colour-coded: Easy 🟢 green, Medium 🟡 amber, Hard 🔴 red |
| S3 | Interview | No answer feedback | Live word count displayed next to "Your Answer" label |
| S4 | Feedback screen | Context lost after interview | Session role, difficulty, question count now preserved and shown |
| S5 | Dashboard | Stat cards with no trend info | Added trend text line under each stat (`↑ Good`, `Personal best`) |
| S6 | History tiles | Tap does nothing (dead UI) | Added `InkWell` with ripple feedback + chevron indicator |
| S7 | All screens | No haptic feedback | `HapticFeedback.lightImpact()` / `.mediumImpact()` / `.selectionClick()` added |
| S8 | AppButton | Dead code branch + icon always leading | Cleaned up dead ternary, "Next →" button uses text arrow |

### Polish Fixes

| # | Screen | Issue | Fix Applied |
|---|--------|-------|-------------|
| P1 | Onboarding | All feature pills appear at once | Staggered slide-in (120ms delay per pill) |
| P2 | Login/Register | Back button via `context.go()` destroys stack | Changed to `context.canPop() ? pop() : go(onboarding)` |
| P3 | Login/Register | Keyboard hides submit button | `keyboardDismissBehavior: onDrag` + `FocusScope.unfocus()` |
| P4 | All forms | No keyboard tab chain | `textInputAction: TextInputAction.next/done` + `onSubmitted` on last field |
| P5 | Interview | "🤖 AI is evaluating..." static text | Replaced with animated pulsing container + breathing dots |
| P6 | Dashboard | Chart Y-axis unreadable | Added left axis with 0/25/50/75/100 labels + subtle grid |
| P7 | All files | `withOpacity()` deprecated | Replaced with `withValues(alpha: x)` everywhere |
| P8 | Role Selection | Duration unknown to user | `~N min` estimated duration shown (2.5 min per question) |

---

## 16. Build & Deployment

### Debug Build
```bash
flutter run
```

### Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
# Size: ~49.7 MB
```

### GitHub Push

```bash
git init
git remote add origin https://github.com/adeshpatel700-rgb/Mockmate.git
git add .
git commit -m "feat: initial release — MockMate v1.0.0"
git push -u origin master
```

**Security:** `.env` (real API key) is in `.gitignore` and was never committed. Only `.env.example` (blank template) is in the repository.

---

## 17. Environment Configuration

### `.env` (local only, gitignored)
```env
GROQ_API_KEY=gsk_your_actual_key_here
GROQ_BASE_URL=https://api.groq.com/openai/v1
API_BASE_URL=http://localhost:8000/api/v1
APP_NAME=MockMate
APP_ENV=development
```

### `.env.example` (committed to repo — safe template)
```env
GROQ_API_KEY=your_groq_api_key_here
GROQ_BASE_URL=https://api.groq.com/openai/v1
API_BASE_URL=http://localhost:8000/api/v1
APP_NAME=MockMate
APP_ENV=development
```

### Setup for new developers
```bash
git clone https://github.com/adeshpatel700-rgb/Mockmate.git
cd Mockmate
cp .env.example .env
# Edit .env with your real Groq key from https://console.groq.com
flutter pub get
flutter run
```

---

## 18. File Structure Reference

```
mockmate/
├── .env                          ← Real secrets (gitignored)
├── .env.example                  ← Safe template (committed)
├── .gitignore
├── pubspec.yaml
├── README.md
├── DOCUMENTATION.md              ← This file
│
├── assets/
│   ├── images/
│   │   └── logo.png             ← Brand logo (app icon + onboarding hero)
│   ├── animations/              ← (reserved for future Lottie files)
│   └── icons/                   ← (reserved for custom SVG icons)
│
├── android/
│   └── app/src/main/res/        ← Generated launcher icons (all densities)
│
└── lib/
    ├── main.dart                 ← App entry: DI init, dotenv, orientation lock, theme
    │
    ├── core/
    │   ├── constants/
    │   │   └── app_constants.dart
    │   ├── di/
    │   │   └── injection_container.dart
    │   ├── errors/
    │   │   ├── exceptions.dart
    │   │   └── failures.dart
    │   ├── network/
    │   │   └── dio_client.dart
    │   ├── router/
    │   │   └── app_router.dart
    │   ├── theme/
    │   │   └── app_theme.dart
    │   ├── usecases/
    │   │   └── usecase.dart
    │   └── widgets/
    │       ├── app_button.dart
    │       ├── app_loader.dart
    │       ├── app_snackbar.dart
    │       └── app_text_field.dart
    │
    └── features/
        ├── splash/
        │   └── presentation/
        │       └── splash_screen.dart       ← 5-stage animated splash
        │
        ├── auth/
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── auth_remote_datasource.dart
        │   │   ├── models/
        │   │   │   └── user_model.dart
        │   │   └── repositories/
        │   │       └── auth_repository_impl.dart
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   └── user.dart
        │   │   ├── repositories/
        │   │   │   └── auth_repository.dart
        │   │   └── usecases/
        │   │       ├── login_usecase.dart
        │   │       ├── register_usecase.dart
        │   │       └── logout_usecase.dart
        │   └── presentation/
        │       ├── bloc/
        │       │   └── auth_bloc.dart
        │       └── screens/
        │           ├── onboarding_screen.dart
        │           ├── login_screen.dart
        │           └── register_screen.dart
        │
        ├── interview/
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── interview_remote_datasource.dart  ← Groq AI calls
        │   │   ├── models/
        │   │   │   └── interview_models.dart
        │   │   └── repositories/
        │   │       └── interview_repository_impl.dart
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   └── interview_entities.dart
        │   │   ├── repositories/
        │   │   │   └── interview_repository.dart
        │   │   └── usecases/
        │   │       ├── start_interview_usecase.dart
        │   │       └── submit_answer_usecase.dart
        │   └── presentation/
        │       ├── bloc/
        │       │   └── interview_bloc.dart
        │       └── screens/
        │           ├── role_selection_screen.dart
        │           ├── interview_screen.dart
        │           └── feedback_screen.dart
        │
        └── dashboard/
            ├── data/
            │   ├── datasources/
            │   │   └── dashboard_remote_datasource.dart
            │   ├── models/
            │   │   └── dashboard_models.dart
            │   └── repositories/
            │       └── dashboard_repository_impl.dart
            ├── domain/
            │   ├── entities/
            │   │   └── dashboard_entities.dart
            │   ├── repositories/
            │   │   └── dashboard_repository.dart
            │   └── usecases/
            │       ├── get_analytics_usecase.dart
            │       └── get_session_history_usecase.dart
            └── presentation/
                ├── bloc/
                │   └── dashboard_bloc.dart
                └── screens/
                    ├── dashboard_screen.dart
                    └── history_screen.dart
```

---

## 19. Key Design Decisions

### Decision 1: No Lottie for Animations
**Why:** Adding Lottie would require a separate animation design tool and a binary asset file. Using Flutter's built-in `AnimationController` + `CustomPainter` keeps everything in Dart, compiles smaller, and is fully customisable without external tooling.

### Decision 2: Groq over OpenAI
**Why:** Groq's LPU hardware delivers token generation ~10× faster. For an interview practice app where the user is waiting for AI feedback, latency is critical. Also free tier has no credit card requirement — better for development.

### Decision 3: Mock Data Fallback on Dashboard
**Why:** The backend (FastAPI) is optional. Rather than showing an error screen when no backend is connected, the dashboard populates with realistic-looking mock data. This allows the app to be demoed without any server setup, and the interview feature (which only needs Groq API) works fully.

### Decision 4: JWT in Flutter Secure Storage
**Why:** `SharedPreferences` stores data in plaintext on Android. `flutter_secure_storage` uses Android Keystore / iOS Keychain for hardware-backed encryption. Tokens are sensitive — they must be stored securely.

### Decision 5: `withValues(alpha:)` over `withOpacity()`
**Why:** `Color.withOpacity()` was deprecated in Flutter 3.27. The replacement `Color.withValues(alpha:)` takes a value in the `0.0–1.0` range in the linear colour space rather than the perceptual space, giving more physically accurate colour blending.

### Decision 6: Pinned AppBar vs FlexibleSpaceBar
**Why:** `FlexibleSpaceBar` with a multi-line `Column` as title causes text overlap in the collapsed state because the title widget is scaled and translated during scroll. A simple pinned `SliverAppBar` with `expandedHeight: 0` gives a clean, predictable header that never glitches.

### Decision 7: `registerFactory` for Blocs
**Why:** Using `registerLazySingleton` for Blocs would mean the same Bloc instance is reused across screen navigations. If a user goes Login → Dashboard → back → Login, the Login Bloc would still be in `Authenticated` state. `registerFactory` creates a fresh Bloc per screen, giving clean initial state every time.

---

*End of Documentation — MockMate v1.0.0*
