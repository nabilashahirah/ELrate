import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/course_list_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/main_navigation.dart';
import 'views/auth/login_screen.dart';

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
          primaryColor: Color(0xFF800000), // UPM Maroon
          scaffoldBackgroundColor: Colors.grey[50],
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF800000),
            foregroundColor: Colors.white,
            elevation: 0,
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
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: 80,
                    color: Color(0xFF800000),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "ELRate",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF800000),
                    ),
                  ),
                  SizedBox(height: 40),
                  CircularProgressIndicator(
                    color: Color(0xFF800000),
                  ),
                ],
              ),
            ),
          );
        }

        // Show main app if authenticated, login screen otherwise
        return authViewModel.isAuthenticated ? MainNavigation() : LoginScreen();
      },
    );
  }
}