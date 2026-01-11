import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class AddReviewViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String courseId;

  double _rating = 5.0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  double get rating => _rating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AddReviewViewModel({required this.courseId});

  /// Update rating
  void updateRating(double newRating) {
    _rating = newRating;
    notifyListeners();
  }

  /// Submit review
  Future<bool> submitReview(String comment) async {
    if (comment.isEmpty) {
      _errorMessage = "Please enter a comment";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final review = Review(
        courseId: courseId,
        studentName: "Student (App)",
        rating: _rating,
        comment: comment,
      );

      await _apiService.submitReview(review);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
