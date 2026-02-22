/// Interview Remote Data Source — Groq AI calls for questions and feedback.
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mockmate/core/errors/exceptions.dart';
import 'package:mockmate/features/interview/data/datasources/groq_datasource.dart';
import 'package:mockmate/features/interview/data/models/interview_models.dart';

abstract class InterviewRemoteDataSource {
  Future<List<QuestionModel>> generateQuestions({
    required String role,
    required String difficulty,
    required int count,
  });

  Future<AnswerFeedbackModel> submitAnswer({
    required String question,
    required String answer,
    required String role,
  });
}

class InterviewRemoteDataSourceImpl implements InterviewRemoteDataSource {
  // ignore: unused_field
  final Dio _dio;
  final GroqDataSource _groqDataSource;

  const InterviewRemoteDataSourceImpl({
    required Dio dio,
    required GroqDataSource groqDataSource,
  })  : _dio = dio,
        _groqDataSource = groqDataSource;

  @override
  Future<List<QuestionModel>> generateQuestions({
    required String role,
    required String difficulty,
    required int count,
  }) async {
    try {
      // Call Groq AI to generate questions
      final rawResponse = await _groqDataSource.chat(
        systemPrompt: GroqPrompts.questionGenerationSystem(role, difficulty),
        userMessage: GroqPrompts.questionGenerationUser(role, difficulty, count),
      );

      // Parse the JSON array returned by the AI
      // WHY TRY/CATCH HERE?
      // AI responses can sometimes be slightly malformed. We handle that gracefully.
      dynamic decoded;
      try {
        decoded = jsonDecode(rawResponse);
      } catch (_) {
        // Try to extract JSON from the response if it has extra text
        final jsonStart = rawResponse.indexOf('[');
        final jsonEnd = rawResponse.lastIndexOf(']') + 1;
        if (jsonStart != -1 && jsonEnd > jsonStart) {
          decoded = jsonDecode(rawResponse.substring(jsonStart, jsonEnd));
        } else {
          throw const AIException(message: 'AI returned an unparseable response.');
        }
      }

      final list = (decoded as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList();

      return list;
    } on AIException {
      rethrow;
    } catch (e) {
      throw AIException(message: 'Failed to generate questions: $e');
    }
  }

  @override
  Future<AnswerFeedbackModel> submitAnswer({
    required String question,
    required String answer,
    required String role,
  }) async {
    try {
      final rawResponse = await _groqDataSource.chat(
        systemPrompt: GroqPrompts.feedbackGenerationSystem(role),
        userMessage: GroqPrompts.feedbackGenerationUser(question, answer),
      );

      dynamic decoded;
      try {
        decoded = jsonDecode(rawResponse);
      } catch (_) {
        final jsonStart = rawResponse.indexOf('{');
        final jsonEnd = rawResponse.lastIndexOf('}') + 1;
        if (jsonStart != -1 && jsonEnd > jsonStart) {
          decoded = jsonDecode(rawResponse.substring(jsonStart, jsonEnd));
        } else {
          throw const AIException(message: 'AI returned an unparseable feedback response.');
        }
      }

      return AnswerFeedbackModel.fromJson(decoded as Map<String, dynamic>);
    } on AIException {
      rethrow;
    } catch (e) {
      throw AIException(message: 'Failed to get feedback: $e');
    }
  }
}
