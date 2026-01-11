import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'auth/login_screen.dart';
import '../models/review.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize user data and fetch reviews
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().initialize();
      context.read<ProfileViewModel>().fetchMyReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        elevation: 0,
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            color: Color(0xFF800000),
            onRefresh: () async {
              await viewModel.initialize();
              await viewModel.fetchMyReviews();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(viewModel),

                  SizedBox(height: 10),

                  // Profile Options
                  _buildProfileOptions(context, viewModel),

                  SizedBox(height: 10),

                  // My Reviews Section
                  _buildMyReviews(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel) {
    final user = viewModel.user;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF800000),
            Color(0xFFA00000),
          ],
        ),
      ),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                user?.initials ?? 'U',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),

          // Name
          Text(
            user?.name ?? 'User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),

          // Email
          Text(
            user?.email ?? 'user@upm.edu.my',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),

          SizedBox(height: 24),

          // Stats
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.rate_review_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  "${viewModel.myReviews.length} Reviews",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, ProfileViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            _buildOptionTile(
              icon: Icons.edit_outlined,
              title: "Edit Profile",
              onTap: () => _showEditProfileDialog(context, viewModel),
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.settings_outlined,
              title: "Settings",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Settings coming soon!")),
                );
              },
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.help_outline_rounded,
              title: "Help & Support",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Help & Support coming soon!")),
                );
              },
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.info_outline_rounded,
              title: "About",
              onTap: () => _showAboutDialog(context),
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.logout_rounded,
              title: "Logout",
              textColor: Colors.red,
              onTap: () => _showLogoutDialog(context, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 56, endIndent: 20);
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildMyReviews(ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            "My Reviews",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        if (viewModel.isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Color(0xFF800000),
              ),
            ),
          )
        else if (viewModel.myReviews.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No reviews yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Start rating courses to see them here",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: viewModel.myReviews.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildReviewCard(viewModel.myReviews[index]);
            },
          ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF800000).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    review.courseId,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF800000),
                      fontSize: 12,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileViewModel viewModel) {
    final nameController = TextEditingController(text: viewModel.user?.name ?? '');
    final emailController = TextEditingController(text: viewModel.user?.email ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Edit Profile"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (viewModel.isLoading) ...[
                  SizedBox(height: 15),
                  CircularProgressIndicator(
                    color: Color(0xFF800000),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: viewModel.isLoading ? null : () => Navigator.pop(dialogContext),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF800000),
                  foregroundColor: Colors.white,
                ),
                onPressed: viewModel.isLoading ? null : () async {
                  // Validate inputs
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Name cannot be empty")),
                    );
                    return;
                  }

                  if (emailController.text.trim().isEmpty || !emailController.text.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a valid email")),
                    );
                    return;
                  }

                  // Call API to update profile
                  final success = await viewModel.updateProfile(
                    nameController.text.trim(),
                    emailController.text.trim(),
                  );

                  if (context.mounted) {
                    if (success) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Profile updated successfully!")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(viewModel.errorMessage ?? "Failed to update profile"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("About ELRate"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ELRate - UPM Course Rating System",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Version: 1.0.0"),
            SizedBox(height: 10),
            Text(
              "A platform for students to rate and review university courses.",
            ),
            SizedBox(height: 10),
            Text(
              "© 2026 UPM",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Get AuthViewModel and logout
              final authViewModel = context.read<AuthViewModel>();
              await authViewModel.logout();

              if (context.mounted) {
                Navigator.pop(dialogContext); // Close dialog

                // Navigate to login screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
