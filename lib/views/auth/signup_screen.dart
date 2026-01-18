import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/responsive.dart';
import '../main_navigation.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<AuthViewModel>();
      
      // Call signup on the viewmodel
      final success = await viewModel.signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to Home upon successful signup
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? "Signup failed"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF800000),
              Color(0xFF500000),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(responsive.spacing(24)),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 450, // Limit width on tablets/desktop
                        ),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(responsive.spacing(20)),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(responsive.spacing(32)),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo
                                  Container(
                                    padding: EdgeInsets.all(responsive.spacing(16)),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF800000).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      width: responsive.logoSize * 0.6,
                                      height: responsive.logoSize * 0.6,
                                      color: Color(0xFF800000),
                                    ),
                                  ),
                                  SizedBox(height: responsive.spacing(16)),

                                  // Header
                                  Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: responsive.sp(24),
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF800000),
                                    ),
                                  ),
                                  SizedBox(height: responsive.spacing(8)),
                                  Text(
                                    "Join the student community",
                                    style: TextStyle(
                                      fontSize: responsive.sp(14),
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: responsive.spacing(32)),

                                  // Name Field
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: _buildInputDecoration(
                                      "Full Name",
                                      Icons.person_outline,
                                      responsive,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      if (value.length < 3) {
                                        return 'Name must be at least 3 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: responsive.spacing(16)),

                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: _buildInputDecoration(
                                      "Email Address",
                                      Icons.email_outlined,
                                      responsive,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: responsive.spacing(16)),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    decoration: _buildInputDecoration(
                                      "Password",
                                      Icons.lock_outline,
                                      responsive,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: responsive.spacing(16)),

                                  // Confirm Password Field
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: !_isConfirmPasswordVisible,
                                    decoration: _buildInputDecoration(
                                      "Confirm Password",
                                      Icons.lock_outline,
                                      responsive,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: responsive.spacing(32)),

                                  // Signup Button
                                  Consumer<AuthViewModel>(
                                    builder: (context, viewModel, child) {
                                      return SizedBox(
                                        width: double.infinity,
                                        height: responsive.buttonHeight,
                                        child: ElevatedButton(
                                          onPressed: viewModel.isLoading ? null : _handleSignup,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF800000),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 2,
                                          ),
                                          child: viewModel.isLoading
                                              ? SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Text(
                                                  "Sign Up",
                                                  style: TextStyle(
                                                    fontSize: responsive.sp(16),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: responsive.spacing(24)),

                                  // Login Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account? ",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: responsive.sp(14),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                            color: Color(0xFF800000),
                                            fontWeight: FontWeight.bold,
                                            fontSize: responsive.sp(14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, Responsive responsive, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Color(0xFF800000)),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF800000), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(16),
        vertical: responsive.spacing(16),
      ),
    );
  }
}