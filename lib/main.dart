import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/course_list_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'utils/responsive.dart';
import 'views/main_navigation.dart';
import 'views/splash_intro_screen.dart';

void main() {
  runApp(ELRateApp());
}

class ELRateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CourseListViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ELRate',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF800000), // UPM Maroon
            primary: Color(0xFF800000),
            secondary: Color(0xFFD4AF37), // Gold accent
            surface: Colors.grey[50],
          ),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF800000),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

/// Wrapper to check authentication status and show appropriate screen
class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Show loading while checking auth status
        if (authViewModel.isLoading) {
          // Use Builder to access context with MediaQuery
          return Scaffold(
            backgroundColor: Colors.white,
            body: Builder(
              builder: (context) {
                final responsive = context.responsive;
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(responsive.spacing(24)),
                                decoration: BoxDecoration(
                                  color: Color(0xFF800000).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: responsive.logoSize * 0.64,
                                  height: responsive.logoSize * 0.64,
                                  color: Color(0xFF800000),
                                ),
                              ),
                              SizedBox(height: responsive.spacing(32)),
                              CircularProgressIndicator(
                                color: Color(0xFF800000),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        // Show main app if authenticated, login screen otherwise
        return authViewModel.isAuthenticated ? MainNavigation() : SplashIntroScreen();
      },
    );
  }
}