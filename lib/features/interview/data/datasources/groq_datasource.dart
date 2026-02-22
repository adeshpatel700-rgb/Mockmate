/// Groq AI Data Source — the AI integration core of MockMate.
///
/// WHAT IS THE GROQ API?
/// Groq provides fast inference for LLMs (Large Language Models) like Llama 3.
/// It's OpenAI-compatible, meaning the API format is the same as OpenAI's.
///
/// WHAT IS A REST API?
/// REST = Representational State Transfer. It's a way for apps to talk to servers
/// over HTTP. You send a request (with data), the server processes it and sends back
/// a response (usually JSON). Think of it like ordering food:
/// - Request = your order
/// - Server = the kitchen
/// - Response = your food
///
/// WHAT IS JSON?
/// JSON (JavaScript Object Notation) is a text format for sending structured data.
/// Example: {"name": "Adesh", "role": "Flutter Developer"}
///
/// WHY ASYNC/AWAIT?
/// Network calls take time (thousands of milliseconds). Instead of freezing the
/// entire app while waiting, async/await lets Flutter continue rendering UI
/// while the network request happens in the background.
library;

import 'package:dio/dio.dart';
import 'package:mockmate/core/constants/api_endpoints.dart';
import 'package:mockmate/core/constants/app_constants.dart';
import 'package:mockmate/core/errors/exceptions.dart';
import 'package:mockmate/core/network/dio_client.dart';

abstract class GroqDataSource {
  /// Sends a prompt to the Groq AI and returns the text response.
  Future<String> chat({
    required String systemPrompt,
    required String userMessage,
  });
}

class GroqDataSourceImpl implements GroqDataSource {
  final Dio _dio;
  const GroqDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<String> chat({
    required String systemPrompt,
    required String userMessage,
  }) async {
    try {
      // This is the OpenAI-compatible chat completions format.
      // Groq uses the exact same API structure as OpenAI.
      final response = await _dio.post(
        ApiEndpoints.groqChatCompletions,
        data: {
          'model': AppConstants.groqModel,
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'max_tokens': AppConstants.groqMaxTokens,
          'temperature': AppConstants.groqTemperature,
        },
      );

      // Parse the response — AI reply is nested in choices[0].message.content
      final content = response.data['choices'][0]['message']['content'] as String?;
      if (content == null || content.isEmpty) {
        throw const AIException(message: 'AI returned an empty response.');
      }

      return content.trim();
    } on DioException catch (e) {
      final appEx = handleDioException(e);
      throw AIException(message: appEx.message, statusCode: appEx.statusCode);
    }
  }
}

// ── AI Prompt Builder ─────────────────────────────────────────────────────

/// Utility class for building structured prompts for different AI tasks.
///
/// WHY STRUCTURED PROMPTS?
/// LLMs need clear instructions to produce reliable, parseable output.
/// By defining prompt templates here, the output format is consistent.
class GroqPrompts {
  GroqPrompts._();

  /// System prompt for question generation.
  static String questionGenerationSystem(String role, String difficulty) {
    return '''
You are an expert technical interviewer for $role positions.
Generate exactly 5 interview questions for a $difficulty level candidate.

Requirements:
- Questions must be specific to $role development
- Vary question types: conceptual, practical, scenario-based
- Questions should be clear and answerable in 2-5 minutes each
- Return ONLY a JSON array with this exact format:
[
  {"id": "1", "question": "...", "type": "conceptual", "expectedDuration": 3},
  {"id": "2", "question": "...", "type": "practical", "expectedDuration": 5}
]
Do not include any explanation, only the JSON array.
''';
  }

  /// User message for question generation.
  static String questionGenerationUser(String role, String difficulty, int count) {
    return 'Generate $count $difficulty-level interview questions for: $role';
  }

  /// System prompt for feedback generation.
  static String feedbackGenerationSystem(String role) {
    return '''
You are an expert technical interviewer evaluating answers for $role positions.
Provide detailed, constructive feedback on the candidate's answer.

Return ONLY a JSON object with this exact format:
{
  "score": 75,
  "strengths": ["Clear explanation", "Good use of examples"],
  "improvements": ["Add more detail about X", "Mention Y concept"],
  "idealAnswer": "The ideal answer would include...",
  "overallFeedback": "Good foundational understanding but needs..."
}
Score is 0-100. Be specific, constructive, and encouraging.
''';
  }

  /// User message for feedback generation.
  static String feedbackGenerationUser(String question, String answer) {
    return '''
Question: $question

Candidate's Answer: $answer

Please evaluate this answer and provide feedback.
''';
  }
}
