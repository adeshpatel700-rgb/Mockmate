/// Dashboard domain entities.
library;

import 'package:equatable/equatable.dart';

class SessionHistory extends Equatable {
  final String id;
  final String role;
  final String difficulty;
  final double score;
  final int questionCount;
  final DateTime completedAt;

  const SessionHistory({
    required this.id,
    required this.role,
    required this.difficulty,
    required this.score,
    required this.questionCount,
    required this.completedAt,
  });

  @override
  List<Object> get props => [id, role, difficulty, score, questionCount, completedAt];
}

class Analytics extends Equatable {
  final int totalSessions;
  final double averageScore;
  final double bestScore;
  final String mostPracticedRole;
  final List<double> weeklyScores;

  const Analytics({
    required this.totalSessions,
    required this.averageScore,
    required this.bestScore,
    required this.mostPracticedRole,
    required this.weeklyScores,
  });

  @override
  List<Object> get props => [totalSessions, averageScore, bestScore, mostPracticedRole, weeklyScores];
}
