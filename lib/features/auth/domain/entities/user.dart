/// User Entity — the core domain object for authenticated users.
///
/// WHY ENTITIES IN DOMAIN LAYER?
/// An entity is a pure Dart class that represents a real-world concept (User).
/// It has NO dependency on Flutter, Dio, or any framework.
/// This makes it reusable, testable, and framework-agnostic.
///
/// WHY EQUATABLE?
/// Equatable automatically generates == comparisons based on [props].
/// Without it, two User objects with the same data would never be equal
/// unless you manually override == and hashCode.
library;

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final int totalSessions;
  final double averageScore;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.totalSessions = 0,
    this.averageScore = 0.0,
  });

  @override
  List<Object?> get props => [id, name, email, createdAt, totalSessions, averageScore];
}
