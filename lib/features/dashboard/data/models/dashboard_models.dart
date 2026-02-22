/// Dashboard data models.
library;

import 'package:mockmate/features/dashboard/domain/entities/dashboard_entities.dart';

class SessionHistoryModel extends SessionHistory {
  const SessionHistoryModel({
    required super.id,
    required super.role,
    required super.difficulty,
    required super.score,
    required super.questionCount,
    required super.completedAt,
  });

  factory SessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SessionHistoryModel(
      id: json['id'] as String,
      role: json['role'] as String,
      difficulty: json['difficulty'] as String,
      score: (json['score'] as num).toDouble(),
      questionCount: json['question_count'] as int,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  SessionHistory toEntity() => SessionHistory(
    id: id,
    role: role,
    difficulty: difficulty,
    score: score,
    questionCount: questionCount,
    completedAt: completedAt,
  );
}

class AnalyticsModel extends Analytics {
  const AnalyticsModel({
    required super.totalSessions,
    required super.averageScore,
    required super.bestScore,
    required super.mostPracticedRole,
    required super.weeklyScores,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      totalSessions: json['total_sessions'] as int,
      averageScore: (json['average_score'] as num).toDouble(),
      bestScore: (json['best_score'] as num).toDouble(),
      mostPracticedRole: json['most_practiced_role'] as String,
      weeklyScores: (json['weekly_scores'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  /// Returns mock analytics data for offline/demo scenarios.
  factory AnalyticsModel.mock() {
    return const AnalyticsModel(
      totalSessions: 12,
      averageScore: 74.5,
      bestScore: 92.0,
      mostPracticedRole: 'Flutter Developer',
      weeklyScores: [65, 70, 68, 78, 80, 74, 85],
    );
  }
}
