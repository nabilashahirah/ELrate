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

  @override
  void initState() {
    super.initState();
    // Fetch courses when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseListViewModel>().fetchCourses();
    });
  }

  List<Course> _getTopRated(List<Course> courses) {
    final sorted = List<Course>.from(courses);
    sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return sorted.take(5).toList();
  }

  List<Course> _getMostReviewed(List<Course> courses) {
    final sortedList = List<Course>.from(courses);
    sortedList.sort((a, b) => b.totalReviews.compareTo(a.totalReviews));
    return sortedList.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Campus Hub"),
        elevation: 0,
      ),
      body: Consumer<CourseListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.courses.isEmpty) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFF800000)));
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

                final topRated = _getTopRated(viewModel.courses);
                final mostReviewed = _getMostReviewed(viewModel.courses);
                final allCourses = viewModel.courses;


                return RefreshIndicator(
                  onRefresh: () => viewModel.refreshCourses(),
                  child: CustomScrollView(
                    slivers: [
                      // Top Rated Section
                      SliverToBoxAdapter(
                        child: _buildSectionHeader("Top Rated", Icons.star_rounded),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          height: 180,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: topRated.length,
                            separatorBuilder: (context, index) => SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              return _buildFeaturedCourseCard(context, topRated[index]);
                            },
                          ),
                        ),
                      ),

                      // Most Reviewed Section
                      SliverToBoxAdapter(
                        child: _buildSectionHeader("Most Reviewed", Icons.rate_review_rounded),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          height: 180,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: mostReviewed.length,
                            separatorBuilder: (context, index) => SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              return _buildFeaturedCourseCard(context, mostReviewed[index]);
                            },
                          ),
                        ),
                      ),

                      // All Courses Section
                      SliverToBoxAdapter(
                        child: _buildSectionHeader("All Courses", Icons.library_books_rounded),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: _buildCourseCard(context, allCourses[index]),
                              );
                            },
                            childCount: allCourses.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF800000).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF800000), size: 20),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourseCard(BuildContext context, Course course) {
    return Container(
      width: 160,
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF800000),
                Color(0xFFA00000),
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
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
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course.facultyShort,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              course.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      course.id,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      course.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${course.totalReviews} Reviews",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF800000).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  course.id.substring(0, min(3, course.id.length)),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800000),
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.id,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF800000),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      course.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            course.facultyShort,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          course.averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          " (${course.totalReviews})",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}
