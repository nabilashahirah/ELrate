import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/add_review_viewmodel.dart';

class AddReviewScreen extends StatelessWidget {
  final String courseId;

  const AddReviewScreen({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddReviewViewModel(courseId: courseId),
      child: _AddReviewView(courseId: courseId),
    );
  }
}

class _AddReviewView extends StatefulWidget {
  final String courseId;

  const _AddReviewView({required this.courseId});

  @override
  _AddReviewViewState createState() => _AddReviewViewState();
}

class _AddReviewViewState extends State<_AddReviewView> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(BuildContext context) async {
    final viewModel = context.read<AddReviewViewModel>();
    final success = await viewModel.submitReview(_commentController.text);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review Posted!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? "Connection Error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStarRating(AddReviewViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          iconSize: 40,
          icon: Icon(
            starIndex <= viewModel.rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber,
          ),
          onPressed: () => viewModel.updateRating(starIndex.toDouble()),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rate ${widget.courseId}")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Consumer<AddReviewViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Info Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF800000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.courseId,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF800000),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text("How was your experience?"),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Rating Section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Your Rating",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        _buildStarRating(viewModel),
                        Text(
                          viewModel.rating == 1 ? "Poor" :
                          viewModel.rating == 2 ? "Fair" :
                          viewModel.rating == 3 ? "Good" :
                          viewModel.rating == 4 ? "Very Good" : "Excellent",
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Comment Section
                  Text(
                    "Review",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLength: 500,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Share your thoughts about the course content, lecturer, and difficulty...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Options Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text("Post Anonymously"),
                          subtitle: Text("Hide your name from other students"),
                          value: viewModel.isAnonymous,
                          activeColor: Color(0xFF800000),
                          onChanged: (val) => viewModel.toggleAnonymous(val),
                        ),
                        Divider(height: 1),
                        CheckboxListTile(
                          title: Text("Recommend this course?"),
                          subtitle: Text("Help others decide"),
                          value: viewModel.isRecommended,
                          activeColor: Colors.green,
                          onChanged: (val) => viewModel.toggleRecommended(val ?? false),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF800000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: viewModel.isLoading ? null : () => _submitReview(context),
                      child: viewModel.isLoading
                          ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("Submit Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
