import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../models/review.dart';
import '../viewmodels/course_detail_viewmodel.dart';
import 'add_review_screen.dart';
import '../utils/responsive.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({required this.course});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CourseDetailViewModel(course: course)..fetchReviews(),
      child: _CourseDetailView(course: course),
    );
  }
}

class _CourseDetailView extends StatelessWidget {
  final Course course;

  const _CourseDetailView({required this.course});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Scaffold(
      body: Consumer<CourseDetailViewModel>(
        builder: (context, viewModel, child) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(responsive.spacing(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseStats(responsive),
                      SizedBox(height: responsive.spacing(24)),
                      Text(
                        "About this course",
                        style: TextStyle(
                          fontSize: responsive.sp(18),
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF800000),
                        ),
                      ),
                      SizedBox(height: responsive.spacing(12)),
                      Text(
                        course.description,
                        style: TextStyle(
                          fontSize: responsive.sp(15),
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: responsive.spacing(32)),
                      _buildReviewsHeader(viewModel, responsive),
                    ],
                  ),
                ),
              ),
              _buildReviewsList(viewModel, responsive),
              SliverToBoxAdapter(
                child: _buildLoadMoreButton(viewModel, responsive),
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: responsive.spacing(80))),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF800000),
        icon: Icon(Icons.edit, color: Colors.white),
        label: Text("Write Review", style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddReviewScreen(courseId: course.id),
            ),
          );
          // Refresh reviews when coming back
          if (context.mounted) {
            context.read<CourseDetailViewModel>().refreshReviews();
          }
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final responsive = context.responsive;
    return SliverAppBar(
      expandedHeight: responsive.spacing(150.0),
      pinned: true,
      backgroundColor: Color(0xFF800000),
      foregroundColor: Colors.white,
      title: Text(course.id),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF800000), Color(0xFF500000)],
            ),
          ),
          padding: EdgeInsets.fromLTRB(responsive.spacing(20), 0, responsive.spacing(20), responsive.spacing(16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing(10), vertical: responsive.spacing(5)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(responsive.spacing(20)),
                    ),
                    child: Text(
                      course.faculty,
                      style: TextStyle(color: Colors.white, fontSize: responsive.sp(12), fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing(10), vertical: responsive.spacing(5)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(responsive.spacing(20)),
                    ),
                    child: Text(
                      course.universityId ?? 'UPM',
                      style: TextStyle(color: Colors.white, fontSize: responsive.sp(12), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(8)),
              Text(
                course.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.sp(18),
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseStats(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: responsive.spacing(10),
            offset: Offset(0, responsive.spacing(4)),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                course.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: responsive.sp(36),
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < course.averageRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: responsive.iconSize(16),
                  );
                }),
              ),
            ],
          ),
          SizedBox(width: responsive.spacing(20)),
          Container(height: responsive.spacing(50), width: 1, color: Colors.grey[200]),
          SizedBox(width: responsive.spacing(20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${course.totalReviews} Reviews",
                  style: TextStyle(
                    fontSize: responsive.sp(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  "Student feedback summary",
                  style: TextStyle(
                    fontSize: responsive.sp(12),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsHeader(CourseDetailViewModel viewModel, Responsive responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Student Reviews",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: responsive.sp(18),
            color: Color(0xFF800000),
          ),
        ),
        if (viewModel.reviews.isNotEmpty)
          Container(
            height: responsive.spacing(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(responsive.spacing(16)),
            ),
            child: TextButton.icon(
              onPressed: () => viewModel.toggleSortOrder(),
              icon: Icon(
                viewModel.isNewestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                size: responsive.iconSize(14),
                color: Color(0xFF800000),
              ),
              label: Text(
                viewModel.isNewestFirst ? "Newest" : "Oldest",
                style: TextStyle(fontSize: responsive.sp(12), color: Color(0xFF800000), fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(12)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsList(CourseDetailViewModel viewModel, Responsive responsive) {
    if (viewModel.isLoading && viewModel.reviews.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(40)),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF800000))),
        ),
      );
    }

    if (viewModel.reviews.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(40)),
          child: Column(
            children: [
              Icon(Icons.rate_review_outlined, size: responsive.iconSize(48), color: Colors.grey[300]),
              SizedBox(height: responsive.spacing(16)),
              Text("No reviews yet", style: TextStyle(color: Colors.grey[600], fontSize: responsive.sp(14), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final review = viewModel.reviews[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20), vertical: responsive.spacing(8)),
            child: _buildReviewCard(review, responsive),
          );
        },
        childCount: viewModel.reviews.length,
      ),
    );
  }

  Widget _buildReviewCard(Review review, Responsive responsive) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: responsive.spacing(8),
            offset: Offset(0, responsive.spacing(2)),
          ),
        ],
      ),
      padding: EdgeInsets.all(responsive.spacing(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: responsive.spacing(16),
                backgroundColor: Color(0xFF800000).withOpacity(0.1),
                child: Text(
                  review.studentName.isNotEmpty ? review.studentName[0].toUpperCase() : 'A',
                  style: TextStyle(color: Color(0xFF800000), fontWeight: FontWeight.bold, fontSize: responsive.sp(14)),
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.studentName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsive.sp(14)),
                    ),
                    if (review.timestamp != null)
                      Text(
                        "${review.timestamp!.day}/${review.timestamp!.month}/${review.timestamp!.year}",
                        style: TextStyle(fontSize: responsive.sp(11), color: Colors.grey[500]),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(8), vertical: responsive.spacing(4)),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, size: responsive.iconSize(14), color: Colors.amber),
                    SizedBox(width: responsive.spacing(4)),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsive.sp(12), color: Colors.amber[900]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.isRecommended) ...[
            SizedBox(height: responsive.spacing(12)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: responsive.spacing(10), vertical: responsive.spacing(6)),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(responsive.spacing(8)),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up_rounded, size: responsive.iconSize(14), color: Colors.green),
                  SizedBox(width: responsive.spacing(6)),
                  Text(
                    "Recommends this course",
                    style: TextStyle(fontSize: responsive.sp(12), color: Colors.green[700], fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: responsive.spacing(12)),
          Text(
            review.comment,
            style: TextStyle(fontSize: responsive.sp(14), height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(CourseDetailViewModel viewModel, Responsive responsive) {
    if (!viewModel.hasMore || viewModel.isLoading) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.all(responsive.spacing(20)),
      child: viewModel.isLoadingMore
          ? Center(child: CircularProgressIndicator(color: Color(0xFF800000)))
          : OutlinedButton(
              onPressed: () => viewModel.loadMoreReviews(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF800000),
                side: BorderSide(color: Color(0xFF800000)),
                padding: EdgeInsets.symmetric(vertical: responsive.spacing(12)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.spacing(12))),
              ),
              child: Text("Load More Reviews", style: TextStyle(fontSize: responsive.sp(14))),
            ),
    );
  }
}
