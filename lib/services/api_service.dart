import 'dart:convert';
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
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  /// Fetch reviews for a specific course
  Future<List<Review>> getReviews(String courseId, {int? limit, int? offset}) async {
    try {
      var url = "$_getReviewsUrl?courseId=$courseId";
      if (limit != null) url += "&limit=$limit";
      if (offset != null) url += "&offset=$offset";

      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting review: $e');
    }
  }
}
