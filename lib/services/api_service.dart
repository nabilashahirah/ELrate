import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../models/review.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class ApiService {
  // API Endpoints from constants
  static const String _getCoursesUrl = AppConstants.getCoursesUrl;
  static const String _submitReviewUrl = AppConstants.submitReviewUrl;
  static const String _getReviewsUrl = AppConstants.getReviewsUrl;
  static const String _getHarshWordsUrl = AppConstants.getHarshWordsUrl;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final AuthService _authService = AuthService();

  /// Fetch all courses from the API
  Future<List<Course>> getCourses() async {
    try {
      final response = await http.get(Uri.parse(_getCoursesUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Unable to load courses. Please try again later.');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException {
      throw Exception('Invalid data received. Please try again later.');
    } catch (e) {
      if (e is Exception && e.toString().contains('Exception:')) rethrow;
      throw Exception('Unable to load courses. Please try again later.');
    }
  }

  /// Fetch reviews for a specific course
  Future<List<Review>> getReviews(String courseId, {int? limit, int? offset}) async {
    try {
      final uri = Uri.parse(_getReviewsUrl).replace(queryParameters: {
        'courseId': courseId,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      });
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Unable to load reviews. Please try again later.');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException {
      throw Exception('Invalid data received. Please try again later.');
    } catch (e) {
      if (e is Exception && e.toString().contains('Exception:')) rethrow;
      throw Exception('Unable to load reviews. Please try again later.');
    }
  }

  /// Submit a new review
  Future<void> submitReview(Review review) async {
    try {
      // Get authentication token
      final token = await _authService.getToken();

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http.post(
        Uri.parse(_submitReviewUrl),
        headers: headers,
        body: json.encode(review.toJson()),
      );

      if (response.statusCode == 400) {
        // Backend validation error (e.g., harsh words)
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Invalid review. Please check your input.');
      } else if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Unable to submit review. Please try again later.');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again later.');
    } catch (e) {
      if (e is Exception && e.toString().contains('Exception:')) rethrow;
      throw Exception('Unable to submit review. Please try again later.');
    }
  }

  /// Fetch list of harsh words for content moderation
  Future<List<String>> getHarshWords() async {
    try {
      final response = await http.get(
        Uri.parse(_getHarshWordsUrl),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((e) => e.toString()).toList();
      } else {
        // Return empty list if API fails - backend will still validate
        // This prevents exposing the word list in the app
        return [];
      }
    } catch (e) {
      // Return empty list on error - backend will still validate
      // Security: Do NOT expose the harsh words list in client code
      return [];
    }
  }
}
