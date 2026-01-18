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
  final List<String> _availableFaculties = ['All'];

  // Getters
  List<Course> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedFaculty => _selectedFaculty;
  double get minRating => _minRating;
  List<String> get availableFaculties => _availableFaculties;

  // UI Helpers to distinguish between "All Courses" and "Search Results"
  bool get isFiltered => _searchQuery.isNotEmpty || _selectedFaculty != 'All' || _minRating > 0;
  int get totalCoursesCount => _allCourses.length;
  int get filteredCoursesCount => _searchResults.length;

  /// Initialize by fetching all courses
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allCourses = await _apiService.getCourses();
      _searchResults = _allCourses;
      _errorMessage = null;

      // Extract unique faculties from courses
      _extractUniqueFaculties();
    } catch (e) {
      _errorMessage = e.toString();
      _allCourses = [];
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Extract unique faculties from all courses
  void _extractUniqueFaculties() {
    final faculties = <String>{'All'};
    for (var course in _allCourses) {
      if (course.facultyShort.isNotEmpty) {
        faculties.add(course.facultyShort);
      }
    }
    _availableFaculties.clear();
    _availableFaculties.addAll(faculties.toList()..sort((a, b) {
      if (a == 'All') return -1;
      if (b == 'All') return 1;
      return a.compareTo(b);
    }));
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

    // Sort results: when rating filter is active, sort by rating descending
    if (_minRating > 0) {
      _searchResults.sort((a, b) {
        final ratingComparison = b.averageRating.compareTo(a.averageRating);
        if (ratingComparison != 0) return ratingComparison;
        // Tiebreaker: more reviews first
        return b.totalReviews.compareTo(a.totalReviews);
      });
    }

    notifyListeners();
  }

  /// Refresh courses while preserving filters
  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch fresh data from API
      _allCourses = await _apiService.getCourses();
      _errorMessage = null;

      // Extract unique faculties from courses
      _extractUniqueFaculties();

      // Reapply existing filters to the new data
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
      _allCourses = [];
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
