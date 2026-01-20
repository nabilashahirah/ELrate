import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'auth/login_screen.dart';
import '../utils/responsive.dart';
class SplashIntroScreen extends StatefulWidget {
  const SplashIntroScreen({Key? key}) : super(key: key);

  @override
  State<SplashIntroScreen> createState() => _SplashIntroScreenState();
}

class _SplashIntroScreenState extends State<SplashIntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF800000),
              Color(0xFF500000),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(30),
                    vertical: responsive.spacing(20), // Reduced vertical padding
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      // Logo / Icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(responsive.spacing(30)),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: responsive.spacing(20),
                                offset: Offset(0, responsive.spacing(10)),
                              )
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            width: responsive.logoSize,
                            height: responsive.logoSize,
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.spacing(40)),

                      // Animated Text Content
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Text(
                                "ELRate",
                                style: TextStyle(
                                  fontSize: responsive.sp(42),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: responsive.spacing(12)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: responsive.spacing(16),
                                    vertical: responsive.spacing(6)),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(
                                      responsive.spacing(20)),
                                ),
                                child: Text(
                                  "UPM Course Rating System",
                                  style: TextStyle(
                                    fontSize: responsive.sp(14),
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: responsive.spacing(40)),
                              Text(
                                "Discover what students are saying about courses.\nRead reviews, check ratings, and choose wisely.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: responsive.sp(16),
                                  color: Colors.white.withOpacity(0.85),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Spacer(),

                      // Get Started Button
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: responsive.buttonHeight,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Check if user has completed onboarding before
                              final hasCompleted = await OnboardingScreen.hasCompletedOnboarding();

                              if (!context.mounted) return;

                              if (hasCompleted) {
                                // Skip onboarding, go directly to login
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginScreen()),
                                );
                              } else {
                                // First time user, show onboarding
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF800000),
                              elevation: 4,
                              shadowColor: Colors.black45,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    responsive.spacing(16)),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Get Started",
                                  style: TextStyle(
                                    fontSize: responsive.sp(18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: responsive.spacing(8)),
                                Icon(Icons.arrow_forward_rounded,
                                    size: responsive.iconSize(24)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}