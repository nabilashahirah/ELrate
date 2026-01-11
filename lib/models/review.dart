class Review {
  final String courseId;
  final String studentName;
  final double rating;
  final String comment;
  final String? userId;  // User ID to link review to user
  final bool isAnonymous;  // Whether to display name as Anonymous
  final bool isRecommended;  // Whether user recommends this course
  final DateTime? timestamp; // Date of the review

  Review({
    required this.courseId,
    required this.studentName,
    required this.rating,
    required this.comment,
    this.userId,
    this.isAnonymous = false,
    this.isRecommended = false,
    this.timestamp,
  });

  // Factory constructor to create Review from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      courseId: json['courseId'] ?? '',
      studentName: json['studentName'] ?? 'Anonymous',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      userId: json['userId'],
      isAnonymous: json['isAnonymous'] ?? false,
      isRecommended: json['isRecommended'] ?? false,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }

  // Convert Review to JSON
  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'studentName': studentName,
      'rating': rating,
      'comment': comment,
      if (userId != null) 'userId': userId,
      'isAnonymous': isAnonymous,
      'isRecommended': isRecommended,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  // Helper to parse timestamp from various formats (String, Firestore Object, etc.)
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is String) return DateTime.tryParse(timestamp);
    if (timestamp is Map) {
      // Handle Firestore timestamp object {_seconds: ..., _nanoseconds: ...}
      if (timestamp.containsKey('_seconds')) {
        return DateTime.fromMillisecondsSinceEpoch((timestamp['_seconds'] * 1000));
      }
    }
    return null;
  }
}
