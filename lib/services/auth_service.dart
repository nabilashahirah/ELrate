import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_request.dart';
import '../models/user.dart';
import '../models/review.dart';
import '../utils/security_helper.dart';
import 'secure_storage_service.dart';

class AuthService {
  // API Endpoints - Update these with your actual backend URLs
  static const String _loginUrl = "https://login-1089993125152.asia-southeast2.run.app";
  static const String _signupUrl = "https://signup-1089993125152.asia-southeast2.run.app";
  static const String _updateProfileUrl = "https://updateprofile-1089993125152.asia-southeast2.run.app";
  static const String _getUserReviewsUrl = "https://getuserreviews-1089993125152.asia-southeast2.run.app";
  static const String _forgotPasswordUrl = "https://forgotpassword-1089993125152.asia-southeast2.run.app";

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
  final _secureStorage = SecureStorageService();

  /// Login user
  Future<AuthResponse> login(LoginRequest request) async {
    // Rate limiting check
    if (!SecurityHelper.canAttemptAction('login', cooldownSeconds: 2)) {
      throw Exception('Too many attempts. Please wait a moment.');
    }

    // Input validation
    if (!SecurityHelper.isValidEmail(request.email)) {
      throw Exception('Invalid email format');
    }

    if (request.password.length < 8) {
      throw Exception('Invalid credentials');
    }

    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(request.toJson()),
      ).timeout(
        const Duration(seconds: 30), // 30 seconds for cold start
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet and try again.');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final authResponse = AuthResponse.fromJson(jsonData);

        // Save auth data
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        // Generic error message - don't reveal if user exists or password is wrong
        throw Exception('Invalid email or password');
      }
    } on SocketException {
      // Network error - no internet connection
      throw Exception('No internet connection. Please check your network and try again.');
    } on FormatException {
      // Invalid response format
      throw Exception('Invalid server response. Please try again later.');
    } catch (e) {
      // Re-throw if already an Exception with our message
      if (e is Exception && e.toString().contains('Exception:')) rethrow;
      // Generic fallback for unexpected errors
      throw Exception('Unable to sign in. Please try again later.');
    }
  }

  /// Sign up new user
  Future<AuthResponse> signup(SignupRequest request) async {
    // Rate limiting check
    if (!SecurityHelper.canAttemptAction('signup', cooldownSeconds: 5)) {
      throw Exception('Too many attempts. Please wait a moment.');
    }

    // Input validation and sanitization
    final sanitizedName = SecurityHelper.sanitizeInput(request.name);
    if (sanitizedName.isEmpty || sanitizedName.length < 2) {
      throw Exception('Name must be at least 2 characters');
    }

    if (!SecurityHelper.isValidEmail(request.email)) {
      throw Exception('Invalid email format');
    }

    // Validate password strength
    final passwordError = SecurityHelper.validatePassword(request.password);
    if (passwordError != null) {
      throw Exception(passwordError);
    }

    try {
      // Create sanitized request
      final sanitizedRequest = SignupRequest(
        name: sanitizedName,
        email: request.email.trim().toLowerCase(),
        password: request.password,
      );

      final response = await http.post(
        Uri.parse(_signupUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(sanitizedRequest.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        final authResponse = AuthResponse.fromJson(jsonData);

        // Save auth data
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        // Generic error message - don't expose backend details
        throw Exception('Unable to create account. Please try a different email.');
      }
    } on SocketException {
      // Network error - no internet connection
      throw Exception('No internet connection. Please check your network and try again.');
    } on FormatException {
      // Invalid response format
      throw Exception('Invalid server response. Please try again later.');
    } catch (e) {
      // Re-throw if already an Exception with our message
      if (e is Exception && e.toString().contains('Exception:')) rethrow;
      // Generic fallback for unexpected errors
      throw Exception('Unable to sign up. Please try again later.');
    }
  }

  /// Save authentication data locally
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    // Save Token to Secure Storage
    await _secureStorage.write(_tokenKey, authResponse.token);
    // Save User Info to Shared Preferences (Non-sensitive)
    await prefs.setString(_userIdKey, authResponse.userId);
    await prefs.setString(_userNameKey, authResponse.name);
    await prefs.setString(_userEmailKey, authResponse.email);
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _secureStorage.read(_tokenKey);
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

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

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

        return reviewsJson.map((json) => Review.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        // Generic error message - don't expose internal details
        throw Exception('Failed to fetch reviews. Please try again.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to load reviews. Please check your connection.');
    }
  }

  /// Forgot password - Send reset email
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(_forgotPasswordUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - password reset email sent
        return;
      } else {
        // Generic error - don't reveal if email exists or not (prevents email enumeration)
        throw Exception('If this email exists, a password reset link has been sent.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to process request. Please try again later.');
    }
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  /// Mock login (for testing without backend)
  Future<AuthResponse> mockLogin(LoginRequest request) async {
    // Security: Ensure mock methods are NEVER run in release mode
    bool isDebug = false;
    assert(isDebug = true);
    if (!isDebug) {
      throw Exception('Mock login is not available in release builds.');
    }

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Mock validation
    if (request.email.isEmpty || request.password.isEmpty) {
      throw Exception('Email and password are required');
    }

    if (!request.email.contains('@')) {
      throw Exception('Invalid email format');
    }

    if (request.password.length < 8) {
      throw Exception('Password must be at least 8 characters');
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
    // Security: Ensure mock methods are NEVER run in release mode
    bool isDebug = false;
    assert(isDebug = true);
    if (!isDebug) {
      throw Exception('Mock signup is not available in release builds.');
    }

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Mock validation
    if (request.name.isEmpty || request.email.isEmpty || request.password.isEmpty) {
      throw Exception('All fields are required');
    }

    if (!request.email.contains('@')) {
      throw Exception('Invalid email format');
    }

    if (request.password.length < 8) {
      throw Exception('Password must be at least 8 characters');
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
