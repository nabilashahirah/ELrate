import 'package:flutter/material.dart';
import '../models/university.dart';
import '../services/ai_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/security_helper.dart';

class AddUniversityViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final AiService _aiService = AiService();

  bool _isLoading = false;
  bool _isValidatingWithAi = false;
  String? _errorMessage;
  University? _addedUniversity;
  AiValidationResult? _aiValidationResult;

  // Getters
  bool get isLoading => _isLoading;
  bool get isValidatingWithAi => _isValidatingWithAi;
  String? get errorMessage => _errorMessage;
  University? get addedUniversity => _addedUniversity;
  AiValidationResult? get aiValidationResult => _aiValidationResult;

  /// Check if AI validation has been completed and passed
  bool get isAiValidated => _aiValidationResult != null && _aiValidationResult!.isValid;

  /// Check if can submit (AI validation passed)
  bool get canSubmit => isAiValidated;

  /// Clear AI validation result
  void clearAiValidation() {
    _aiValidationResult = null;
    notifyListeners();
  }

  /// Validate university with AI
  Future<AiValidationResult> validateUniversityWithAi({
    required String name,
    required String shortName,
    required String country,
  }) async {
    _isValidatingWithAi = true;
    _aiValidationResult = null;
    notifyListeners();

    try {
      _aiValidationResult = await _aiService.validateUniversity(
        universityName: name,
        shortName: shortName,
        country: country,
      );

      _isValidatingWithAi = false;
      notifyListeners();
      return _aiValidationResult!;
    } catch (e) {
      _isValidatingWithAi = false;
      _aiValidationResult = AiValidationResult(
        isValid: false,
        confidence: 'unknown',
        reason: 'Could not validate university. Please try again.',
      );
      notifyListeners();
      return _aiValidationResult!;
    }
  }

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

    // Require AI validation first
    if (!isAiValidated) {
      _errorMessage = 'Please validate the university with AI first';
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
