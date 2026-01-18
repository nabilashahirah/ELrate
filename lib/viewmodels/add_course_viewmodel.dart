import 'package:flutter/material.dart';
import '../models/university.dart';
import '../services/ai_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/security_helper.dart';

class AddCourseViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final AiService _aiService = AiService();

  List<University> _universities = [];
  University? _selectedUniversity;
  bool _isLoading = false;
  bool _isLoadingUniversities = false;
  bool _isValidatingWithAi = false;
  bool _isGeneratingDescription = false;
  String? _errorMessage;
  AiValidationResult? _aiValidationResult;
  String? _generatedDescription;

  // Getters
  List<University> get universities => _universities;
  University? get selectedUniversity => _selectedUniversity;
  bool get isLoading => _isLoading;
  bool get isLoadingUniversities => _isLoadingUniversities;
  bool get isValidatingWithAi => _isValidatingWithAi;
  bool get isGeneratingDescription => _isGeneratingDescription;
  String? get errorMessage => _errorMessage;
  AiValidationResult? get aiValidationResult => _aiValidationResult;
  String? get generatedDescription => _generatedDescription;

  /// Check if AI validation has been completed and passed
  bool get isAiValidated => _aiValidationResult != null && _aiValidationResult!.isValid;

  /// Check if can submit (AI validation passed)
  bool get canSubmit => isAiValidated;

  AddCourseViewModel() {
    fetchUniversities();
  }

  /// Fetch universities list
  Future<void> fetchUniversities() async {
    _isLoadingUniversities = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _universities = await _apiService.getUniversities();
      _isLoadingUniversities = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoadingUniversities = false;
      notifyListeners();
    }
  }

  /// Select university
  void selectUniversity(University? university) {
    _selectedUniversity = university;
    notifyListeners();
  }

  /// Clear AI validation result
  void clearAiValidation() {
    _aiValidationResult = null;
    notifyListeners();
  }

  /// Clear generated description
  void clearGeneratedDescription() {
    _generatedDescription = null;
    notifyListeners();
  }

  /// Validate course with AI
  Future<AiValidationResult> validateCourseWithAi({
    required String courseCode,
    required String courseName,
    required String faculty,
  }) async {
    if (_selectedUniversity == null) {
      return AiValidationResult(
        isValid: false,
        confidence: 'high',
        reason: 'Please select a university first.',
      );
    }

    _isValidatingWithAi = true;
    _aiValidationResult = null;
    notifyListeners();

    try {
      _aiValidationResult = await _aiService.validateCourse(
        courseCode: courseCode,
        courseName: courseName,
        faculty: faculty,
        universityName: _selectedUniversity!.name,
      );

      _isValidatingWithAi = false;
      notifyListeners();
      return _aiValidationResult!;
    } catch (e) {
      _isValidatingWithAi = false;
      _aiValidationResult = AiValidationResult(
        isValid: false,
        confidence: 'unknown',
        reason: 'Could not validate course. Please try again.',
      );
      notifyListeners();
      return _aiValidationResult!;
    }
  }

  /// Generate course description with AI
  Future<String> generateDescriptionWithAi({
    required String courseCode,
    required String courseName,
    required String faculty,
  }) async {
    if (_selectedUniversity == null) {
      return '';
    }

    _isGeneratingDescription = true;
    _generatedDescription = null;
    notifyListeners();

    try {
      _generatedDescription = await _aiService.generateCourseDescription(
        courseCode: courseCode,
        courseName: courseName,
        faculty: faculty,
        universityName: _selectedUniversity!.name,
      );

      _isGeneratingDescription = false;
      notifyListeners();
      return _generatedDescription ?? '';
    } catch (e) {
      _isGeneratingDescription = false;
      _generatedDescription = null;
      notifyListeners();
      return '';
    }
  }

  /// Submit new course
  Future<bool> submitCourse({
    required String courseId,
    required String name,
    required String faculty,
    required String facultyShort,
    required String description,
  }) async {
    // Rate limiting
    if (!SecurityHelper.canAttemptAction('add_course', cooldownSeconds: 5)) {
      _errorMessage = 'Too many attempts. Please wait a moment.';
      notifyListeners();
      return false;
    }

    // Require AI validation first
    if (!isAiValidated) {
      _errorMessage = 'Please validate the course with AI first';
      notifyListeners();
      return false;
    }

    // Validation
    if (_selectedUniversity == null) {
      _errorMessage = 'Please select a university';
      notifyListeners();
      return false;
    }

    final sanitizedCourseId = SecurityHelper.sanitizeInput(courseId);
    final sanitizedName = SecurityHelper.sanitizeInput(name);
    final sanitizedFaculty = SecurityHelper.sanitizeInput(faculty);
    final sanitizedFacultyShort = SecurityHelper.sanitizeInput(facultyShort);
    final sanitizedDescription = SecurityHelper.sanitizeInput(description);

    if (sanitizedCourseId.isEmpty || sanitizedCourseId.length < 3) {
      _errorMessage = 'Course ID must be at least 3 characters';
      notifyListeners();
      return false;
    }

    if (sanitizedName.isEmpty || sanitizedName.length < 3) {
      _errorMessage = 'Course name must be at least 3 characters';
      notifyListeners();
      return false;
    }

    if (sanitizedFaculty.isEmpty) {
      _errorMessage = 'Faculty is required';
      notifyListeners();
      return false;
    }

    if (sanitizedFacultyShort.isEmpty || sanitizedFacultyShort.length > 10) {
      _errorMessage = 'Faculty short name must be 1-10 characters';
      notifyListeners();
      return false;
    }

    // Check if user is logged in
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      _errorMessage = 'Please login to add a course';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.addCourse(
        courseId: sanitizedCourseId.toUpperCase(),
        name: sanitizedName,
        faculty: sanitizedFaculty,
        facultyShort: sanitizedFacultyShort.toUpperCase(),
        description: sanitizedDescription,
        universityId: _selectedUniversity!.id,
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
