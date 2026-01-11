import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class CourseListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all courses
  Future<void> fetchCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _apiService.getCourses();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _courses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh courses (for pull-to-refresh)
  Future<void> refreshCourses() async {
    await fetchCourses();
  }
}
