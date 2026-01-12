import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class CourseListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Course> _courses = [];
  List<Review> _latestReviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Course> get courses => _courses;
  List<Review> get latestReviews => _latestReviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all courses
  Future<void> fetchCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _apiService.getCourses();
      await _fetchLatestReviews();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _courses = [];
      _latestReviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch latest reviews across all courses
  Future<void> _fetchLatestReviews() async {
    List<Review> allReviews = [];

    // Fetch reviews from multiple courses (up to 10 courses to get diverse reviews)
    final coursesToFetch = _courses.take(10).toList();

    for (var course in coursesToFetch) {
      try {
        final reviews = await _apiService.getReviews(course.id, limit: 5);
        allReviews.addAll(reviews);
      } catch (e) {
        // Continue if one course fails
        continue;
      }
    }

    // Sort by timestamp (newest first) and take top 10
    allReviews.sort((a, b) {
      if (a.timestamp == null && b.timestamp == null) return 0;
      if (a.timestamp == null) return 1;
      if (b.timestamp == null) return -1;
      return b.timestamp!.compareTo(a.timestamp!);
    });

    _latestReviews = allReviews.take(10).toList();
  }

  /// Refresh courses (for pull-to-refresh)
  Future<void> refreshCourses() async {
    await fetchCourses();
  }
}
