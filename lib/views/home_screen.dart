import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/course_list_viewmodel.dart';
import '../models/course.dart';
import '../models/review.dart';
import '../utils/responsive.dart';
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
    // Filter courses with at least 3 reviews to ensure rating credibility
    final eligible = courses.where((course) => course.totalReviews >= 3).toList();

    // Sort by average rating (descending), then by total reviews (descending) as tiebreaker
    eligible.sort((a, b) {
      final ratingComparison = b.averageRating.compareTo(a.averageRating);
      if (ratingComparison != 0) return ratingComparison;
      return b.totalReviews.compareTo(a.totalReviews);
    });

    return eligible.take(5).toList();
  }

  List<Course> _getMostReviewed(List<Course> courses) {
    // Filter courses with at least 1 review
    final eligible = courses.where((course) => course.totalReviews > 0).toList();

    // Sort by total reviews (descending), then by rating (descending) as tiebreaker
    eligible.sort((a, b) {
      final reviewsComparison = b.totalReviews.compareTo(a.totalReviews);
      if (reviewsComparison != 0) return reviewsComparison;
      return b.averageRating.compareTo(a.averageRating);
    });

    return eligible.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

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
                final latestReviews = viewModel.latestReviews;


                return RefreshIndicator(
                  onRefresh: () => viewModel.refreshCourses(),
                  child: CustomScrollView(
                    slivers: [
                      // Top Rated Section
                      SliverToBoxAdapter(
                        child: _buildSectionHeader(context, "Top Rated", Icons.star_rounded),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          height: responsive.cardHeight,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                            scrollDirection: Axis.horizontal,
                            itemCount: topRated.length,
                            separatorBuilder: (context, index) => SizedBox(width: responsive.spacing(16)),
                            itemBuilder: (context, index) {
                              return _buildFeaturedCourseCard(context, topRated[index]);
                            },
                          ),
                        ),
                      ),

                      // Most Reviewed Section
                      SliverToBoxAdapter(
                        child: _buildSectionHeader(context, "Most Reviewed", Icons.rate_review_rounded),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          height: responsive.cardHeight,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                            scrollDirection: Axis.horizontal,
                            itemCount: mostReviewed.length,
                            separatorBuilder: (context, index) => SizedBox(width: responsive.spacing(16)),
                            itemBuilder: (context, index) {
                              return _buildFeaturedCourseCard(context, mostReviewed[index]);
                            },
                          ),
                        ),
                      ),

                      // What People Say Section
                      SliverToBoxAdapter(
                        child: _buildSectionHeader(context, "What People Say", Icons.forum_rounded),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing(20),
                          vertical: responsive.spacing(10),
                        ),
                        sliver: latestReviews.isEmpty
                            ? SliverToBoxAdapter(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(responsive.spacing(32)),
                                    child: Text(
                                      "No reviews yet",
                                      style: TextStyle(color: Colors.grey[600], fontSize: responsive.sp(14)),
                                    ),
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: responsive.spacing(16)),
                                      child: _buildReviewCard(context, latestReviews[index], viewModel.courses),
                                    );
                                  },
                                  childCount: latestReviews.length,
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

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final responsive = context.responsive;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.spacing(20),
        responsive.spacing(24),
        responsive.spacing(20),
        responsive.spacing(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(responsive.spacing(8)),
            decoration: BoxDecoration(
              color: Color(0xFF800000).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Color(0xFF800000),
              size: responsive.iconSize(20),
            ),
          ),
          SizedBox(width: responsive.spacing(12)),
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.sp(18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourseCard(BuildContext context, Course course) {
    final responsive = context.responsive;
    return Container(
      width: responsive.cardWidth,
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
                padding: EdgeInsets.all(responsive.spacing(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(8),
                            vertical: responsive.spacing(4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course.facultyShort,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.sp(10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: responsive.iconSize(16),
                              color: Colors.amber,
                            ),
                            SizedBox(width: responsive.spacing(4)),
                            Text(
                              course.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: responsive.sp(12),
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
                        fontSize: responsive.sp(18),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      course.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: responsive.sp(12),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(8)),
                    Text(
                      "${course.totalReviews} Reviews",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: responsive.sp(11),
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

  Widget _buildReviewCard(BuildContext context, Review review, List<Course> courses) {
    final responsive = context.responsive;

    // Find the course for this review
    final course = courses.firstWhere(
      (c) => c.id == review.courseId,
      orElse: () => Course(
        id: review.courseId,
        name: "Unknown Course",
        faculty: "",
        facultyShort: "Gen",
        description: "",
        averageRating: 0.0,
        totalReviews: 0,
      ),
    );

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // Navigate to course detail
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
          padding: EdgeInsets.all(responsive.spacing(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with course info and rating
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.id,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF800000),
                            fontSize: responsive.sp(12),
                          ),
                        ),
                        SizedBox(height: responsive.spacing(2)),
                        Text(
                          course.name,
                          style: TextStyle(
                            fontSize: responsive.sp(13),
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  // Rating stars
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating.floor()
                            ? Icons.star_rounded
                            : (index < review.rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                        size: responsive.iconSize(16),
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(12)),

              // Review comment
              Text(
                review.comment,
                style: TextStyle(
                  fontSize: responsive.sp(14),
                  height: 1.4,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: responsive.spacing(12)),

              // Footer with student name and timestamp
              Row(
                children: [
                  Icon(Icons.person_outline, size: responsive.iconSize(14), color: Colors.grey[600]),
                  SizedBox(width: responsive.spacing(4)),
                  Text(
                    review.isAnonymous ? "Anonymous" : review.studentName,
                    style: TextStyle(
                      fontSize: responsive.sp(12),
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  if (review.timestamp != null) ...[
                    Icon(Icons.access_time, size: responsive.iconSize(14), color: Colors.grey[600]),
                    SizedBox(width: responsive.spacing(4)),
                    Text(
                      _formatTimestamp(review.timestamp!),
                      style: TextStyle(
                        fontSize: responsive.sp(12),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    } else if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }

  int min(int a, int b) => a < b ? a : b;
}
