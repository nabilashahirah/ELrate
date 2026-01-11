class Course {
  final String id;
  final String name;
  final String faculty;
  final String facultyShort;
  final String description;
  final double averageRating;
  final int totalReviews;

  Course({
    required this.id,
    required this.name,
    required this.faculty,
    required this.facultyShort,
    required this.description,
    required this.averageRating,
    required this.totalReviews,
  });

  // Factory constructor to create Course from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      faculty: json['faculty'] ?? '',
      facultyShort: json['facultyShort'] ?? 'Gen',
      description: json['description'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  // Convert Course to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'faculty': faculty,
      'facultyShort': facultyShort,
      'description': description,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }
}
