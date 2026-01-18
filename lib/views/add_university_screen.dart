import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                      onPressed: viewModel.isLoading ? null : () => _submitUniversity(context),
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
                              "Add University",
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
