import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AddReviewViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final String courseId;

  double _rating = 5.0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAnonymous = false;
  bool _isRecommended = false;

  // Getters
  double get rating => _rating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAnonymous => _isAnonymous;
  bool get isRecommended => _isRecommended;

  AddReviewViewModel({required this.courseId});

  /// Update rating
  void updateRating(double newRating) {
    _rating = newRating;
    notifyListeners();
  }

  /// Toggle anonymous
  void toggleAnonymous(bool value) {
    _isAnonymous = value;
    notifyListeners();
  }

  /// Toggle recommended
  void toggleRecommended(bool value) {
    _isRecommended = value;
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
      // Get current user data
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        _errorMessage = "User not logged in";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final review = Review(
        courseId: courseId,
        studentName: _isAnonymous ? 'Anonymous' : currentUser.name,
        rating: _rating,
        comment: comment,
        userId: currentUser.id,
        isAnonymous: _isAnonymous,
        isRecommended: _isRecommended,
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
