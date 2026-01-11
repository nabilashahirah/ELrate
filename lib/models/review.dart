class Review {
  final String courseId;
  final String studentName;
  final double rating;
  final String comment;

  Review({
    required this.courseId,
    required this.studentName,
    required this.rating,
    required this.comment,
  });

  // Factory constructor to create Review from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      courseId: json['courseId'] ?? '',
      studentName: json['studentName'] ?? 'Anonymous',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
    );
  }

  // Convert Review to JSON
  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'studentName': studentName,
      'rating': rating,
      'comment': comment,
    };
  }
}
