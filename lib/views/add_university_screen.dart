import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../viewmodels/add_university_viewmodel.dart';
import '../utils/responsive.dart';

class AddUniversityScreen extends StatelessWidget {
  const AddUniversityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddUniversityViewModel(),
      child: const _AddUniversityView(),
    );
  }
}

class _AddUniversityView extends StatefulWidget {
  const _AddUniversityView();

  @override
  _AddUniversityViewState createState() => _AddUniversityViewState();
}

class _AddUniversityViewState extends State<_AddUniversityView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _countryController = TextEditingController(text: 'Malaysia');

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submitUniversity(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AddUniversityViewModel>();
    final success = await viewModel.submitUniversity(
      name: _nameController.text,
      shortName: _shortNameController.text,
      country: _countryController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, viewModel.addedUniversity);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("University added successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? "Failed to add university"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _validateWithAi(BuildContext context) async {
    final viewModel = context.read<AddUniversityViewModel>();

    if (_nameController.text.trim().isEmpty || _shortNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter university name and short name first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await viewModel.validateUniversityWithAi(
      name: _nameController.text.trim(),
      shortName: _shortNameController.text.trim(),
      country: _countryController.text.trim(),
    );

    if (!mounted) return;

    _showAiValidationResult(context, result);
  }

  void _showAiValidationResult(BuildContext context, AiValidationResult result) {
    final responsive = context.responsive;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.isValid ? Icons.check_circle : Icons.warning,
              color: result.isValid ? Colors.green : Colors.orange,
            ),
            SizedBox(width: responsive.spacing(8)),
            Expanded(
              child: Text(
                result.isValid ? "Valid University" : "Validation Warning",
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
            SizedBox(height: responsive.spacing(12)),
            Container(
              padding: EdgeInsets.all(responsive.spacing(8)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    "Confidence: ",
                    style: TextStyle(
                      fontSize: responsive.sp(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(8),
                      vertical: responsive.spacing(4),
                    ),
                    decoration: BoxDecoration(
                      color: result.confidence == 'high'
                          ? Colors.green
                          : result.confidence == 'medium'
                              ? Colors.orange
                              : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      result.confidence.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.sp(10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (result.suggestedName != null) ...[
              SizedBox(height: responsive.spacing(12)),
              Text(
                "Suggested name: ${result.suggestedName}",
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

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New University"),
        elevation: 0,
      ),
      body: Consumer<AddUniversityViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(responsive.spacing(20)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(responsive.spacing(16)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF800000).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(responsive.spacing(12)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_rounded,
                          size: responsive.iconSize(40),
                          color: const Color(0xFF800000),
                        ),
                        SizedBox(height: responsive.spacing(8)),
                        Text(
                          "Add a New University",
                          style: TextStyle(
                            fontSize: responsive.sp(18),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF800000),
                          ),
                        ),
                        SizedBox(height: responsive.spacing(4)),
                        Text(
                          "Add your university to start reviewing courses",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: responsive.sp(12),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: responsive.spacing(24)),

                  // University Name
                  Text(
                    "University Name *",
                    style: TextStyle(
                      fontSize: responsive.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: "e.g., Universiti Putra Malaysia",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(responsive.spacing(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(responsive.spacing(16)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'University name is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: responsive.spacing(20)),

                  // Short Name
                  Text(
                    "Short Name / Abbreviation *",
                    style: TextStyle(
                      fontSize: responsive.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  TextFormField(
                    controller: _shortNameController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: "e.g., UPM, UM, USM",
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(responsive.spacing(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(responsive.spacing(16)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Short name is required';
                      }
                      if (value.trim().length > 10) {
                        return 'Short name must be 10 characters or less';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: responsive.spacing(20)),

                  // Country
                  Text(
                    "Country *",
                    style: TextStyle(
                      fontSize: responsive.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  TextFormField(
                    controller: _countryController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: "e.g., Malaysia",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(responsive.spacing(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(responsive.spacing(16)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Country is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: responsive.spacing(20)),

                  // AI Validation Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(responsive.spacing(12)),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(responsive.spacing(12)),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.blue[700],
                              size: responsive.iconSize(20),
                            ),
                            SizedBox(width: responsive.spacing(8)),
                            Text(
                              "AI Assistant",
                              style: TextStyle(
                                fontSize: responsive.sp(14),
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: responsive.spacing(8)),
                        Text(
                          "Verify with AI before submitting (Required)",
                          style: TextStyle(
                            fontSize: responsive.sp(12),
                            color: Colors.blue[600],
                          ),
                        ),
                        SizedBox(height: responsive.spacing(12)),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: viewModel.isValidatingWithAi
                                    ? null
                                    : () => _validateWithAi(context),
                                icon: viewModel.isValidatingWithAi
                                    ? SizedBox(
                                        width: responsive.spacing(16),
                                        height: responsive.spacing(16),
                                        child: const CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Icon(Icons.verified, size: responsive.iconSize(18)),
                                label: Text(
                                  viewModel.isValidatingWithAi ? "Validating..." : "Validate University",
                                  style: TextStyle(fontSize: responsive.sp(12)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue[700],
                                  side: BorderSide(color: Colors.blue[300]!),
                                  padding: EdgeInsets.symmetric(
                                    vertical: responsive.spacing(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (viewModel.aiValidationResult != null) ...[
                          SizedBox(height: responsive.spacing(8)),
                          Container(
                            padding: EdgeInsets.all(responsive.spacing(8)),
                            decoration: BoxDecoration(
                              color: viewModel.aiValidationResult!.isValid
                                  ? Colors.green[50]
                                  : Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  viewModel.aiValidationResult!.isValid
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: viewModel.aiValidationResult!.isValid
                                      ? Colors.green
                                      : Colors.orange,
                                  size: responsive.iconSize(16),
                                ),
                                SizedBox(width: responsive.spacing(8)),
                                Expanded(
                                  child: Text(
                                    viewModel.aiValidationResult!.reason.length > 100
                                        ? '${viewModel.aiValidationResult!.reason.substring(0, 100)}...'
                                        : viewModel.aiValidationResult!.reason,
                                    style: TextStyle(
                                      fontSize: responsive.sp(11),
                                      color: viewModel.aiValidationResult!.isValid
                                          ? Colors.green[700]
                                          : Colors.orange[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: responsive.spacing(24)),

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
                          : () => _submitUniversity(context),
                      child: viewModel.isLoading
                          ? SizedBox(
                              height: responsive.spacing(24),
                              width: responsive.spacing(24),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              viewModel.canSubmit
                                  ? "Add University"
                                  : "Validate with AI First",
                              style: TextStyle(
                                fontSize: responsive.sp(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: responsive.spacing(16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
