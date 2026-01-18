import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// AI Service for validating universities/courses and generating descriptions
class AiService {
  static const String _baseUrl = 'http://gametaiko.com.my/ai/';

  // Singleton pattern
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  /// Validate if a university is real
  /// Returns a validation result with isValid flag and details
  Future<AiValidationResult> validateUniversity({
    required String universityName,
    required String shortName,
    required String country,
  }) async {
    try {
      final query = Uri.encodeComponent(
        'Is "$universityName" (also known as "$shortName") a real university in $country? '
        'Answer in JSON format: {"isValid": true/false, "confidence": "high/medium/low", '
        '"reason": "brief explanation", "suggestedName": "correct name if different"}'
      );

      final response = await http.get(
        Uri.parse('$_baseUrl?query=$query'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return _parseValidationResponse(response.body, 'university');
      } else {
        return AiValidationResult(
          isValid: false,
          confidence: 'unknown',
          reason: 'Could not verify university. Please try again.',
        );
      }
    } on SocketException {
      return AiValidationResult(
        isValid: false,
        confidence: 'unknown',
        reason: 'No internet connection. Please check your connection.',
      );
    } catch (e) {
      print('AI validation error: $e');
      return AiValidationResult(
        isValid: false,
        confidence: 'unknown',
        reason: 'Validation service unavailable. Please try again.',
      );
    }
  }

  /// Validate if a course is real and belongs to the university
  Future<AiValidationResult> validateCourse({
    required String courseCode,
    required String courseName,
    required String faculty,
    required String universityName,
  }) async {
    try {
      final query = Uri.encodeComponent(
        'Is "$courseName" (course code: "$courseCode") a real course in the $faculty faculty '
        'at $universityName? Answer in JSON format: {"isValid": true/false, '
        '"confidence": "high/medium/low", "reason": "brief explanation", '
        '"suggestedName": "correct name if different"}'
      );

      final response = await http.get(
        Uri.parse('$_baseUrl?query=$query'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return _parseValidationResponse(response.body, 'course');
      } else {
        return AiValidationResult(
          isValid: false,
          confidence: 'unknown',
          reason: 'Could not verify course. Please try again.',
        );
      }
    } on SocketException {
      return AiValidationResult(
        isValid: false,
        confidence: 'unknown',
        reason: 'No internet connection. Please check your connection.',
      );
    } catch (e) {
      print('AI validation error: $e');
      return AiValidationResult(
        isValid: false,
        confidence: 'unknown',
        reason: 'Validation service unavailable. Please try again.',
      );
    }
  }

  /// Generate a description for a course
  Future<String> generateCourseDescription({
    required String courseCode,
    required String courseName,
    required String faculty,
    required String universityName,
  }) async {
    try {
      final query = Uri.encodeComponent(
        'Generate a brief 2-3 sentence academic description for the course "$courseName" '
        '(code: $courseCode) from the $faculty faculty at $universityName. '
        'Focus on what students learn and the course objectives. Keep it professional and concise.'
      );

      final response = await http.get(
        Uri.parse('$_baseUrl?query=$query'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Clean up the response - remove any markdown or extra formatting
        String description = response.body.trim();

        // Remove common markdown artifacts
        description = description.replaceAll(RegExp(r'^```[\s\S]*?```$', multiLine: true), '');
        description = description.replaceAll(RegExp(r'^\*\*.*?\*\*:?\s*', multiLine: true), '');
        description = description.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');

        // Take first 500 characters max
        if (description.length > 500) {
          description = '${description.substring(0, 497)}...';
        }

        return description.trim();
      } else {
        return '';
      }
    } on SocketException {
      return '';
    } catch (e) {
      print('AI description generation error: $e');
      return '';
    }
  }

  /// Check if review content contains inappropriate language
  /// Returns a moderation result with approval status and details
  Future<ContentModerationResult> moderateReviewContent({
    required String reviewText,
  }) async {
    try {
      final query = Uri.encodeComponent(
        'Analyze this review for inappropriate content (profanity, hate speech, harassment, '
        'personal attacks, or offensive language). Review: "$reviewText". '
        'Answer in JSON format: {"isAppropriate": true/false, "reason": "brief explanation", '
        '"flaggedWords": ["list", "of", "problematic", "words"], "suggestion": "cleaned version if needed"}'
      );

      final response = await http.get(
        Uri.parse('$_baseUrl?query=$query'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return _parseModerationResponse(response.body);
      } else {
        return ContentModerationResult(
          isAppropriate: false,
          reason: 'Could not verify content. Please try again.',
          flaggedWords: [],
        );
      }
    } on SocketException {
      return ContentModerationResult(
        isAppropriate: false,
        reason: 'No internet connection. Please check your connection.',
        flaggedWords: [],
      );
    } catch (e) {
      return ContentModerationResult(
        isAppropriate: false,
        reason: 'Content check unavailable. Please try again.',
        flaggedWords: [],
      );
    }
  }

  /// Parse the AI moderation response
  ContentModerationResult _parseModerationResponse(String responseBody) {
    try {
      // Try to extract JSON from the response
      final jsonStr = _extractJsonObject(responseBody);

      if (jsonStr != null) {
        final jsonData = json.decode(jsonStr);

        List<String> flaggedWords = [];
        if (jsonData['flaggedWords'] != null) {
          flaggedWords = List<String>.from(jsonData['flaggedWords']);
        }

        return ContentModerationResult(
          isAppropriate: jsonData['isAppropriate'] ?? true,
          reason: jsonData['reason'] ?? 'Content reviewed.',
          flaggedWords: flaggedWords,
          suggestion: jsonData['suggestion'],
        );
      }

      // If no JSON found, analyze the text response
      final lowerBody = responseBody.toLowerCase();
      final isAppropriate = !lowerBody.contains('inappropriate') &&
                            !lowerBody.contains('offensive') &&
                            !lowerBody.contains('profanity') &&
                            !lowerBody.contains('not appropriate') &&
                            !lowerBody.contains('contains harsh');

      return ContentModerationResult(
        isAppropriate: isAppropriate,
        reason: isAppropriate
            ? 'Content appears appropriate.'
            : 'Content may contain inappropriate language.',
        flaggedWords: [],
      );
    } catch (e) {
      return ContentModerationResult(
        isAppropriate: false,
        reason: 'Could not parse moderation response. Please try again.',
        flaggedWords: [],
      );
    }
  }

  /// Extract JSON object from response text, handling nested braces
  String? _extractJsonObject(String text) {
    final startIndex = text.indexOf('{');
    if (startIndex == -1) return null;

    int braceCount = 0;
    int endIndex = -1;

    for (int i = startIndex; i < text.length; i++) {
      if (text[i] == '{') {
        braceCount++;
      } else if (text[i] == '}') {
        braceCount--;
        if (braceCount == 0) {
          endIndex = i;
          break;
        }
      }
    }

    if (endIndex == -1) return null;
    return text.substring(startIndex, endIndex + 1);
  }

  /// Parse the AI response into a validation result
  AiValidationResult _parseValidationResponse(String responseBody, String type) {
    try {
      // Try to extract JSON from the response
      final jsonStr = _extractJsonObject(responseBody);

      if (jsonStr != null) {
        final jsonData = json.decode(jsonStr);
        return AiValidationResult(
          isValid: jsonData['isValid'] ?? true,
          confidence: jsonData['confidence'] ?? 'medium',
          reason: jsonData['reason'] ?? 'Validation completed.',
          suggestedName: jsonData['suggestedName'],
        );
      }

      // If no JSON found, analyze the text response
      final lowerBody = responseBody.toLowerCase();
      final isValid = !lowerBody.contains('not a real') &&
                      !lowerBody.contains('does not exist') &&
                      !lowerBody.contains('cannot find') &&
                      !lowerBody.contains('no such');

      return AiValidationResult(
        isValid: isValid,
        confidence: 'medium',
        reason: responseBody.length > 200
            ? '${responseBody.substring(0, 197)}...'
            : responseBody,
      );
    } catch (e) {
      print('Error parsing AI response: $e');
      return AiValidationResult(
        isValid: false,
        confidence: 'unknown',
        reason: 'Could not parse validation response. Please try again.',
      );
    }
  }
}

/// Result of AI validation
class AiValidationResult {
  final bool isValid;
  final String confidence;
  final String reason;
  final String? suggestedName;

  AiValidationResult({
    required this.isValid,
    required this.confidence,
    required this.reason,
    this.suggestedName,
  });

  bool get isHighConfidence => confidence == 'high';
  bool get isMediumConfidence => confidence == 'medium';
  bool get isLowConfidence => confidence == 'low';
}

/// Result of content moderation
class ContentModerationResult {
  final bool isAppropriate;
  final String reason;
  final List<String> flaggedWords;
  final String? suggestion;

  ContentModerationResult({
    required this.isAppropriate,
    required this.reason,
    required this.flaggedWords,
    this.suggestion,
  });

  bool get hasFlaggedWords => flaggedWords.isNotEmpty;
}
