import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
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
      appBar: AppBar(title: Text(course.id)),
      body: Consumer<CourseDetailViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800000),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  course.faculty,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  course.description,
                  style: TextStyle(height: 1.5, fontSize: 15),
                ),
                SizedBox(height: 20),
                Divider(),
                Text(
                  "Student Reviews",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                if (viewModel.isLoading)
                  Center(child: CircularProgressIndicator())
                else if (viewModel.reviews.isEmpty)
                  Text("No reviews yet.")
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: viewModel.reviews.length,
                    itemBuilder: (context, index) {
                      final review = viewModel.reviews[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    review.studentName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Icon(Icons.star, size: 16, color: Colors.amber),
                                  Text(" ${review.rating.toStringAsFixed(1)}"),
                                ],
                              ),
                              if (review.isRecommended) ...[
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF800000).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFF800000),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.thumb_up,
                                        size: 14,
                                        color: Color(0xFF800000),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Recommends this course",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF800000),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              SizedBox(height: 8),
                              Text(review.comment),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
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
}
