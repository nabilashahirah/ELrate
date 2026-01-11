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
  bool _isNewestFirst = true;
  
  // Pagination state
  int _offset = 0;
  final int _limit = 5; // Load 5 reviews at a time
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Getters
  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isNewestFirst => _isNewestFirst;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  CourseDetailViewModel({required this.course});

  /// Fetch reviews for the course
  Future<void> fetchReviews() async {
    _isLoading = true;
    _errorMessage = null;
    _offset = 0;
    _hasMore = true;
    notifyListeners();

    try {
      _reviews = await _apiService.getReviews(course.id, limit: _limit, offset: _offset);
      if (_reviews.length < _limit) _hasMore = false;
      _sortReviews();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _reviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load the next page of reviews
  Future<void> loadMoreReviews() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextOffset = _offset + _limit;
      final newReviews = await _apiService.getReviews(course.id, limit: _limit, offset: nextOffset);

      if (newReviews.isEmpty) {
        _hasMore = false;
      } else {
        _reviews.addAll(newReviews);
        _offset = nextOffset;
        if (newReviews.length < _limit) _hasMore = false;
        _sortReviews(); // Re-sort combined list
      }
    } catch (e) {
      // Silently fail or handle error
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Toggle sort order between newest and oldest
  void toggleSortOrder() {
    _isNewestFirst = !_isNewestFirst;
    _sortReviews();
    notifyListeners();
  }

  void _sortReviews() {
    _reviews.sort((a, b) {
      final dateA = a.timestamp ?? DateTime(1970);
      final dateB = b.timestamp ?? DateTime(1970);
      return _isNewestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });
  }

  /// Refresh reviews after adding a new one
  Future<void> refreshReviews() async {
    await fetchReviews();
  }
}
