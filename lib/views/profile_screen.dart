import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../utils/responsive.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'auth/login_screen.dart';
import '../models/review.dart';
import '../models/course.dart';
import '../services/api_service.dart';
import 'course_detail_screen.dart';

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
    final responsive = context.responsive;

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

                  SizedBox(height: responsive.spacing(10)),

                  // Profile Options
                  _buildProfileOptions(context, viewModel),

                  SizedBox(height: responsive.spacing(10)),

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
    final responsive = context.responsive;

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
      padding: EdgeInsets.fromLTRB(
        responsive.spacing(20),
        responsive.spacing(40),
        responsive.spacing(20),
        responsive.spacing(40)
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: EdgeInsets.all(responsive.spacing(4)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: CircleAvatar(
              radius: responsive.avatarSize * 1.0,
              backgroundColor: Colors.white,
              child: Text(
                user?.initials ?? 'U',
                style: TextStyle(
                  fontSize: responsive.sp(32),
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing(15)),

          // Name
          Text(
            user?.name ?? 'User',
            style: TextStyle(
              fontSize: responsive.sp(24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: responsive.spacing(5)),

          // Email
          Text(
            user?.email ?? 'user@upm.edu.my',
            style: TextStyle(
              fontSize: responsive.sp(14),
              color: Colors.white.withOpacity(0.8),
            ),
          ),

          SizedBox(height: responsive.spacing(24)),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Total Reviews
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(16),
                  vertical: responsive.spacing(12)
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      "${viewModel.myReviews.length}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.sp(24),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Row(
                      children: [
                        Icon(Icons.rate_review_rounded, color: Colors.white.withOpacity(0.9), size: responsive.iconSize(14)),
                        SizedBox(width: responsive.spacing(4)),
                        Text(
                          "Reviews",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: responsive.sp(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              // Average Rating Given
              if (viewModel.myReviews.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(16),
                    vertical: responsive.spacing(12)
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (viewModel.myReviews.map((r) => r.rating).reduce((a, b) => a + b) / viewModel.myReviews.length).toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: responsive.sp(24),
                        ),
                      ),
                      SizedBox(height: responsive.spacing(4)),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber[300], size: responsive.iconSize(14)),
                          SizedBox(width: responsive.spacing(4)),
                          Text(
                            "Avg Rating",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: responsive.sp(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, ProfileViewModel viewModel) {
    final responsive = context.responsive;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
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
              onTap: () => _showHelpSupportDialog(context),
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
    final responsive = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            responsive.spacing(20),
            responsive.spacing(20),
            responsive.spacing(20),
            responsive.spacing(16)
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.spacing(10)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF800000),
                      Color(0xFFA00000),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: responsive.iconSize(22),
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Reviews",
                    style: TextStyle(
                      fontSize: responsive.sp(20),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (viewModel.myReviews.isNotEmpty)
                    Text(
                      "Tap any review to view the course",
                      style: TextStyle(
                        fontSize: responsive.sp(12),
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (viewModel.isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(responsive.spacing(20)),
              child: CircularProgressIndicator(
                color: Color(0xFF800000),
              ),
            ),
          )
        else if (viewModel.myReviews.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(responsive.spacing(40)),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(responsive.spacing(24)),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rate_review_outlined,
                      size: responsive.iconSize(48),
                      color: Colors.grey[400],
                    ),
                  ),
                  SizedBox(height: responsive.spacing(20)),
                  Text(
                    "No reviews yet",
                    style: TextStyle(
                      fontSize: responsive.sp(18),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  Text(
                    "Start rating courses to see them here",
                    style: TextStyle(
                      fontSize: responsive.sp(14),
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsive.spacing(20)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(20),
                      vertical: responsive.spacing(10),
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF800000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_outline, size: responsive.iconSize(16), color: Color(0xFF800000)),
                        SizedBox(width: responsive.spacing(8)),
                        Text(
                          "Explore courses in Search tab",
                          style: TextStyle(
                            fontSize: responsive.sp(13),
                            color: Color(0xFF800000),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(20),
              vertical: responsive.spacing(10)
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: viewModel.myReviews.length,
            separatorBuilder: (context, index) => SizedBox(height: responsive.spacing(12)),
            itemBuilder: (context, index) {
              return _buildReviewCard(viewModel.myReviews[index]);
            },
          ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    final responsive = context.responsive;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // Fetch course details and navigate
          try {
            final apiService = ApiService();
            final courses = await apiService.getCourses();
            final course = courses.firstWhere(
              (c) => c.id == review.courseId,
              orElse: () => Course(
                id: review.courseId,
                name: "Unknown Course",
                faculty: "",
                facultyShort: "Gen",
                description: "",
                averageRating: 0.0,
                totalReviews: 0,
              ),
            );

            if (context.mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(course: course),
                ),
              );
              // Refresh reviews after returning
              if (context.mounted) {
                context.read<ProfileViewModel>().fetchMyReviews();
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to load course details")),
              );
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with course ID, timestamp, and tap hint
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Course icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF800000),
                                Color(0xFFA00000),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            review.courseId.substring(0, review.courseId.length >= 3 ? 3 : review.courseId.length),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: responsive.sp(12),
                            ),
                          ),
                        ),
                        SizedBox(width: responsive.spacing(12)),
                        // Course ID
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.courseId,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF800000),
                                  fontSize: responsive.sp(14),
                                ),
                              ),
                              SizedBox(height: responsive.spacing(2)),
                              Row(
                                children: [
                                  Icon(Icons.touch_app, size: responsive.iconSize(12), color: Colors.grey[500]),
                                  SizedBox(width: responsive.spacing(4)),
                                  Text(
                                    "Tap to view course",
                                    style: TextStyle(
                                      fontSize: responsive.sp(11),
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  // Timestamp
                  if (review.timestamp != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTimestamp(review.timestamp!),
                          style: TextStyle(
                            fontSize: responsive.sp(11),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: responsive.spacing(14)),

              // Rating with stars
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(10),
                  vertical: responsive.spacing(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < review.rating.floor()
                            ? Icons.star_rounded
                            : (index < review.rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                        size: responsive.iconSize(16),
                        color: Colors.amber[700],
                      );
                    }),
                    SizedBox(width: responsive.spacing(6)),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.sp(15),
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(14)),

              // Comment with quote styling
              Container(
                padding: EdgeInsets.only(left: responsive.spacing(12)),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Color(0xFF800000).withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  '"${review.comment}"',
                  style: TextStyle(
                    fontSize: responsive.sp(14),
                    color: Colors.black87,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              // Badges for anonymous and recommended
              if (review.isAnonymous || review.isRecommended) ...[
                SizedBox(height: responsive.spacing(14)),
                Wrap(
                  spacing: responsive.spacing(8),
                  runSpacing: responsive.spacing(8),
                  children: [
                    if (review.isAnonymous)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing(10),
                          vertical: responsive.spacing(6)
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_off, size: responsive.iconSize(14), color: Colors.grey[700]),
                            SizedBox(width: responsive.spacing(6)),
                            Text(
                              'Anonymous',
                              style: TextStyle(
                                fontSize: responsive.sp(12),
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (review.isRecommended)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing(10),
                          vertical: responsive.spacing(6)
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green[300]!, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.thumb_up, size: responsive.iconSize(14), color: Colors.green[700]),
                            SizedBox(width: responsive.spacing(6)),
                            Text(
                              'Recommended',
                              style: TextStyle(
                                fontSize: responsive.sp(12),
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    } else if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
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

  void _showHelpSupportDialog(BuildContext context) {
    final responsive = context.responsive;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Color(0xFF800000)),
            SizedBox(width: 10),
            Text("Help & Support"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Need help? Contact us!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsive.sp(16)),
            ),
            SizedBox(height: 16),
            Text(
              "Email:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800000)),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 18, color: Colors.grey[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "elrate00@gmail.com",
                    style: TextStyle(fontSize: responsive.sp(14)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 18, color: Colors.grey[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "214478@student.upm.edu.my",
                    style: TextStyle(fontSize: responsive.sp(14)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF800000).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Color(0xFF800000)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "We typically respond within 24-48 hours.",
                      style: TextStyle(fontSize: responsive.sp(12), color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
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

  void _showAboutDialog(BuildContext context) {
    final responsive = context.responsive;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFF800000)),
            SizedBox(width: 10),
            Text("About ELRate"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ELRate - Course Rating System",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsive.sp(16)),
              ),
              SizedBox(height: 8),
              Text("Version: 1.0.0"),
              SizedBox(height: 16),
              Text(
                "A platform for students to rate and review university courses across Malaysia.",
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              Text(
                "Developers:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800000)),
              ),
              SizedBox(height: 10),
              _buildDeveloperName("Nur Nabila Shahirah bt Salim"),
              _buildDeveloperName("Aein Zakira bt Zuber"),
              _buildDeveloperName("Nur Aliyah Bt Kamarul 'Arif"),
              _buildDeveloperName("Yogeswary Mohan"),
              _buildDeveloperName("Liao Meixi"),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF800000).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "© 2026 ELRate Team\nUniversiti Putra Malaysia",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: responsive.sp(12), color: Colors.grey[700]),
                ),
              ),
            ],
          ),
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

  Widget _buildDeveloperName(String name) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.person_outline, size: 18, color: Color(0xFF800000)),
          SizedBox(width: 8),
          Text(name),
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
