import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/course_list_viewmodel.dart';
import '../models/course.dart';
import 'course_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFaculty = 'All';
  final List<String> _faculties = ['All', 'FSKTM', 'FEP', 'FPP', 'FBMK', 'Gen'];

  @override
  void initState() {
    super.initState();
    // Fetch courses when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseListViewModel>().fetchCourses();
    });
  }

  List<Course> _filterCourses(List<Course> courses) {
    if (_selectedFaculty == 'All') {
      return courses;
    }
    return courses.where((course) => course.facultyShort == _selectedFaculty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Discover Courses"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Faculty Filter Tabs
          _buildFacultyFilter(),

          // Course List
          Expanded(
            child: Consumer<CourseListViewModel>(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF800000),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => viewModel.fetchCourses(),
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                final filteredCourses = _filterCourses(viewModel.courses);

                if (filteredCourses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No courses found",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.refreshCourses(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(15),
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(context, filteredCourses[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyFilter() {
    return Container(
      height: 50,
      color: Colors.grey[100],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: _faculties.length,
        itemBuilder: (context, index) {
          final faculty = _faculties[index];
          final isSelected = _selectedFaculty == faculty;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: ChoiceChip(
              label: Text(faculty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFaculty = faculty;
                });
              },
              selectedColor: Color(0xFF800000),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              elevation: isSelected ? 2 : 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: Color(0xFF800000).withValues(alpha: 0.1),
          child: Text(
            course.id.substring(0, 3),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF800000),
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          course.id,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.name),
            SizedBox(height: 5),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    course.facultyShort,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Icon(Icons.star, size: 14, color: Colors.amber),
                Text(" ${course.averageRating.toStringAsFixed(1)} (${course.totalReviews})"),
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
