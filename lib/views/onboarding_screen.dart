import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  /// Check if user has completed onboarding before
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Using Google Drive direct URLs for GIFs
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "gif": "https://drive.google.com/uc?export=view&id=1aPa1QtDb0nqiI-RbWg7Kvqp4MYcM7nrs",
      "title": "Feeling Lost?",
      "desc": "We get it — choosing courses can be overwhelming. Let us help you figure it out!",
      "icon": Icons.psychology_outlined,
      "color": Color(0xFFE57373),
    },
    {
      "gif": "https://drive.google.com/uc?export=view&id=1EmJKAd9kwAw5Q4EkFijkY7wFIsIs8_wW",
      "title": "Find What You Need",
      "desc": "Search courses, check the syllabus, and know exactly what you're signing up for.",
      "icon": Icons.search_rounded,
      "color": Color(0xFF64B5F6),
    },
    {
      "gif": "https://drive.google.com/uc?export=view&id=1EsGykCkWpXtUUNHDqDp1YqlxehU88EP1",
      "title": "Hear From Your Peers",
      "desc": "Real reviews from real students. No sugar-coating — just honest opinions to help you decide.",
      "icon": Icons.rate_review_rounded,
      "color": Color(0xFF81C784),
    },
    {
      "gif": "https://drive.google.com/uc?export=view&id=1HSRhRqXv3uX5qSwTdMFZWDQ2oDfO4ArF",
      "title": "Help Your Juniors",
      "desc": "Took a course? Share your experience! Your review could save someone's semester.",
      "icon": Icons.add_circle_outline_rounded,
      "color": Color(0xFFFFB74D),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    // Animate content on page change
    _fadeController.reset();
    _scaleController.reset();
    _fadeController.forward();
    _scaleController.forward();
  }

  void _completeOnboarding() async {
    await OnboardingScreen.setOnboardingCompleted();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF800000);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade500,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return _buildOnboardingPage(
                    gifUrl: data["gif"],
                    title: data["title"],
                    desc: data["desc"],
                    icon: data["icon"],
                    accentColor: data["color"],
                    primaryColor: primaryColor,
                    isSmallScreen: isSmallScreen,
                  );
                },
              ),
            ),

            // Bottom section with indicators and button
            _buildBottomSection(primaryColor, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String gifUrl,
    required String title,
    required String desc,
    required IconData icon,
    required Color accentColor,
    required Color primaryColor,
    required bool isSmallScreen,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            SizedBox(height: isSmallScreen ? 10 : 30),

            // GIF Container with decorative elements
            ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background decoration circles
                  Positioned(
                    top: 10,
                    right: 20,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.08),
                      ),
                    ),
                  ),

                  // Main GIF container
                  Container(
                    height: isSmallScreen ? 220 : 280,
                    width: isSmallScreen ? 220 : 280,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // GIF Image
                        Positioned.fill(
                          child: Image.network(
                            gifUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        color: accentColor,
                                        strokeWidth: 3,
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Loading...",
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        icon,
                                        size: 60,
                                        color: accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Subtle gradient overlay at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.grey.shade50.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 30 : 50),

            // Icon badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 28,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 26 : 30,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  color: Colors.grey.shade600,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(Color primaryColor, bool isSmallScreen) {
    final isLastPage = _currentPage == _onboardingData.length - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(32, 20, 32, isSmallScreen ? 24 : 40),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 8,
                width: _currentPage == index ? 32 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _currentPage == index
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Navigation button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton(
                key: ValueKey<bool>(isLastPage),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: isLastPage ? 8 : 2,
                  shadowColor: primaryColor.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (isLastPage) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastPage ? "Get Started" : "Next",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isLastPage ? 0.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isLastPage
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_forward_rounded,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Page counter
          const SizedBox(height: 16),
          Text(
            "${_currentPage + 1} of ${_onboardingData.length}",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
