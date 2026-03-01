// ═══════════════════════════════════════════════════════════════════════════════
// 📝 MOCKMATE CONTENT DESIGN SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
//
// Guidelines for writing user-facing content that embodies MockMate's voice:
// Professional, Confident, and Empowering.
//
// This system ensures consistency across all copy, from headlines to error messages,
// maintaining a tone that respects users' career goals while providing clear guidance.
//
// ═══════════════════════════════════════════════════════════════════════════════

/// Voice & Tone Framework for MockMate
class ContentVoice {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CORE PRINCIPLES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// PRIMARY VOICE: Professional, confident, empowering
  /// - We're an expert coach helping professionals succeed
  /// - We speak with authority but remain approachable
  /// - We celebrate wins and provide actionable guidance on improvements

  /// NEVER USE:
  /// - Cutesy or overly casual language ("Hey there!", "Yay!")
  /// - Condescending tone ("You should know this...")
  /// - Vague promises ("You'll probably do great!")
  /// - Technical jargon without context

  /// ALWAYS USE:
  /// - Clear value propositions
  /// - Active voice and action verbs
  /// - Specific metrics and outcomes
  /// - Encouraging but realistic tone

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CONTENT PATTERNS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// HEADLINE FORMULA: [Action] + [Benefit] + [Proof/Trust]
  /// ✅ Good: "Master Interviews with AI" + "Practice any role" + "Join 10,000+ professionals"
  /// ❌ Bad: "Welcome to MockMate!" (no action or value)
  static const String headlineFormula =
      '[Action] + [Benefit] + [Optional: Social Proof]';

  /// CTA BUTTON RULES
  /// ✅ Good:
  /// - Primary: "Start Practicing" (action + outcome)
  /// - Secondary: "See My Progress" (specific value)
  /// ❌ Bad:
  /// - "Click here" (not descriptive)
  /// - "Submit" (generic, no value)
  /// - "OK" (minimal context)
  static const List<String> ctaExamples = [
    'Start Practicing',
    'View My Results',
    'Continue Learning',
    'Explore Sessions',
    'Review Feedback',
  ];

  /// ERROR MESSAGE FRAMEWORK: [What happened] + [Why] + [What to do]
  /// ✅ Good: "Sign in failed. Invalid email or password. Double-check your credentials and try again."
  /// ❌ Bad: "Error 401" (technical, no guidance)
  /// ❌ Bad: "Something went wrong" (vague, no action)
  static String errorPattern(String what, String why, String action) =>
      '$what. $why. $action';

  /// EMPTY STATE FORMULA: [Empathy] + [Action] + [Value]
  /// ✅ Good: "No sessions yet, but you're ready! Start your first interview and track your progress."
  /// ❌ Bad: "Nothing here." (no encouragement or direction)
  static const String emptyStateFormula =
      '[Acknowledge state] + [CTA] + [Value promise]';
}

/// Headline Examples for Key Screens
class HeadlineLibrary {
  // Auth screens
  static const String loginHeadline = 'Welcome Back';
  static const String loginSubheadline =
      'Continue your interview practice journey.';

  static const String registerHeadline = 'Create Your Account';
  static const String registerSubheadline =
      'Start practicing in less than 60 seconds.';

  static const String forgotPasswordHeadline = 'Reset Your Password';
  static const String forgotPasswordSubheadline =
      'Enter your email address and we\'ll send you a link to reset your password.';

  // Onboarding
  static const String onboardingHeadline1 = 'Ace Every Interview with AI';
  static const String onboardingSubheadline1 =
      'Personalized mock interviews that adapt to your target role and skill level.';

  static const String onboardingHeadline2 = 'How MockMate Works';
  static const String onboardingHeadline3 = 'Join Thousands Preparing';

  // Dashboard
  static const String dashboardGreetingMorning = 'Good morning';
  static const String dashboardGreetingAfternoon = 'Good afternoon';
  static const String dashboardGreetingEvening = 'Good evening';

  // Interview
  static const String interviewStarting = 'Preparing Your Interview';
  static const String interviewEvaluating = 'Analyzing Your Response';
  static const String interviewComplete = 'Interview Complete';

  // Results
  static const String resultsOutstanding = 'Outstanding Performance!';
  static const String resultsGood = 'Good Job!';
  static const String resultsKeepPracticing = 'Keep Practicing!';
}

/// CTA Button Copy Library
class CTALibrary {
  // Primary actions
  static const String startPracticing = 'Start Practicing';
  static const String startInterview = 'Start Interview';
  static const String getStarted = 'Get Started Free';
  static const String createAccount = 'Create Account';
  static const String signIn = 'Sign In';

  // Secondary actions
  static const String viewResults = 'View Results';
  static const String viewHistory = 'View History';
  static const String seeProgress = 'See My Progress';
  static const String continueLearning = 'Continue Learning';
  static const String practiceAgain = 'Practice Again';
  static const String goToDashboard = 'Go to Dashboard';

