import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/add_review_viewmodel.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';

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
  List<String> _harshWords = AppConstants.harshWords; // Initialize with fallback

  @override
  void initState() {
    super.initState();
    _fetchHarshWords();
  }

  Future<void> _fetchHarshWords() async {
    try {
      final words = await ApiService().getHarshWords();
      if (mounted) {
        setState(() {
          _harshWords = words;
        });
      }
    } catch (_) {
      // Keep using default list if fetch fails
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool _containsHarshWords(String text) {
    // Basic list of inappropriate words for academic context
    final lowerText = text.toLowerCase();
    for (final word in _harshWords) {
      // Check for whole words to avoid false positives (e.g., "class" containing "ass")
      if (RegExp(r'\b' + RegExp.escape(word) + r'\b').hasMatch(lowerText)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _submitReview(BuildContext context) async {
    if (_containsHarshWords(_commentController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please keep reviews professional. Harsh language is not allowed."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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

  Widget _buildStarRating(AddReviewViewModel viewModel, Responsive responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          iconSize: responsive.iconSize(40),
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
    final responsive = context.responsive;
    return Scaffold(
      appBar: AppBar(title: Text("Rate ${widget.courseId}")),
      body: Padding(
        padding: EdgeInsets.all(responsive.spacing(20)),
        child: Consumer<AddReviewViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(responsive.spacing(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Info Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(responsive.spacing(16)),
                    decoration: BoxDecoration(
                      color: Color(0xFF800000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(responsive.spacing(12)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.courseId,
                          style: TextStyle(
                            fontSize: responsive.sp(20),
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF800000),
                          ),
                        ),
                        SizedBox(height: responsive.spacing(4)),
                        Text("How was your experience?", style: TextStyle(fontSize: responsive.sp(14))),
                      ],
                    ),
                  ),
                  SizedBox(height: responsive.spacing(24)),

                  // Rating Section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Your Rating",
                          style: TextStyle(fontSize: responsive.sp(16), fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: responsive.spacing(8)),
                        _buildStarRating(viewModel, responsive),
                        Text(
                          viewModel.rating == 1 ? "Poor" :
                          viewModel.rating == 2 ? "Fair" :
                          viewModel.rating == 3 ? "Good" :
                          viewModel.rating == 4 ? "Very Good" : "Excellent",
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontSize: responsive.sp(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: responsive.spacing(32)),

                  // Comment Section
                  Text(
                    "Review",
                    style: TextStyle(fontSize: responsive.sp(16), fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  TextField(
                    controller: _commentController,
                    maxLength: 500,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Share your thoughts about the course content, lecturer, and difficulty...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(responsive.spacing(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(responsive.spacing(16)),
                    ),
                    style: TextStyle(fontSize: responsive.sp(14)),
                  ),
                  SizedBox(height: responsive.spacing(24)),

                  // Options Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(responsive.spacing(12)),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text("Post Anonymously", style: TextStyle(fontSize: responsive.sp(14))),
                          subtitle: Text("Hide your name from other students", style: TextStyle(fontSize: responsive.sp(12))),
                          value: viewModel.isAnonymous,
                          activeColor: Color(0xFF800000),
                          onChanged: (val) => viewModel.toggleAnonymous(val),
                        ),
                        Divider(height: 1),
                        CheckboxListTile(
                          title: Text("Recommend this course?", style: TextStyle(fontSize: responsive.sp(14))),
                          subtitle: Text("Help others decide", style: TextStyle(fontSize: responsive.sp(12))),
                          value: viewModel.isRecommended,
                          activeColor: Colors.green,
                          onChanged: (val) => viewModel.toggleRecommended(val ?? false),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: responsive.spacing(32)),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: responsive.buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF800000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(responsive.spacing(12)),
                        ),
                        elevation: 2,
                      ),
                      onPressed: viewModel.isLoading ? null : () => _submitReview(context),
                      child: viewModel.isLoading
                          ? SizedBox(height: responsive.spacing(24), width: responsive.spacing(24), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("Submit Review", style: TextStyle(fontSize: responsive.sp(16), fontWeight: FontWeight.bold)),
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
