/// UserModel — the data layer representation of a User.
///
/// WHY USER MODEL vs USER ENTITY?
/// - UserEntity (domain): pure Dart, no JSON knowledge
/// - UserModel (data):    knows how to parse JSON from the API
///
/// This separation means if your API changes (e.g., renames a field),
/// only the Model changes — not the entity or the UI.
library;

import 'package:mockmate/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.createdAt,
    super.totalSessions,
    super.averageScore,
  });

  /// Factory constructor — converts a JSON map from the API into a [UserModel].
  /// 
  /// WHY FACTORY CONSTRUCTOR?
  /// A factory constructor can return an existing instance or perform
  /// complex initialization logic before creating an object.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalSessions: json['total_sessions'] as int? ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts the model back to JSON (for sending to the API).
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'created_at': createdAt.toIso8601String(),
    'total_sessions': totalSessions,
    'average_score': averageScore,
  };

  /// Converts UserModel to the pure domain entity.
  User toEntity() => User(
    id: id,
    name: name,
    email: email,
    createdAt: createdAt,
    totalSessions: totalSessions,
    averageScore: averageScore,
  );
}

/// Wrapper for the login/register API response which includes both
/// the user data and the authentication tokens.
class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}
