import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/ai_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AddReviewViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final AiService _aiService = AiService();
  final String courseId;

  double _rating = 5.0;
  bool _isLoading = false;
  bool _isCheckingContent = false;
  String? _errorMessage;
  bool _isAnonymous = false;
  bool _isRecommended = false;
  ContentModerationResult? _moderationResult;

  // Getters
  double get rating => _rating;
  bool get isLoading => _isLoading;
  bool get isCheckingContent => _isCheckingContent;
  String? get errorMessage => _errorMessage;
  bool get isAnonymous => _isAnonymous;
  bool get isRecommended => _isRecommended;
  ContentModerationResult? get moderationResult => _moderationResult;

  /// Check if content has been checked and is appropriate
  bool get isContentChecked => _moderationResult != null && _moderationResult!.isAppropriate;

  /// Check if can submit (content check passed)
  bool get canSubmit => isContentChecked;

  AddReviewViewModel({required this.courseId});

  /// Clear moderation result
  void clearModerationResult() {
    _moderationResult = null;
    notifyListeners();
  }

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

  /// Check content with AI before submission
  Future<ContentModerationResult> checkContentWithAi(String comment) async {
    _isCheckingContent = true;
    _moderationResult = null;
    notifyListeners();

    try {
      _moderationResult = await _aiService.moderateReviewContent(
        reviewText: comment,
      );
      _isCheckingContent = false;
      notifyListeners();
      return _moderationResult!;
    } catch (e) {
      _isCheckingContent = false;
      _moderationResult = ContentModerationResult(
        isAppropriate: false,
        reason: 'Could not check content. Please try again.',
        flaggedWords: [],
      );
      notifyListeners();
      return _moderationResult!;
    }
  }

  /// Submit review with AI content moderation
  Future<bool> submitReview(String comment) async {
    if (comment.isEmpty) {
      _errorMessage = "Please enter a comment";
      notifyListeners();
      return false;
    }

    // Require AI content check first
    if (!isContentChecked) {
      _errorMessage = 'Please check your content with AI first';
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
      _moderationResult = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
