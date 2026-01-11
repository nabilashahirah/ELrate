import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class CourseDetailViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Course course;

  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CourseDetailViewModel({required this.course});

  /// Fetch reviews for the course
  Future<void> fetchReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _apiService.getReviews(course.id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _reviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh reviews after adding a new one
  Future<void> refreshReviews() async {
    await fetchReviews();
  }
}
