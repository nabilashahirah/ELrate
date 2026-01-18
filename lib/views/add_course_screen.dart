import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../viewmodels/add_course_viewmodel.dart';
import '../viewmodels/course_list_viewmodel.dart';
import '../models/university.dart';
import '../utils/responsive.dart';
import 'add_university_screen.dart';

class AddCourseScreen extends StatelessWidget {
  const AddCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddCourseViewModel(),
      child: const _AddCourseView(),
    );
  }
}

class _AddCourseView extends StatefulWidget {
  const _AddCourseView();

  @override
  _AddCourseViewState createState() => _AddCourseViewState();
}

class _AddCourseViewState extends State<_AddCourseView> {
  final _formKey = GlobalKey<FormState>();
  final _courseIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _facultyController = TextEditingController();
  final _facultyShortController = TextEditingController();
  final _descriptionController = TextEditingController();

  Timer? _debounce;
  bool _isDuplicate = false;

  @override
  void initState() {
    super.initState();
    _courseIdController.addListener(_onCourseIdChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _courseIdController.removeListener(_onCourseIdChanged);
    _courseIdController.dispose();
    _nameController.dispose();
    _facultyController.dispose();
    _facultyShortController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onCourseIdChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final id = _courseIdController.text.trim();
      if (id.isEmpty) {
        if (_isDuplicate) setState(() => _isDuplicate = false);
        return;
      }

      // Check locally against loaded courses
      final courses = context.read<CourseListViewModel>().courses;
      final exists = courses.any((c) => c.id.toLowerCase() == id.toLowerCase());

      if (_isDuplicate != exists) {
        setState(() => _isDuplicate = exists);
      }
    });
  }

  Future<void> _submitCourse(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AddCourseViewModel>();

    // Show confirmation dialog to prevent duplicates/typos
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Confirm Course Details"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Text("Please verify the details below. The Course Code must be unique."),
              const SizedBox(height: 16),
              _buildConfirmationRow("University", viewModel.selectedUniversity?.shortName ?? "-"),
              const SizedBox(height: 8),
              _buildConfirmationRow("Course Code", _courseIdController.text.toUpperCase()),
              const SizedBox(height: 8),
              _buildConfirmationRow("Course Name", _nameController.text),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF800000),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Confirm & Add"),
          ),
        ],
      ),
    );

    if (shouldSubmit != true) return;

    final success = await viewModel.submitCourse(
      courseId: _courseIdController.text,
      name: _nameController.text,
      faculty: _facultyController.text,
      facultyShort: _facultyShortController.text,
      description: _descriptionController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Course added successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? "Failed to add course"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToAddUniversity(BuildContext context) async {
    final result = await Navigator.push<University>(
      context,
      MaterialPageRoute(builder: (_) => const AddUniversityScreen()),
    );

    if (result != null && mounted) {
      // Refresh universities list and select the new one
      final viewModel = context.read<AddCourseViewModel>();
      await viewModel.fetchUniversities();
      viewModel.selectUniversity(result);
    }
  }

  Future<void> _validateWithAi(BuildContext context) async {
    final viewModel = context.read<AddCourseViewModel>();

    if (viewModel.selectedUniversity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a university first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_courseIdController.text.trim().isEmpty || _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter course code and name first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await viewModel.validateCourseWithAi(
      courseCode: _courseIdController.text.trim(),
      courseName: _nameController.text.trim(),
      faculty: _facultyController.text.trim(),
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
            Text(result.isValid ? "Valid Course" : "Validation Warning"),
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

  Future<void> _generateDescription(BuildContext context) async {
    final viewModel = context.read<AddCourseViewModel>();

    if (viewModel.selectedUniversity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a university first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_courseIdController.text.trim().isEmpty || _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter course code and name first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final description = await viewModel.generateDescriptionWithAi(
      courseCode: _courseIdController.text.trim(),
      courseName: _nameController.text.trim(),
      faculty: _facultyController.text.trim(),
    );

    if (!mounted) return;

    if (description.isNotEmpty) {
      _descriptionController.text = description;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Description generated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not generate description. Please try again."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Course"),
        elevation: 0,
      ),
      body: Consumer<AddCourseViewModel>(
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
                          Icons.school_rounded,
                          size: responsive.iconSize(40),
                          color: const Color(0xFF800000),
                        ),
                        SizedBox(height: responsive.spacing(8)),
                        Text(
                          "Add a New Course",
                          style: TextStyle(
                            fontSize: responsive.sp(18),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF800000),
                          ),
                        ),
                        SizedBox(height: responsive.spacing(4)),
                        Text(
                          "Help other students by adding courses from your university",
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

                  // University Selection
                  Text(
                    "University *",
                    style: TextStyle(
                      fontSize: responsive.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  if (viewModel.isLoadingUniversities)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<University>(
                            value: viewModel.selectedUniversity,
                            decoration: InputDecoration(
                              hintText: "Select University",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(responsive.spacing(12)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: responsive.spacing(16),
                                vertical: responsive.spacing(12),
                              ),
                            ),
                            items: viewModel.universities.map((university) {
                              return DropdownMenuItem(
                                value: university,
                                child: Text(
                                  "${university.shortName} - ${university.name}",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) => viewModel.selectUniversity(value),
                            validator: (value) {
                              if (value == null) return 'Please select a university';
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: responsive.spacing(8)),
                        IconButton(
                          onPressed: () => _navigateToAddUniversity(context),
                          icon: Container(
                            padding: EdgeInsets.all(responsive.spacing(8)),
                            decoration: BoxDecoration(
                              color: const Color(0xFF800000),
                              borderRadius: BorderRadius.circular(responsive.spacing(8)),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: responsive.iconSize(20),
                            ),
                          ),
                          tooltip: "Add New University",
                        ),
                      ],
                    ),
                  SizedBox(height: responsive.spacing(20)),

                  // Course ID
                  Text(
                    "Course Code *",
                    style: TextStyle(
                      fontSize: responsive.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  TextFormField(
                    controller: _courseIdController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: "e.g., SSK3100, CS101",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(responsive.spacing(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(responsive.spacing(16)),
                      errorText: _isDuplicate ? "Course code already exists" : null,
                      suffixIcon: _courseIdController.text.isNotEmpty
                          ? (_isDuplicate
                              ? const Icon(Icons.error, color: Colors.red)
                              : (_courseIdController.text.length >= 3 ? const Icon(Icons.check_circle, color: Colors.green) : null))
                          : null,
                    ),
                    validator: (value) {
                      if (_isDuplicate) return 'Course already exists';
                      if (value == null || value.trim().isEmpty) {
                        return 'Course code is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Course code must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: responsive.spacing(20)),

                  // Course Name
                  Text(
                    "Course Name *",
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
                      hintText: "e.g., Introduction to Programming",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(responsive.spacing(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(responsive.spacing(16)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Course name is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Course name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: responsive.spacing(20)),

                  // Faculty
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Faculty *",
                              style: TextStyle(
                                fontSize: responsive.sp(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: responsive.spacing(8)),
                            TextFormField(
                              controller: _facultyController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: "e.g., Computer Science",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(responsive.spacing(12)),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.all(responsive.spacing(16)),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Faculty is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: responsive.spacing(12)),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Short *",
                              style: TextStyle(
                                fontSize: responsive.sp(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: responsive.spacing(8)),
                            TextFormField(
                              controller: _facultyShortController,
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 10,
                              decoration: InputDecoration(
                                hintText: "e.g., CS",
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
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          "Validate course with AI before submitting (Required)",
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
                                  viewModel.isValidatingWithAi ? "Validating..." : "Validate Course",
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
                  SizedBox(height: responsive.spacing(20)),

                  // Description
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: responsive.sp(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: (viewModel.isGeneratingDescription || !viewModel.isAiValidated)
                            ? null
                            : () => _generateDescription(context),
                        icon: viewModel.isGeneratingDescription
                            ? SizedBox(
                                width: responsive.spacing(14),
                                height: responsive.spacing(14),
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.auto_awesome, size: responsive.iconSize(16)),
                        label: Text(
                          viewModel.isGeneratingDescription
                              ? "Generating..."
                              : viewModel.isAiValidated
                                  ? "AI Generate"
                                  : "Validate First",
                          style: TextStyle(fontSize: responsive.sp(12)),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: viewModel.isAiValidated ? Colors.blue[700] : Colors.grey,
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: "Brief description of the course content... (Use AI Generate to auto-fill)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(responsive.spacing(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(responsive.spacing(16)),
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
                          : () => _submitCourse(context),
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
                                  ? "Add Course"
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
