import 'package:flutter/material.dart';

/// Helper class for university logos and visual assets
/// Uses university building images as watermarks
class UniversityAssets {
  // University building/campus image URLs
  // Using reliable image hosting sources
  static const Map<String, String> _universityImages = {
    'UM': 'https://drive.google.com/uc?export=view&id=1XHGchaAnPcPlZ1BL3vD-cMpgLTeJl3D0',
    'UPM': 'https://drive.google.com/uc?export=view&id=1JjDWNPKkS3osFjYXGodN0H7DJLdOAJL9',
    'UKM': 'https://drive.google.com/uc?export=view&id=d/1w-ybtWHeeolkv_oWLOjuXwxGWFDfqKtd',
    'USM': 'https://drive.google.com/uc?export=view&id=1W8Xgm7j4fgPDzSmy6rEpgStoJTGITsKe',
    'UTM': 'https://www.utm.my/wp-content/uploads/2019/10/MENARA-UTM.jpg',
    'UiTM': 'https://www.uitm.edu.my/images/stories/gallery/shah-alam-campus.jpg',
    'UITM': 'https://www.uitm.edu.my/images/stories/gallery/shahy-alam-campus.jpg',
    'IIUM': 'https://www.iium.edu.my/media/72543/download',
    'UIAM': 'https://www.iium.edu.my/media/72543/download',
    'UMS': 'https://www.ums.edu.my/v5/images/banner/ums-banner.jpg',
    'UNIMAS': 'https://www.unimas.my/images/headers/unimas-aerial.jpg',
    'UMP': 'https://www.ump.edu.my/images/buildings/ump-main.jpg',
    'UMPSA': 'https://www.ump.edu.my/images/buildings/ump-main.jpg',
    'UMT': 'https://www.umt.edu.my/images/umt-aerial.jpg',
    'UUM': 'https://www.uum.edu.my/images/campus/uum-main.jpg',
    'UPSI': 'https://www.upsi.edu.my/images/campus/upsi-main.jpg',
    'UTHM': 'https://www.uthm.edu.my/images/campus/uthm-main.jpg',
    'UTeM': 'https://www.utem.edu.my/images/campus/utem-main.jpg',
    'UTEM': 'https://www.utem.edu.my/images/campus/utem-main.jpg',
    'MMU': 'https://www.mmu.edu.my/images/campus/mmu-cyberjaya.jpg',
    'UTAR': 'https://www.utar.edu.my/images/campus/utar-main.jpg',
    'SUNWAY': 'https://university.sunway.edu.my/images/campus/sunway-main.jpg',
    'TAYLOR': 'https://university.taylors.edu.my/images/campus/taylors-main.jpg',
    'APU': 'https://www.apu.edu.my/images/campus/apu-main.jpg',
    'UCSI': 'https://www.ucsiuniversity.edu.my/images/campus/ucsi-main.jpg',
  };

  // Colors for each university (for gradient backgrounds)
  static const Map<String, List<Color>> _universityColors = {
    'UM': [Color(0xFF003366), Color(0xFF004080)],
    'UPM': [Color(0xFF800000), Color(0xFFB00000)],
    'UKM': [Color(0xFF800000), Color(0xFFB22222)],
    'USM': [Color(0xFFFFD700), Color(0xFFFFA500)],
    'UTM': [Color(0xFF8B0000), Color(0xFFCD5C5C)],
    'UIAM': [Color(0xFF008000), Color(0xFF2E8B57)],
    'IIUM': [Color(0xFF008000), Color(0xFF2E8B57)],
    'UiTM': [Color(0xFF4B0082), Color(0xFF8A2BE2)],
    'UITM': [Color(0xFF4B0082), Color(0xFF8A2BE2)],
    'UMS': [Color(0xFF0066CC), Color(0xFF3399FF)],
    'UNIMAS': [Color(0xFF006699), Color(0xFF0099CC)],
    'UMP': [Color(0xFF003399), Color(0xFF0055AA)],
    'UMPSA': [Color(0xFF003399), Color(0xFF0055AA)],
    'UMT': [Color(0xFF0077B6), Color(0xFF00B4D8)],
    'UNIMAP': [Color(0xFF1E3A5F), Color(0xFF3D5A80)],
    'UMK': [Color(0xFF228B22), Color(0xFF32CD32)],
    'UPSI': [Color(0xFF4169E1), Color(0xFF6495ED)],
    'USIM': [Color(0xFF006400), Color(0xFF32CD32)],
    'UTeM': [Color(0xFF800020), Color(0xFFB22222)],
    'UTEM': [Color(0xFF800020), Color(0xFFB22222)],
    'UTHM': [Color(0xFF191970), Color(0xFF4169E1)],
    'UUM': [Color(0xFF8B4513), Color(0xFFCD853F)],
    'UPNM': [Color(0xFF2F4F4F), Color(0xFF556B2F)],
    'MMU': [Color(0xFF0047AB), Color(0xFF4682B4)],
    'UNITEN': [Color(0xFFCC0000), Color(0xFFFF3333)],
    'UTAR': [Color(0xFF003366), Color(0xFF336699)],
    'SUNWAY': [Color(0xFFFF6600), Color(0xFFFF9933)],
    'TAYLOR': [Color(0xFF6B0F1A), Color(0xFF9E1B32)],
    'APU': [Color(0xFF1E90FF), Color(0xFF00BFFF)],
    'HELP': [Color(0xFF8B0000), Color(0xFFDC143C)],
    'UCSI': [Color(0xFF003366), Color(0xFF4682B4)],
    'MONASH': [Color(0xFF003366), Color(0xFF005599)],
    'NOTTINGHAM': [Color(0xFF003D71), Color(0xFF0066B3)],
  };

