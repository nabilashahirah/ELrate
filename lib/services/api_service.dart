import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../models/review.dart';
import '../models/university.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class ApiService {
  // API Endpoints from constants
  static const String _getCoursesUrl = AppConstants.getCoursesUrl;
  static const String _submitReviewUrl = AppConstants.submitReviewUrl;
  static const String _getReviewsUrl = AppConstants.getReviewsUrl;
  static const String _getUniversitiesUrl = AppConstants.getUniversitiesUrl;
  static const String _addUniversityUrl = AppConstants.addUniversityUrl;
  static const String _addCourseUrl = AppConstants.addCourseUrl;

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
        // Backend validation error
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

  /// Fetch all universities
  Future<List<University>> getUniversities() async {
    try {
      print('Fetching universities from: $_getUniversitiesUrl');
      final response = await http.get(Uri.parse(_getUniversitiesUrl));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => University.fromJson(json)).toList();
      } else {
        throw Exception('Unable to load universities. Status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception('No internet connection. Please check your network.');
    } on FormatException catch (e) {
      print('FormatException: $e');
      throw Exception('Invalid data received. Please try again later.');
    } catch (e) {
      print('Error fetching universities: $e');
      if (e is Exception && e.toString().contains('Exception:')) rethrow;
      throw Exception('Unable to load universities: $e');
    }
  }

  /// Add a new university
  Future<University> addUniversity({
    required String name,
    required String shortName,
    required String country,
  }) async {
    try {
      final token = await _authService.getToken();

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http.post(
        Uri.parse(_addUniversityUrl),
        headers: headers,
        body: json.encode({
          'name': name,
          'shortName': shortName,
          'country': country,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return University.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Invalid university data.');
      } else if (response.statusCode == 409) {
        throw Exception('University already exists.');
      } else {
        throw Exception('Unable to add university. Please try again later.');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again later.');
    } catch (e) {
      if (e is Exception && e.toString().contains('Exception:')) rethrow;
      throw Exception('Unable to add university. Please try again later.');
    }
  }

  /// Add a new course
  Future<Course> addCourse({
    required String courseId,
    required String name,
    required String faculty,
    required String facultyShort,
    required String description,
    required String universityId,
  }) async {
    try {
      final token = await _authService.getToken();

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http.post(
        Uri.parse(_addCourseUrl),
        headers: headers,
        body: json.encode({
          'id': courseId,
          'name': name,
          'faculty': faculty,
          'facultyShort': facultyShort,
          'description': description,
          'universityId': universityId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Course.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Invalid course data.');
      } else if (response.statusCode == 409) {
        throw Exception('Course already exists.');
      } else {
        throw Exception('Unable to add course. Please try again later.');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again later.');
    } catch (e) {
      if (e is Exception && e.toString().contains('Exception:')) rethrow;
      throw Exception('Unable to add course. Please try again later.');
    }
  }
}
