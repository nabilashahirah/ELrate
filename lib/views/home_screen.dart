import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/course_list_viewmodel.dart';
import '../models/course.dart';
import '../models/review.dart';
import '../utils/responsive.dart';
import '../utils/university_assets.dart';
import 'course_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAll;

  const HomeScreen({Key? key, this.onSeeAll}) : super(key: key);

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
        title: Text("ELRate"),
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
                      // Intro Banner
                      SliverToBoxAdapter(child: _buildIntroBanner(responsive)),

                      // Top Rated Section
                      SliverToBoxAdapter(
                        child: _buildSectionHeader(
                          context, 
                          "Top Rated", 
                          Icons.star_rounded,
                          showSeeAll: true,
                        ),
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
                              return _buildFeaturedCourseCard(context, topRated[index], index, isTopRated: true);
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
                              return _buildFeaturedCourseCard(context, mostReviewed[index], index, isTopRated: false);
                            },
                          ),
                        ),
                      ),

                      // What People Say Section
                      SliverToBoxAdapter(
                        child: _buildSectionHeader(context, "What People Say", Icons.forum_rounded),
                      ),
                      SliverToBoxAdapter(
                        child: latestReviews.isEmpty
                            ? Padding(
                                padding: EdgeInsets.all(responsive.spacing(32)),
                                child: Center(
                                  child: Text(
                                    "No reviews yet",
                                    style: TextStyle(color: Colors.grey[600], fontSize: responsive.sp(14)),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: responsive.isMobile ? 200 : 220,
                                child: ListView.separated(
                                  padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: latestReviews.length,
                                  separatorBuilder: (context, index) => SizedBox(width: responsive.spacing(12)),
                                  itemBuilder: (context, index) {
                                    return _buildReviewCard(context, latestReviews[index], viewModel.courses, responsive);
                                  },
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

  Widget _buildIntroBanner(Responsive responsive) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        responsive.spacing(20),
        responsive.spacing(20),
        responsive.spacing(20),
        responsive.spacing(8),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF800000).withOpacity(0.25),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Gradient - More colorful with gold accent
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF800000),
                      Color(0xFF9A0000),
                      Color(0xFFB8860B).withValues(alpha: 0.8),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Decorative Elements
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              right: 40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 40,
              child: Icon(
                Icons.school_outlined,
                size: 100,
                color: Colors.white.withOpacity(0.05),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(responsive.spacing(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(12),
                      vertical: responsive.spacing(6),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tips_and_updates_rounded,
                          color: Colors.amber[300],
                          size: responsive.iconSize(16),
                        ),
                        SizedBox(width: responsive.spacing(8)),
                        Text(
                          "Welcome to ELRate",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: responsive.sp(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: responsive.spacing(16)),
                  Text(
                    "Plan Your Semester\nWith Confidence",
                    style: TextStyle(
                      fontSize: responsive.sp(24),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(12)),
                  Text(
                    "Get insights on subjects you take, plan ahead for next semester, and help juniors by reviewing courses.",
                    style: TextStyle(
                      fontSize: responsive.sp(14),
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {bool showSeeAll = false}) {
    final responsive = context.responsive;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.spacing(20),
        responsive.spacing(24),
        responsive.spacing(20),
        responsive.spacing(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.spacing(8)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF800000), Color(0xFFB00000)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF800000).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
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
          if (showSeeAll && widget.onSeeAll != null)
            TextButton(
              onPressed: widget.onSeeAll,
              child: Text(
                "See All",
                style: TextStyle(color: Color(0xFF800000), fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourseCard(BuildContext context, Course course, int index, {bool isTopRated = true}) {
    final responsive = context.responsive;
    final universityColors = UniversityAssets.getColors(course.universityId);

    return Container(
      width: responsive.cardWidth,
      child: Card(
        elevation: 4,
        shadowColor: universityColors[0].withValues(alpha: 0.4),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background - University image or beautiful gradient
            UniversityAssets.buildCardBackground(
              universityId: course.universityId,
              universityName: course.universityName,
              imageOpacity: 0.85,
              showOverlay: false,
            ),
            // Dark gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
            // Content
            Material(
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
                  padding: EdgeInsets.all(responsive.spacing(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row - Tags and Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.spacing(8),
                                  vertical: responsive.spacing(4),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  course.facultyShort,
                                  style: TextStyle(
                                    color: universityColors[0],
                                    fontSize: responsive.sp(10),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: responsive.spacing(6)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.spacing(8),
                                  vertical: responsive.spacing(4),
                                ),
                                decoration: BoxDecoration(
                                  color: universityColors[0],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  course.universityId ?? 'UPM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.sp(10),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Rating badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.spacing(8),
                              vertical: responsive.spacing(4),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: responsive.iconSize(14),
                                  color: Colors.white,
                                ),
                                SizedBox(width: responsive.spacing(2)),
                                Text(
                                  course.averageRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: responsive.sp(11),
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // Course code
                      Text(
                        course.id,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: responsive.sp(20),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsive.spacing(4)),
                      // Course name
                      Text(
                        course.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: responsive.sp(12),
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsive.spacing(8)),
                      // Reviews count
                      Row(
                        children: [
                          Icon(
                            Icons.rate_review_rounded,
                            size: responsive.iconSize(14),
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          SizedBox(width: responsive.spacing(4)),
                          Text(
                            "${course.totalReviews} Reviews",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: responsive.sp(11),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review, List<Course> courses, Responsive responsive) {

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

    return _ReviewCardExpanding(
      review: review,
      course: course,
      responsive: responsive,
    );
  }
}

class _ReviewCardExpanding extends StatefulWidget {
  final Review review;
  final Course course;
  final Responsive responsive;

  const _ReviewCardExpanding({
    required this.review,
    required this.course,
    required this.responsive,
  });

  @override
  State<_ReviewCardExpanding> createState() => _ReviewCardExpandingState();
}

class _ReviewCardExpandingState extends State<_ReviewCardExpanding> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final responsive = widget.responsive;
    final course = widget.course;
    final review = widget.review;

    return SizedBox(
      width: responsive.isMobile ? 280 : 320,
      child: Card(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(responsive.spacing(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with course info and faculty tag
                Row(
                  children: [
                    // Course icon/avatar
                    Container(
                      width: responsive.isMobile ? 32 : 36,
                      height: responsive.isMobile ? 32 : 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF800000),
                            Color(0xFFA00000),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        course.id.substring(0, min(3, course.id.length)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: responsive.sp(10),
                        ),
                      ),
                    ),
                    SizedBox(width: responsive.spacing(6)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  course.id,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF800000),
                                    fontSize: responsive.sp(10),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: responsive.spacing(3)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.spacing(3),
                                  vertical: responsive.spacing(1),
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF800000).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  course.facultyShort,
                                  style: TextStyle(
                                    fontSize: responsive.sp(7),
                                    color: Color(0xFF800000),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: responsive.spacing(3)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.spacing(3),
                                  vertical: responsive.spacing(1),
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF800000),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  course.universityId ?? 'UPM',
                                  style: TextStyle(
                                    fontSize: responsive.sp(7),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: responsive.spacing(1)),
                          Text(
                            course.name,
                            style: TextStyle(
                              fontSize: responsive.sp(9),
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.spacing(6)),

                // Rating stars with visual emphasis
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(5),
                    vertical: responsive.spacing(3),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < review.rating.floor()
                              ? Icons.star_rounded
                              : (index < review.rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                          size: responsive.iconSize(11),
                          color: Colors.amber[700],
                        );
                      }),
                      SizedBox(width: responsive.spacing(3)),
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: responsive.sp(10),
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: responsive.spacing(6)),

                // Review comment with quote styling
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: responsive.spacing(6)),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Color(0xFF800000).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"${review.comment}"',
                          style: TextStyle(
                            fontSize: responsive.sp(11),
                            height: 1.3,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: _isExpanded ? null : 2,
                          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                        if (review.comment.length > 100 && !_isExpanded)
                          Padding(
                            padding: EdgeInsets.only(top: responsive.spacing(2)),
                            child: Text(
                              "Tap to read more",
                              style: TextStyle(
                                fontSize: responsive.sp(9),
                                color: Color(0xFF800000),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: responsive.spacing(6)),

                // Footer with student name and timestamp
                Row(
                  children: [
                    // Student avatar/icon
                    CircleAvatar(
                      radius: responsive.isMobile ? 10 : 12,
                      backgroundColor: Color(0xFF800000).withOpacity(0.1),
                      child: Icon(
                        review.isAnonymous ? Icons.person_off_outlined : Icons.person,
                        size: responsive.iconSize(12),
                        color: Color(0xFF800000),
                      ),
                    ),
                    SizedBox(width: responsive.spacing(4)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            review.isAnonymous ? "Anonymous" : review.studentName,
                            style: TextStyle(
                              fontSize: responsive.sp(10),
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (review.timestamp != null)
                            Text(
                              _formatTimestamp(review.timestamp!),
                              style: TextStyle(
                                fontSize: responsive.sp(9),
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Recommended badge
                    if (review.isRecommended)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing(4),
                          vertical: responsive.spacing(2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green[300]!, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: responsive.iconSize(9),
                              color: Colors.green[700],
                            ),
                            SizedBox(width: responsive.spacing(2)),
                            Text(
                              "Rec",
                              style: TextStyle(
                                fontSize: responsive.sp(8),
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
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
