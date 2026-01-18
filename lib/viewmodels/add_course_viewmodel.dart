import 'package:flutter/material.dart';
import '../models/university.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/security_helper.dart';

class AddCourseViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<University> _universities = [];
  University? _selectedUniversity;
  bool _isLoading = false;
  bool _isLoadingUniversities = false;
  String? _errorMessage;

  // Getters
  List<University> get universities => _universities;
  University? get selectedUniversity => _selectedUniversity;
  bool get isLoading => _isLoading;
  bool get isLoadingUniversities => _isLoadingUniversities;
  String? get errorMessage => _errorMessage;

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