  // Tertiary actions
  static const String learnMore = 'Learn More';
  static const String skip = 'Skip';
  static const String cancel = 'Cancel';
  static const String close = 'Close';

  // Navigation
  static const String backToLogin = 'Back to Sign In';
  static const String alreadyHaveAccount = 'I have an account';
  static const String dontHaveAccount = 'New to MockMate? Create an account';
}

/// Error Messages with Actionable Guidance
class ErrorMessages {
  // Validation errors
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordsMismatch = 'Passwords don\'t match';
  static const String nameRequired = 'Name is required';
  static const String nameTooShort = 'Name must be at least 2 characters';

  // Auth errors with context
  static String authFailed(String reason) =>
      'Sign in failed. $reason. Double-check your credentials and try again.';

  static const String networkError =
      'Connection lost. Check your internet connection and try again.';

  static const String serverError =
      'Our servers are experiencing issues. We\'re working on it. Please try again in a moment.';

  // Interview errors
  static const String answerTooShort =
      'Add more detail — minimum 20 characters required for meaningful feedback.';

  static const String evaluationTimeout =
      'Analysis is taking longer than usual. Your answer is being processed — please wait.';

  static const String sessionLoadFailed =
      'Couldn\'t load your session. Check your connection and try again.';
}

/// Empty State Messages
class EmptyStateMessages {
  static const String noSessions = 'No sessions yet, but you\'re ready!';
  static const String noSessionsCTA =
      'Start your first interview and track your progress.';

  static const String noHistory = 'No practice history yet.';
  static const String noHistoryCTA =
      'Complete an interview to see your results here.';

  static const String noSearchResults = 'No matches found.';
  static const String noSearchResultsCTA =
      'Try adjusting your search or filters.';

  static const String noFavorites = 'No favorites saved yet.';
  static const String noFavoritesCTA =
      'Mark sessions as favorites to find them here.';
}

/// Success Messages
class SuccessMessages {
  static const String accountCreated =
      'Account created! Check your email to verify.';
  static const String passwordResetSent =
      'Password reset link sent to your email.';
  static const String profileUpdated = 'Profile updated successfully.';
  static const String sessionCompleted = 'Interview completed! Great work.';
  static const String feedbackSaved =
      'Your feedback helps us improve. Thank you!';
}

/// Loading State Messages
class LoadingMessages {
  static const String signingIn = 'Signing in...';
  static const String creatingAccount = 'Creating your account...';
  static const String loadingDashboard = 'Loading your dashboard...';
  static const String loadingHistory = 'Loading history...';
  static const String startingInterview = 'Preparing your interview...';
  static const String analyzingAnswer = 'Analyzing your response...';
  static const String generating = 'Generating questions...';
}

/// Question Placeholder and Helper Text
class InputHelpers {
  static const String answerPlaceholder =
      'Share your approach. Explain your reasoning and provide examples.';

  static const String answerHint =
      'Tip: Use specific examples and explain your thought process for better feedback.';

  static const String emailPlaceholder = 'you@example.com';
  static const String namePlaceholder = 'John Doe';
  static const String passwordPlaceholder = '••••••••';

  static const String searchPlaceholder = 'Search by role, score, or date...';
}

/// Accessibility Labels for Screen Readers
class A11yLabels {
  // Navigation
  static const String backButton = 'Go back to previous screen';
  static const String closeButton = 'Close this screen';
  static const String menuButton = 'Open menu';

  // Actions
  static const String startInterviewButton =
      'Double tap to start a new interview';
  static const String submitAnswerButton = 'Double tap to submit your answer';
  static const String viewResultsButton = 'Double tap to view your results';

  // Content
  static const String scoreIndicator = 'Your score out of 100';
  static const String progressIndicator = 'Interview progress';
  static const String difficultyLevel = 'Difficulty level';

  // Images
  static const String logoImage = 'MockMate logo';
  static const String emptyStateIllustration = 'No content illustration';
  static const String successIllustration = 'Success celebration';
}

/// Time and Date Formatting Helpers
class TimeFormatting {
  /// Relative time descriptions
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365)
      return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }

  /// Duration descriptions
  static String durationText(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  /// Estimated time
  static String estimatedTime(int minutes) => 'About $minutes minutes';
}

/// Score and Performance Descriptors
class PerformanceLabels {
  /// Score tier labels
  static String getScoreLabel(int score) {
    if (score >= 90) return 'Outstanding';
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Average';
    return 'Needs Work';
  }

  /// Trend labels
  static String getTrendLabel(double change) {
    if (change > 10) return 'Significant improvement';
    if (change > 5) return 'Improving';
    if (change > 0) return 'Slight improvement';
    if (change == 0) return 'Steady';
    if (change > -5) return 'Slight decline';
    return 'Needs attention';
  }

  /// Difficulty descriptions
  static const String easyDescription =
      'Beginner-friendly · Great for first-timers';
  static const String intermediateDescription =
      'Moderate challenge · Build confidence';
  static const String hardDescription = 'Expert level · Test your limits';
}
