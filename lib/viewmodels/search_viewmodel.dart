import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class SearchViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Course> _allCourses = [];
  List<Course> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedFaculty = 'All';
  double _minRating = 0.0;

  // Getters
  List<Course> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedFaculty => _selectedFaculty;
  double get minRating => _minRating;

  /// Initialize by fetching all courses
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allCourses = await _apiService.getCourses();
      _searchResults = _allCourses;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _allCourses = [];
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Update faculty filter
  void updateFacultyFilter(String faculty) {
    _selectedFaculty = faculty;
    _applyFilters();
  }

  /// Update rating filter
  void updateRatingFilter(double rating) {
    _minRating = rating;
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedFaculty = 'All';
    _minRating = 0.0;
    _searchResults = _allCourses;
    notifyListeners();
  }

  /// Apply all filters
  void _applyFilters() {
    _searchResults = _allCourses.where((course) {
      // Search by course code or name
      final matchesSearch = _searchQuery.isEmpty ||
          course.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by faculty
      final matchesFaculty = _selectedFaculty == 'All' ||
          course.facultyShort == _selectedFaculty;

      // Filter by rating
      final matchesRating = course.averageRating >= _minRating;

      return matchesSearch && matchesFaculty && matchesRating;
    }).toList();

    notifyListeners();
  }

  /// Refresh courses
  Future<void> refresh() async {
    await initialize();
  }
}
