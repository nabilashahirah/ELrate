import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
/// Supports phones, tablets, and different orientations
class Responsive {
  final BuildContext context;

  Responsive(this.context);

  /// Get screen width
  double get width => MediaQuery.of(context).size.width;

  /// Get screen height
  double get height => MediaQuery.of(context).size.height;

  /// Get shortest side (good for device type detection)
  double get shortestSide => MediaQuery.of(context).size.shortestSide;

  /// Get screen orientation
  Orientation get orientation => MediaQuery.of(context).orientation;

  /// Check if device is in portrait mode
  bool get isPortrait => orientation == Orientation.portrait;

  /// Check if device is in landscape mode
  bool get isLandscape => orientation == Orientation.landscape;

  /// Device type breakpoints
  bool get isMobile => shortestSide < 600;
  bool get isTablet => shortestSide >= 600 && shortestSide < 1024;
  bool get isDesktop => shortestSide >= 1024;

  /// Specific size checks
  bool get isSmallMobile => shortestSide < 360;
  bool get isLargeMobile => shortestSide >= 360 && shortestSide < 600;
  bool get isSmallTablet => shortestSide >= 600 && shortestSide < 768;
  bool get isLargeTablet => shortestSide >= 768 && shortestSide < 1024;

  /// Responsive sizing methods

  /// Get responsive width percentage (0.0 - 1.0)
  double wp(double percentage) => width * percentage / 100;

  /// Get responsive height percentage (0.0 - 1.0)
  double hp(double percentage) => height * percentage / 100;

  /// Get responsive font size based on screen width
  double sp(double size) {
    if (isSmallMobile) return size * 0.85;
    if (isLargeMobile) return size;
    if (isTablet) return size * 1.15;
    if (isDesktop) return size * 1.3;
    return size;
  }

  /// Get responsive padding/margin
  double spacing(double base) {
    if (isLandscape && isMobile) return base * 0.7; // Reduce spacing in landscape
    if (isSmallMobile) return base * 0.8;
    if (isLargeMobile) return base;
    if (isTablet) return base * 1.3;
    if (isDesktop) return base * 1.5;
    return base;
  }

  /// Get number of columns for grid layouts
  int get gridColumns {
    if (isMobile && isPortrait) return 1;
    if (isMobile && isLandscape) return 2;
    if (isTablet && isPortrait) return 2;
    if (isTablet && isLandscape) return 3;
    return 4;
  }

  /// Get card width for horizontal lists
  double get cardWidth {
    if (isSmallMobile) return width * 0.42;
    if (isLargeMobile) return width * 0.45;
    if (isTablet) return width * 0.3;
    return width * 0.25;
  }

  /// Get card height for horizontal lists
  double get cardHeight {
    if (isLandscape && isMobile) return 180; // Fixed height for landscape mobile
    if (isMobile) return hp(22);
    if (isTablet) return hp(25);
    return hp(28);
  }

  /// Get icon size based on device
  double iconSize(double base) {
    if (isSmallMobile) return base * 0.85;
    if (isLargeMobile) return base;
    if (isTablet) return base * 1.2;
    return base * 1.4;
  }

  /// Get avatar size
  double get avatarSize {
    if (isSmallMobile) return 40;
    if (isLargeMobile) return 50;
    if (isTablet) return 65;
    return 80;
  }

  /// Get logo size
  double get logoSize {
    if (isLandscape && isMobile) return 80; // Smaller logo in landscape
    if (isSmallMobile) return 70;
    if (isLargeMobile) return 100;
    if (isTablet) return 130;
    return 150;
  }

  /// Get button height
  double get buttonHeight {
    if (isSmallMobile) return 48;
    if (isLargeMobile) return 54;
    if (isTablet) return 60;
    return 66;
  }

  /// Get max content width for large screens
  double get maxContentWidth {
    if (isTablet) return 700;
    if (isDesktop) return 900;
    return width;
  }

  /// Center content on large screens
  Widget centerContent(Widget child) {
    if (isMobile) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }

  /// Responsive horizontal padding
  EdgeInsets get horizontalPadding {
    return EdgeInsets.symmetric(horizontal: spacing(20));
  }

  /// Responsive vertical padding
  EdgeInsets get verticalPadding {
    return EdgeInsets.symmetric(vertical: spacing(16));
  }

  /// Responsive all-around padding
  EdgeInsets get allPadding {
    return EdgeInsets.all(spacing(16));
  }
}

/// Extension method for easy access to Responsive
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
}

/// Text scale factors for different screen sizes
class ResponsiveText {
  static double getScaleFactor(BuildContext context) {
    final responsive = Responsive(context);
    if (responsive.isSmallMobile) return 0.85;
    if (responsive.isLargeMobile) return 1.0;
    if (responsive.isTablet) return 1.15;
    return 1.3;
  }

  static TextStyle scale(BuildContext context, TextStyle style) {
    final scaleFactor = getScaleFactor(context);
    return style.copyWith(
      fontSize: (style.fontSize ?? 14) * scaleFactor,
    );
  }
}
