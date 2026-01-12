/// Security helper for input sanitization and validation
class SecurityHelper {
  /// Sanitize text input to prevent XSS and injection attacks
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    // Remove potentially dangerous characters
    String sanitized = input
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('&lt;', '')
        .replaceAll('&gt;', '')
        .replaceAll('<script', '')
        .replaceAll('</script>', '')
        .replaceAll('javascript:', '')
        .replaceAll('onerror=', '')
        .replaceAll('onclick=', '')
        .replaceAll('onload=', '');

    // Trim and limit length
    sanitized = sanitized.trim();

    return sanitized;
  }

  /// Validate email format with regex
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null; // Valid
  }

  /// Sanitize review comment - allow basic punctuation but prevent scripts
  static String sanitizeComment(String comment) {
    if (comment.isEmpty) return comment;

    // Remove HTML tags and scripts
    String sanitized = comment
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove all HTML tags
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');

    // Trim whitespace and limit length (max 1000 characters for reviews)
    sanitized = sanitized.trim();
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
    }

    return sanitized;
  }

  /// Validate course ID format (alphanumeric and specific format)
  static bool isValidCourseId(String courseId) {
    // Course IDs should be alphanumeric, possibly with dashes/underscores
    final courseIdRegex = RegExp(r'^[A-Z0-9_-]+$', caseSensitive: false);
    return courseIdRegex.hasMatch(courseId) && courseId.length <= 20;
  }

  /// Rate limiting check (simple client-side check)
  static final Map<String, DateTime> _lastAttempts = {};

  static bool canAttemptAction(String actionKey, {int cooldownSeconds = 3}) {
    final now = DateTime.now();
    final lastAttempt = _lastAttempts[actionKey];

    if (lastAttempt != null) {
      final difference = now.difference(lastAttempt).inSeconds;
      if (difference < cooldownSeconds) {
        return false; // Too soon
      }
    }

    _lastAttempts[actionKey] = now;
    return true;
  }
}
