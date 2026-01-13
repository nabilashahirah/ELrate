/// Application-wide constants
class AppConstants {
  // API Endpoints
  static const String getCoursesUrl = "https://getcourse-1089993125152.asia-southeast2.run.app";
  static const String submitReviewUrl = "https://submitreview-1089993125152.asia-southeast2.run.app";
  static const String getReviewsUrl = "https://getreviews-1089993125152.asia-southeast2.run.app";
  static const String getHarshWordsUrl = "https://getharshword-1089993125152.asia-southeast2.run.app";

  // Colors
  static const int upmMaroon = 0xFF800000;

  // App Info
  static const String appName = "ELRate";
  static const String appTitle = "ELRate Subjects";

  // Content Moderation - harsh words are fetched from Cloud Function
  // DO NOT hardcode the list here as it can be exposed via APK decompilation
}
