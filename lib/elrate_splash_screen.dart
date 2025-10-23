import 'package:flutter/material.dart';

class ElrateSplashScreen extends StatelessWidget {
  const ElrateSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand( // Ensures the image fills the entire screen
        child: Image.asset(
          'assets/images/elrate_splash.png', // <--- Your image path here
          fit: BoxFit.cover, // Fills the screen while maintaining aspect ratio
        ),
      ),
    );
  }
}

// Remove the WavyLinesPainter class, as it's no longer needed for the background.
// If you want to keep it in case you need it later, you can.
// class WavyLinesPainter extends CustomPainter { ... }