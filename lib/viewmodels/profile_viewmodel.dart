import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/review.dart';
import '../services/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  List<Review> _myReviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  List<Review> get myReviews => _myReviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize user data
  Future<void> initialize() async {
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile(String name, String email) async {
    if (_user == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call the API to update profile
      final updatedUser = await _authService.updateProfile(name, email);

      // Update local user data
      _user = updatedUser;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch user's reviews from API
  Future<void> fetchMyReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch reviews from API
      _myReviews = await _authService.getUserReviews();
      _errorMessage = null;
    } catch (e) {
      String msg = e.toString().replaceAll('Exception: ', '');
      // Detect Firestore missing index error
      if (msg.contains('FAILED_PRECONDITION')) {
        msg = 'Unable to load reviews. Please try again later.';
      }
      _errorMessage = msg;
      _myReviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    // In a real app, clear tokens, cache, etc.
    _user = User(
      id: '',
      name: 'Guest',
      email: '',
    );
    _myReviews = [];
    notifyListeners();
  }
}