  /// Get university colors for gradient
  static List<Color> getColors(String? universityId) {
    if (universityId == null || universityId.isEmpty) {
      return [const Color(0xFF800000), const Color(0xFFB00000)];
    }
    return _universityColors[universityId.toUpperCase()] ??
           _generateColorsFromName(universityId);
  }

  /// Generate consistent colors from university name/id
  static List<Color> _generateColorsFromName(String name) {
    final hash = name.toUpperCase().codeUnits.fold(0, (prev, curr) => prev + curr);
    final hue = (hash % 360).toDouble();
    return [
      HSLColor.fromAHSL(1.0, hue, 0.6, 0.35).toColor(),
      HSLColor.fromAHSL(1.0, hue, 0.5, 0.45).toColor(),
    ];
  }

  /// Get initials for universities without logos
  static String getInitials(String? universityId, String? universityName) {
    if (universityId != null && universityId.isNotEmpty) {
      // Use short name if available
      return universityId.toUpperCase().substring(0, universityId.length.clamp(1, 3));
    }
    if (universityName != null && universityName.isNotEmpty) {
      // Generate from full name
      final words = universityName.split(' ').where((w) => w.isNotEmpty).toList();
      if (words.length >= 2) {
        return '${words[0][0]}${words[1][0]}'.toUpperCase();
      }
      return universityName.substring(0, universityName.length.clamp(1, 2)).toUpperCase();
    }
    return 'U';
  }

  /// Get image URL for a university
  static String? getImageUrl(String? universityId) {
    if (universityId == null || universityId.isEmpty) return null;
    return _universityImages[universityId.toUpperCase()];
  }

  /// Build a watermark widget for course cards
  static Widget buildWatermark({
    required String? universityId,
    required String? universityName,
    double opacity = 0.08,
    double size = 80,
  }) {
    final imageUrl = getImageUrl(universityId);

    if (imageUrl != null) {
      // Use university building image as watermark
      return Opacity(
        opacity: opacity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.15),
          child: Image.network(
            imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to initials if image fails to load
              return _buildInitialsWatermark(
                universityId: universityId,
                universityName: universityName,
                opacity: 1.0, // Already wrapped in Opacity
                size: size,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              // Show initials while loading
              return _buildInitialsWatermark(
                universityId: universityId,
                universityName: universityName,
                opacity: 1.0,
                size: size,
              );
            },
          ),
        ),
      );
    } else {
      // Use stylized initials for unknown universities
      return _buildInitialsWatermark(
        universityId: universityId,
        universityName: universityName,
        opacity: opacity,
        size: size,
      );
    }
  }

  /// Build a full background image for cards
  static Widget buildFullBackground({
    required String? universityId,
    required String? universityName,
    double opacity = 0.15,
  }) {
    final imageUrl = getImageUrl(universityId);

    if (imageUrl != null) {
      // Use university building image as full background
      return Opacity(
        opacity: opacity,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to gradient if image fails to load
            return _buildGradientBackground(
              universityId: universityId,
              opacity: 1.0,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            // Show gradient while loading
            return _buildGradientBackground(
              universityId: universityId,
              opacity: 1.0,
            );
          },
        ),
      );
    } else {
      // Use gradient background for unknown universities
      return _buildGradientBackground(
        universityId: universityId,
        opacity: opacity,
      );
    }
  }

  static Widget _buildGradientBackground({
    required String? universityId,
    double opacity = 0.15,
  }) {
    final colors = getColors(universityId);
    final safeOpacity = opacity.clamp(0.0, 1.0);

    return Opacity(
      opacity: safeOpacity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors[0], colors[1]],
          ),
        ),
      ),
    );
  }

  /// Build a beautiful card background - image if available, gorgeous gradient if not
  static Widget buildCardBackground({
    required String? universityId,
    required String? universityName,
    double imageOpacity = 0.2,
    bool showOverlay = true,
  }) {
    final imageUrl = getImageUrl(universityId);
    final colors = getColors(universityId);

    if (imageUrl != null) {
      // Has image - show image with subtle overlay
      return Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: imageOpacity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildBeautifulGradient(colors);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildBeautifulGradient(colors);
              },
            ),
          ),
          if (showOverlay)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
        ],
      );
    } else {
      // No image - show beautiful gradient
      return _buildBeautifulGradient(colors);
    }
  }

  /// Build a gorgeous gradient with mesh-like effect
  static Widget _buildBeautifulGradient(List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0].withValues(alpha: 0.15),
            colors[1].withValues(alpha: 0.08),
            colors[0].withValues(alpha: 0.05),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              colors[1].withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  /// Build course detail header background - full image with dark overlay
  static Widget buildDetailBackground({
    required String? universityId,
    required String? universityName,
  }) {
    final imageUrl = getImageUrl(universityId);
    final colors = getColors(universityId);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image or gradient
        if (imageUrl != null)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: colors,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: colors,
                  ),
                ),
              );
            },
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
          ),
        // Dark gradient overlay for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.6),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildInitialsWatermark({
    required String? universityId,
    required String? universityName,
    double opacity = 0.08,
    double size = 80,
  }) {
    final initials = getInitials(universityId, universityName);
    final colors = getColors(universityId);

    // Clamp opacity to valid range (0.0 - 1.0)
    final safeOpacity = (opacity + 0.05).clamp(0.0, 1.0);

    return Opacity(
      opacity: safeOpacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
