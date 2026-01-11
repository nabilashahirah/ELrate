import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../models/review.dart';
import '../viewmodels/course_detail_viewmodel.dart';
import 'add_review_screen.dart';

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
    return Scaffold(
      body: Consumer<CourseDetailViewModel>(
        builder: (context, viewModel, child) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseStats(),
                      SizedBox(height: 24),
                      Text(
                        "About this course",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF800000),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        course.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 32),
                      _buildReviewsHeader(viewModel),
                    ],
                  ),
                ),
              ),
              _buildReviewsList(viewModel),
              SliverToBoxAdapter(
                child: _buildLoadMoreButton(viewModel),
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: 80)),
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
    return SliverAppBar(
      expandedHeight: 150.0,
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
          padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  course.faculty,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8),
              Text(
                course.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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

  Widget _buildCourseStats() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
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
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < course.averageRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          SizedBox(width: 20),
          Container(height: 50, width: 1, color: Colors.grey[200]),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${course.totalReviews} Reviews",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Student feedback summary",
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildReviewsHeader(CourseDetailViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Student Reviews",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF800000),
          ),
        ),
        if (viewModel.reviews.isNotEmpty)
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton.icon(
              onPressed: () => viewModel.toggleSortOrder(),
              icon: Icon(
                viewModel.isNewestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                size: 14,
                color: Color(0xFF800000),
              ),
              label: Text(
                viewModel.isNewestFirst ? "Newest" : "Oldest",
                style: TextStyle(fontSize: 12, color: Color(0xFF800000), fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsList(CourseDetailViewModel viewModel) {
    if (viewModel.isLoading && viewModel.reviews.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF800000))),
        ),
      );
    }

    if (viewModel.reviews.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text("No reviews yet", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _buildReviewCard(review),
          );
        },
        childCount: viewModel.reviews.length,
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF800000).withOpacity(0.1),
                child: Text(
                  review.studentName.isNotEmpty ? review.studentName[0].toUpperCase() : 'A',
                  style: TextStyle(color: Color(0xFF800000), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.studentName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (review.timestamp != null)
                      Text(
                        "${review.timestamp!.day}/${review.timestamp!.month}/${review.timestamp!.year}",
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber[900]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.isRecommended) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up_rounded, size: 14, color: Colors.green),
                  SizedBox(width: 6),
                  Text(
                    "Recommends this course",
                    style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(CourseDetailViewModel viewModel) {
    if (!viewModel.hasMore || viewModel.isLoading) return SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.all(20),
      child: viewModel.isLoadingMore
          ? Center(child: CircularProgressIndicator(color: Color(0xFF800000)))
          : OutlinedButton(
              onPressed: () => viewModel.loadMoreReviews(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF800000),
                side: BorderSide(color: Color(0xFF800000)),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Load More Reviews"),
            ),
    );
  }
}
