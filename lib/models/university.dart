class University {
  final String id;
  final String name;
  final String shortName;
  final String country;
  final int totalCourses;

  University({
    required this.id,
    required this.name,
    required this.shortName,
    required this.country,
    this.totalCourses = 0,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    // Handle totalCourses as either int or String
    int parseTotalCourses(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return University(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      country: json['country'] ?? 'Malaysia',
      totalCourses: parseTotalCourses(json['totalCourses']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'country': country,
      'totalCourses': totalCourses,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is University && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
