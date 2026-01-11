import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/course_list_viewmodel.dart';
import 'views/course_list_screen.dart';

void main() {
  runApp(ELRateApp());
}

class ELRateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseListViewModel()),
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
        home: CourseListScreen(),
      ),
    );
  }
}