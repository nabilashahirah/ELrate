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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rate ${widget.courseId}")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Consumer<AddReviewViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                Text(
                  "Rate this course",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  viewModel.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800000),
                  ),
                ),
                Slider(
                  value: viewModel.rating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: Color(0xFF800000),
                  onChanged: (value) => viewModel.updateRating(value),
                ),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: "Your experience...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF800000),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () => _submitReview(context),
                    child: viewModel.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("SUBMIT"),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
