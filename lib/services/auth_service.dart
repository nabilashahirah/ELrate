import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_request.dart';
import '../models/user.dart';
import '../models/review.dart';

class AuthService {
  // API Endpoints - Update these with your actual backend URLs
  static const String _loginUrl = "https://login-1089993125152.asia-southeast2.run.app";
  static const String _signupUrl = "https://signup-1089993125152.asia-southeast2.run.app";
  static const String _updateProfileUrl = "https://updateprofile-1089993125152.asia-southeast2.run.app";
  static const String _getUserReviewsUrl = "https://getuserreviews-1089993125152.europe-west1.run.app";

  // SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

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
    await prefs.setString(_tokenKey, authResponse.token);
    await prefs.setString(_userIdKey, authResponse.userId);
    await prefs.setString(_userNameKey, authResponse.name);
    await prefs.setString(_userEmailKey, authResponse.email);
  }

  /// Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
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

      final response = await http.get(
        Uri.parse(_getUserReviewsUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Assuming the API returns an array of reviews
        final List<dynamic> reviewsJson = jsonData['reviews'] ?? jsonData;

        return reviewsJson.map((json) => Review.fromJson(json)).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch reviews');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
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
