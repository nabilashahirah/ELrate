import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../viewmodels/add_review_viewmodel.dart';
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkContentWithAi(BuildContext context) async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a review first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final viewModel = context.read<AddReviewViewModel>();
    final result = await viewModel.checkContentWithAi(comment);

    if (!mounted) return;

    _showModerationResult(context, result);
  }

  void _showModerationResult(BuildContext context, ContentModerationResult result) {
    final responsive = context.responsive;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.isAppropriate ? Icons.check_circle : Icons.warning,
              color: result.isAppropriate ? Colors.green : Colors.red,
            ),
            SizedBox(width: responsive.spacing(8)),
            Expanded(
              child: Text(
                result.isAppropriate ? "Content OK" : "Content Warning",
                style: TextStyle(fontSize: responsive.sp(16)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.reason,
              style: TextStyle(fontSize: responsive.sp(14)),
            ),
            if (result.hasFlaggedWords) ...[
              SizedBox(height: responsive.spacing(12)),
              Container(
                padding: EdgeInsets.all(responsive.spacing(8)),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Flagged words:",
                      style: TextStyle(
                        fontSize: responsive.sp(12),
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: result.flaggedWords.map((word) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing(8),
                          vertical: responsive.spacing(2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          word,
                          style: TextStyle(
                            fontSize: responsive.sp(11),
                            color: Colors.red[800],
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
            if (result.suggestion != null) ...[
              SizedBox(height: responsive.spacing(12)),
              Text(
                "Suggestion:",
                style: TextStyle(
                  fontSize: responsive.sp(12),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: responsive.spacing(4)),
              Text(
                result.suggestion!,
                style: TextStyle(
                  fontSize: responsive.sp(12),
                  fontStyle: FontStyle.italic,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview(BuildContext context) async {
    final viewModel = context.read<AddReviewViewModel>();
    final success = await viewModel.submitReview(_commentController.text);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review Posted!")),
      );
    } else {
      // Show moderation warning if content was flagged
      if (viewModel.moderationResult != null && !viewModel.moderationResult!.isAppropriate) {
        _showModerationResult(context, viewModel.moderationResult!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? "Connection Error"),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Review",
                        style: TextStyle(fontSize: responsive.sp(16), fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        onPressed: viewModel.isCheckingContent
                            ? null
                            : () => _checkContentWithAi(context),
                        icon: viewModel.isCheckingContent
                            ? SizedBox(
                                width: responsive.spacing(14),
                                height: responsive.spacing(14),
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              )
                            : viewModel.isContentChecked
                                ? Icon(Icons.check_circle, size: responsive.iconSize(16), color: Colors.green)
                                : Icon(Icons.shield_outlined, size: responsive.iconSize(16)),
                        label: Text(
                          viewModel.isCheckingContent
                              ? "Checking..."
                              : viewModel.isContentChecked
                                  ? "Content OK"
                                  : "Check Content *",
                          style: TextStyle(fontSize: responsive.sp(12)),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: viewModel.isContentChecked ? Colors.green : Colors.blue[700],
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(8),
                          ),
                        ),
                      ),
                    ],
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
                  // AI moderation warning display
                  if (viewModel.moderationResult != null && !viewModel.moderationResult!.isAppropriate)
                    Container(
                      margin: EdgeInsets.only(bottom: responsive.spacing(8)),
                      padding: EdgeInsets.all(responsive.spacing(12)),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(responsive.spacing(8)),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: responsive.iconSize(20)),
                          SizedBox(width: responsive.spacing(8)),
                          Expanded(
                            child: Text(
                              viewModel.moderationResult!.hasFlaggedWords
                                  ? 'Contains inappropriate words: ${viewModel.moderationResult!.flaggedWords.join(", ")}'
                                  : viewModel.moderationResult!.reason,
                              style: TextStyle(
                                fontSize: responsive.sp(12),
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: responsive.spacing(16)),

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
                        backgroundColor: viewModel.canSubmit
                            ? const Color(0xFF800000)
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(responsive.spacing(12)),
                        ),
                        elevation: viewModel.canSubmit ? 2 : 0,
                      ),
                      onPressed: (viewModel.isLoading || !viewModel.canSubmit)
                          ? null
                          : () => _submitReview(context),
                      child: viewModel.isLoading
                          ? SizedBox(height: responsive.spacing(24), width: responsive.spacing(24), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              viewModel.canSubmit
                                  ? "Submit Review"
                                  : "Check Content First",
                              style: TextStyle(fontSize: responsive.sp(16), fontWeight: FontWeight.bold),
                            ),
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
