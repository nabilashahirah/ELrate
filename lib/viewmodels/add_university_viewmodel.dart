import 'package:flutter/material.dart';
import '../models/university.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/security_helper.dart';

class AddUniversityViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  University? _addedUniversity;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  University? get addedUniversity => _addedUniversity;

  /// Submit new university
  Future<bool> submitUniversity({
    required String name,
    required String shortName,
    required String country,
  }) async {
    // Rate limiting
    if (!SecurityHelper.canAttemptAction('add_university', cooldownSeconds: 5)) {
      _errorMessage = 'Too many attempts. Please wait a moment.';
      notifyListeners();
      return false;
    }

    // Validation
    final sanitizedName = SecurityHelper.sanitizeInput(name);
    final sanitizedShortName = SecurityHelper.sanitizeInput(shortName);
    final sanitizedCountry = SecurityHelper.sanitizeInput(country);

    if (sanitizedName.isEmpty || sanitizedName.length < 3) {
      _errorMessage = 'University name must be at least 3 characters';
      notifyListeners();
      return false;
    }

    if (sanitizedShortName.isEmpty || sanitizedShortName.length > 10) {
      _errorMessage = 'Short name must be 1-10 characters';
      notifyListeners();
      return false;
    }

    if (sanitizedCountry.isEmpty) {
      _errorMessage = 'Country is required';
      notifyListeners();
      return false;
    }

    // Check if user is logged in
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      _errorMessage = 'Please login to add a university';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _addedUniversity = await _apiService.addUniversity(
        name: sanitizedName,
        shortName: sanitizedShortName.toUpperCase(),
        country: sanitizedCountry,
      );

      _isLoading = false;
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
