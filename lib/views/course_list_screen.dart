import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/course_list_viewmodel.dart';
import '../models/course.dart';
import '../utils/responsive.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch courses when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseListViewModel>().fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ELRate Subjects")),
      body: Consumer<CourseListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.courses.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFF800000),
              ),
            );
          }

          if (viewModel.errorMessage != null && viewModel.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    "Error loading courses",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchCourses(),
                    child: Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refreshCourses(),
            child: ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: viewModel.courses.length,
              itemBuilder: (context, index) {
                return _buildCourseCard(context, viewModel.courses[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    final responsive = context.responsive;
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: responsive.spacing(15)),
      child: ListTile(
        contentPadding: EdgeInsets.all(responsive.spacing(15)),
        leading: CircleAvatar(
          radius: responsive.avatarSize * 0.5,
          backgroundColor: Color(0xFF800000).withValues(alpha: 0.1),
          child: Text(
            course.id.substring(0, 3),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF800000),
              fontSize: responsive.sp(12),
            ),
          ),
        ),
        title: Text(
          course.id,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: responsive.sp(14),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name,
              style: TextStyle(fontSize: responsive.sp(13)),
            ),
            SizedBox(height: responsive.spacing(5)),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(8),
                    vertical: responsive.spacing(2),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    course.facultyShort,
                    style: TextStyle(
                      fontSize: responsive.sp(10),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.star,
                  size: responsive.iconSize(14),
                  color: Colors.amber,
                ),
                Text(
                  " ${course.averageRating.toStringAsFixed(1)} (${course.totalReviews})",
                  style: TextStyle(fontSize: responsive.sp(12)),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          // Navigate to course detail and refresh when coming back
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(course: course),
            ),
          );
          if (context.mounted) {
            context.read<CourseListViewModel>().refreshCourses();
          }
        },
      ),
    );
  }
}
