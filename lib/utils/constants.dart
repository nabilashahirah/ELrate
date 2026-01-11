/// Application-wide constants
class AppConstants {
  // API Endpoints
  static const String getCoursesUrl = "https://getcourse-1089993125152.asia-southeast2.run.app";
  static const String submitReviewUrl = "https://submitreview-1089993125152.asia-southeast2.run.app";
  static const String getReviewsUrl = "https://getreviews-1089993125152.asia-southeast2.run.app";
  static const String getHarshWordsUrl = "https://getharshwords-1089993125152.asia-southeast2.run.app";

  // Colors
  static const int upmMaroon = 0xFF800000;

  // App Info
  static const String appName = "ELRate";
  static const String appTitle = "ELRate Subjects";

  // Content Moderation
  static const List<String> harshWords = [
    'stupid', 'idiot', 'dumb', 'hate', 'hell', 'damn', 'suck', 'useless',
    'trash', 'rubbish', 'worst', 'horrible', 'terrible', 'fuck', 'shit', 'ass'
  ];
}
