import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_request.dart';
import '../models/user.dart';
import '../models/review.dart';

class AuthService {
  // API Endpoints - Update these with your actual backend URLs
  static const String _loginUrl = "https://login-1089993125152.asia-southeast2.run.app";
  static const String _signupUrl = "https://signup-1089993125152.asia-southeast2.run.app";
  static const String _updateProfileUrl = "https://updateprofile-1089993125152.asia-southeast2.run.app";
  static const String _getUserReviewsUrl = "https://getuserreviews-1089993125152.asia-southeast2.run.app";

  // SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Secure storage for sensitive data (Token)
  final _secureStorage = const FlutterSecureStorage();

  /// Login user
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final authResponse = AuthResponse.fromJson(jsonData);

        // Save auth data
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        // Try to parse error message from response
        try {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Login failed (${response.statusCode})');
        } catch (_) {
          throw Exception('Login failed with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      // If it's already an Exception, rethrow it
      if (e is Exception) rethrow;
      throw Exception('Error during login: $e');
    }
  }

  /// Sign up new user
  Future<AuthResponse> signup(SignupRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(_signupUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        final authResponse = AuthResponse.fromJson(jsonData);

        // Save auth data
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        // Try to parse error message from response
        try {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Signup failed (${response.statusCode})');
        } catch (_) {
          throw Exception('Signup failed with status code: ${response.statusCode}. Response: ${response.body}');
        }
      }
    } catch (e) {
      // If it's already an Exception, rethrow it
      if (e is Exception) rethrow;
      throw Exception('Error during signup: $e');
    }
  }

  /// Save authentication data locally
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    // Save Token to Secure Storage
    await _secureStorage.write(key: _tokenKey, value: authResponse.token);
    // Save User Info to Shared Preferences (Non-sensitive)
    await prefs.setString(_userIdKey, authResponse.userId);
    await prefs.setString(_userNameKey, authResponse.name);
    await prefs.setString(_userEmailKey, authResponse.email);
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Get stored user data
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    final name = prefs.getString(_userNameKey);
    final email = prefs.getString(_userEmailKey);

    if (userId == null || name == null || email == null) {
      return null;
    }

    return User(
      id: userId,
      name: name,
      email: email,
    );
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Update user profile
  Future<User> updateProfile(String name, String email) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(_updateProfileUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          'name': name,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Update local storage with new data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userNameKey, name);
        await prefs.setString(_userEmailKey, email);

        // Return updated user
        final userId = prefs.getString(_userIdKey);
        return User(
          id: userId ?? '',
          name: name,
          email: email,
        );
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  /// Get user's reviews
  Future<List<Review>> getUserReviews() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Get current user to pass userId
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Add userId as query parameter
      final uri = Uri.parse("$_getUserReviewsUrl?userId=${Uri.encodeComponent(currentUser.id)}");

      print('🔍 Fetching reviews for userId: ${currentUser.id}');
      print('🌐 URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Handle both array and object responses
        List<dynamic> reviewsJson;
        if (jsonData is List) {
          // Direct array response
          reviewsJson = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('reviews')) {
          // Object with 'reviews' key
          reviewsJson = jsonData['reviews'] as List<dynamic>;
        } else {
          // Empty or unexpected format
          reviewsJson = [];
        }

        print('✅ Parsed ${reviewsJson.length} reviews');
        return reviewsJson.map((json) => Review.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        String errorMessage;
        try {
          final error = json.decode(response.body);
          errorMessage = error['message'] ?? error['error'] ?? 'Failed to fetch reviews';
        } catch (_) {
          errorMessage = 'Failed to fetch reviews (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ getUserReviews error: $e');
      throw Exception('Error fetching reviews: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: _tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  /// Mock login (for testing without backend)
  Future<AuthResponse> mockLogin(LoginRequest request) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Mock validation
    if (request.email.isEmpty || request.password.isEmpty) {
      throw Exception('Email and password are required');
    }

    if (!request.email.contains('@')) {
      throw Exception('Invalid email format');
    }

    if (request.password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Mock successful response
    final authResponse = AuthResponse(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      userId: '1',
      name: request.email.split('@')[0],
      email: request.email,
    );

    await _saveAuthData(authResponse);
    return authResponse;
  }

  /// Mock signup (for testing without backend)
  Future<AuthResponse> mockSignup(SignupRequest request) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Mock validation
    if (request.name.isEmpty || request.email.isEmpty || request.password.isEmpty) {
      throw Exception('All fields are required');
    }

    if (!request.email.contains('@')) {
      throw Exception('Invalid email format');
    }

    if (request.password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Mock successful response
    final authResponse = AuthResponse(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      userId: '1',
      name: request.name,
      email: request.email,
    );

    await _saveAuthData(authResponse);
    return authResponse;
  }
}
