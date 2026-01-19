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

    // Sort courses by total reviews (descending) to prioritize active courses
    // This ensures we get reviews from courses that actually have reviews
    final sortedCourses = List<Course>.from(_courses)
      ..sort((a, b) => b.totalReviews.compareTo(a.totalReviews));

    // Fetch reviews from courses that have reviews (up to 15 courses for diversity)
    final coursesToFetch = sortedCourses
        .where((c) => c.totalReviews > 0)
        .take(15)
        .toList();

    // Fetch reviews in parallel for better performance
    final futures = coursesToFetch.map((course) async {
      try {
        return await _apiService.getReviews(course.id, limit: 3);
      } catch (e) {
        return <Review>[];
      }
    });

    final results = await Future.wait(futures);
    for (var reviews in results) {
      allReviews.addAll(reviews);
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
