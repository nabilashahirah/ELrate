import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/add_course_viewmodel.dart';
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

  @override
  void dispose() {
    _courseIdController.dispose();
    _nameController.dispose();
    _facultyController.dispose();
    _facultyShortController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitCourse(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AddCourseViewModel>();
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
                  // Debug: Show error or count
                  if (viewModel.errorMessage != null)
                    Text("Error: ${viewModel.errorMessage}", style: TextStyle(color: Colors.red, fontSize: 12)),
                  Text("Universities loaded: ${viewModel.universities.length}", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: responsive.spacing(4)),
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
                    ),
                    validator: (value) {
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

                  // Description
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: responsive.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: "Brief description of the course content...",
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
                        backgroundColor: const Color(0xFF800000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(responsive.spacing(12)),
                        ),
                        elevation: 2,
                      ),
                      onPressed: viewModel.isLoading ? null : () => _submitCourse(context),
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
                              "Add Course",
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
