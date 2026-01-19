import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../utils/responsive.dart';
import '../models/course.dart';
import 'course_detail_screen.dart';
import 'add_course_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isFiltersExpanded = true;
  late AnimationController _filterAnimController;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _filterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimController,
      curve: Curves.easeInOut,
    );
    _filterAnimController.value = 1.0; // Start expanded

    // Initialize search when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _isFiltersExpanded = !_isFiltersExpanded;
      if (_isFiltersExpanded) {
        _filterAnimController.forward();
      } else {
        _filterAnimController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF800000),
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Course',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCourseScreen()),
          );
          if (result == true && context.mounted) {
            context.read<SearchViewModel>().refresh();
          }
        },
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                // Dynamic App Bar
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: Color(0xFF800000),
                  title: Text(viewModel.isFiltered
                      ? "Search Results (${viewModel.filteredCoursesCount})"
                      : "All Courses"),
                  elevation: 0,
                ),
                // Search Input
                SliverToBoxAdapter(child: _buildSearchInput()),

                // Filters
                SliverToBoxAdapter(child: _buildFilters()),

                // Results
                _buildResultsList(viewModel, responsive),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsList(SearchViewModel viewModel, Responsive responsive) {
    if (viewModel.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(responsive.spacing(20)),
                decoration: BoxDecoration(
                  color: Color(0xFF800000).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: responsive.iconSize(40),
                  height: responsive.iconSize(40),
                  child: CircularProgressIndicator(
                    color: Color(0xFF800000),
                    strokeWidth: 3,
                  ),
                ),
              ),
              SizedBox(height: responsive.spacing(20)),
              Text(
                "Loading courses...",
                style: TextStyle(
                  fontSize: responsive.sp(16),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.errorMessage != null && viewModel.searchResults.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(responsive.spacing(32)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(responsive.spacing(20)),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: responsive.iconSize(48),
                    color: Colors.red[400],
                  ),
                ),
                SizedBox(height: responsive.spacing(24)),
                Text(
                  "Oops! Something went wrong",
                  style: TextStyle(
                    fontSize: responsive.sp(18),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: responsive.spacing(8)),
                Text(
                  "We couldn't load the courses.\nPlease check your connection and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: responsive.sp(14),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: responsive.spacing(24)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF800000),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(24),
                      vertical: responsive.spacing(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => viewModel.initialize(),
                  icon: Icon(Icons.refresh_rounded),
                  label: Text(
                    "Try Again",
                    style: TextStyle(
                      fontSize: responsive.sp(15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (viewModel.searchResults.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(responsive.spacing(32)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(responsive.spacing(24)),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: responsive.iconSize(48),
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: responsive.spacing(24)),
                Text(
                  "No courses found",
                  style: TextStyle(
                    fontSize: responsive.sp(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: responsive.spacing(8)),
                Text(
                  viewModel.isFiltered
                      ? "Try adjusting your filters or search terms"
                      : "No courses available yet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: responsive.sp(14),
                  ),
                ),
                SizedBox(height: responsive.spacing(28)),
                // Add Course Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF800000),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(24),
                      vertical: responsive.spacing(14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddCourseScreen()),
                    );
                    if (result == true && context.mounted) {
                      viewModel.refresh();
                    }
                  },
                  icon: Icon(Icons.add_rounded),
                  label: Text(
                    "Add New Course",
                    style: TextStyle(
                      fontSize: responsive.sp(15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (viewModel.isFiltered) ...[
                  SizedBox(height: responsive.spacing(12)),
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      viewModel.clearFilters();
                    },
                    icon: Icon(Icons.clear_all_rounded, size: responsive.iconSize(18)),
                    label: Text(
                      "Clear All Filters",
                      style: TextStyle(fontSize: responsive.sp(14)),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Results count header
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        responsive.spacing(16),
        responsive.spacing(8),
        responsive.spacing(16),
        responsive.spacing(16),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // First item: Results count
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(bottom: responsive.spacing(12)),
                child: Row(
                  children: [
                    Text(
                      viewModel.isFiltered
                          ? "${viewModel.filteredCoursesCount} result${viewModel.filteredCoursesCount != 1 ? 's' : ''}"
                          : "${viewModel.totalCoursesCount} course${viewModel.totalCoursesCount != 1 ? 's' : ''}",
                      style: TextStyle(
                        fontSize: responsive.sp(13),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (viewModel.isFiltered) ...[
                      Text(
                        " of ${viewModel.totalCoursesCount}",
                        style: TextStyle(
                          fontSize: responsive.sp(13),
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            // Course cards
            final courseIndex = index - 1;
            final course = viewModel.searchResults[courseIndex];
            return Padding(
              padding: EdgeInsets.only(
                bottom: courseIndex != viewModel.searchResults.length - 1
                    ? responsive.spacing(12)
                    : responsive.spacing(80), // Extra padding at bottom for FAB
              ),
              child: _buildCourseCard(context, course),
            );
          },
          childCount: viewModel.searchResults.length + 1, // +1 for the header
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    final responsive = context.responsive;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF800000), Color(0xFF600000)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        responsive.spacing(20),
        responsive.spacing(8),
        responsive.spacing(20),
        responsive.spacing(24)
      ),
      child: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
                viewModel.updateSearchQuery(value);
              },
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: responsive.sp(15),
              ),
              decoration: InputDecoration(
                hintText: "Search courses, universities, faculties...",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: responsive.sp(14),
                ),
                prefixIcon: Container(
                  padding: EdgeInsets.all(responsive.spacing(12)),
                  child: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF800000),
                    size: responsive.iconSize(24),
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[400],
                          size: responsive.iconSize(20),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          viewModel.updateSearchQuery('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(16),
                  vertical: responsive.spacing(14),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    final responsive = context.responsive;

    return Consumer<SearchViewModel>(
      builder: (context, viewModel, child) {
        final hasActiveFilters = viewModel.selectedUniversity != 'All' ||
            viewModel.selectedFaculty != 'All' ||
            viewModel.minRating > 0;
        final activeFilterCount = (viewModel.selectedUniversity != 'All' ? 1 : 0) +
            (viewModel.selectedFaculty != 'All' ? 1 : 0) +
            (viewModel.minRating > 0 ? 1 : 0);

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(12),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Filter Header with toggle
              InkWell(
                onTap: _toggleFilters,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                  bottom: _isFiltersExpanded ? Radius.zero : Radius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(responsive.spacing(16)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(responsive.spacing(8)),
                        decoration: BoxDecoration(
                          color: Color(0xFF800000).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.filter_list_rounded,
                          color: Color(0xFF800000),
                          size: responsive.iconSize(20),
                        ),
                      ),
                      SizedBox(width: responsive.spacing(12)),
                      Text(
                        "Filters",
                        style: TextStyle(
                          fontSize: responsive.sp(16),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (hasActiveFilters) ...[
                        SizedBox(width: responsive.spacing(8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(8),
                            vertical: responsive.spacing(2),
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF800000),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$activeFilterCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.sp(12),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      Spacer(),
                      AnimatedRotation(
                        turns: _isFiltersExpanded ? 0.5 : 0,
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable Filter Content
              SizeTransition(
                sizeFactor: _filterAnimation,
                child: Column(
                  children: [
                    Divider(height: 1, color: Colors.grey[200]),
                    Padding(
                      padding: EdgeInsets.all(responsive.spacing(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // University Filter
                          _buildFilterSection(
                            icon: Icons.account_balance_rounded,
                            label: "University",
                            responsive: responsive,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: viewModel.availableUniversities.map((university) {
                                  final isSelected = viewModel.selectedUniversity == university;
                                  return Padding(
                                    padding: EdgeInsets.only(right: responsive.spacing(8)),
                                    child: _buildFilterChip(
                                      label: university,
                                      isSelected: isSelected,
                                      onSelected: () => viewModel.updateUniversityFilter(university),
                                      responsive: responsive,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: responsive.spacing(16)),

                          // Faculty Filter
                          _buildFilterSection(
                            icon: Icons.school_rounded,
                            label: "Faculty",
                            responsive: responsive,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: viewModel.availableFaculties.map((faculty) {
                                  final isSelected = viewModel.selectedFaculty == faculty;
                                  return Padding(
                                    padding: EdgeInsets.only(right: responsive.spacing(8)),
                                    child: _buildFilterChip(
                                      label: faculty,
                                      isSelected: isSelected,
                                      onSelected: () => viewModel.updateFacultyFilter(faculty),
                                      responsive: responsive,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: responsive.spacing(16)),

                          // Rating Filter
                          _buildFilterSection(
                            icon: Icons.star_rounded,
                            iconColor: Colors.amber,
                            label: "Min Rating",
                            trailing: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.spacing(10),
                                vertical: responsive.spacing(4),
                              ),
                              decoration: BoxDecoration(
                                color: viewModel.minRating > 0
                                    ? Color(0xFF800000)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                viewModel.minRating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: viewModel.minRating > 0 ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.sp(13),
                                ),
                              ),
                            ),
                            responsive: responsive,
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Color(0xFF800000),
                                inactiveTrackColor: Colors.grey[300],
                                thumbColor: Color(0xFF800000),
                                overlayColor: Color(0xFF800000).withOpacity(0.2),
                                trackHeight: 4,
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                              ),
                              child: Slider(
                                value: viewModel.minRating,
                                min: 0,
                                max: 5,
                                divisions: 10,
                                onChanged: (value) {
                                  viewModel.updateRatingFilter(value);
                                },
                              ),
                            ),
                          ),

                          // Clear Filters Button
                          if (hasActiveFilters) ...[
                            SizedBox(height: responsive.spacing(12)),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                  viewModel.clearFilters();
                                },
                                icon: Icon(Icons.refresh_rounded, size: responsive.iconSize(18)),
                                label: Text(
                                  "Reset All Filters",
                                  style: TextStyle(fontSize: responsive.sp(14)),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFF800000),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive.spacing(20),
                                    vertical: responsive.spacing(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection({
    required IconData icon,
    Color? iconColor,
    required String label,
    Widget? trailing,
    required Responsive responsive,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: responsive.iconSize(18), color: iconColor ?? Colors.grey[600]),
            SizedBox(width: responsive.spacing(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: responsive.sp(13),
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            if (trailing != null) ...[
              Spacer(),
              trailing,
            ],
          ],
        ),
        SizedBox(height: responsive.spacing(10)),
        child,
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required Responsive responsive,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: Material(
        color: isSelected ? Color(0xFF800000) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(14),
              vertical: responsive.spacing(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: responsive.sp(13),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    final responsive = context.responsive;
    final cardIconSize = responsive.isMobile ? 52.0 : 62.0;

    // Generate a color based on faculty for variety
    final facultyColors = {
      'FSKTM': Color(0xFF1565C0),
      'FEM': Color(0xFF2E7D32),
      'FK': Color(0xFFE65100),
      'FPP': Color(0xFF6A1B9A),
      'FS': Color(0xFF00838F),
    };
    final cardColor = facultyColors[course.facultyShort] ?? Color(0xFF800000);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CourseDetailScreen(course: course),
              ),
            );
            if (context.mounted) {
              context.read<SearchViewModel>().refresh();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(responsive.spacing(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Icon with gradient
                Container(
                  width: cardIconSize,
                  height: cardIconSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cardColor, cardColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    course.id.substring(0, min(3, course.id.length)).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: responsive.sp(13),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: responsive.spacing(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Code
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing(8),
                          vertical: responsive.spacing(3),
                        ),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          course.id,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: cardColor,
                            fontSize: responsive.sp(11),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.spacing(6)),
                      // Course Name
                      Text(
                        course.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: responsive.sp(15),
                          height: 1.25,
                          color: Colors.grey[850],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: responsive.spacing(10)),
                      // Tags and Rating Row
                      Row(
                        children: [
                          // Faculty Tag
                          _buildTag(
                            label: course.facultyShort,
                            backgroundColor: Colors.grey[100]!,
                            textColor: Colors.grey[700]!,
                            responsive: responsive,
                          ),
                          SizedBox(width: responsive.spacing(6)),
                          // University Tag
                          _buildTag(
                            label: course.universityId ?? 'UPM',
                            backgroundColor: Color(0xFF800000),
                            textColor: Colors.white,
                            responsive: responsive,
                          ),
                          Spacer(),
                          // Rating
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.spacing(8),
                              vertical: responsive.spacing(4),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: responsive.iconSize(14),
                                  color: Colors.amber[700],
                                ),
                                SizedBox(width: responsive.spacing(3)),
                                Text(
                                  course.averageRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: responsive.sp(12),
                                    color: Colors.amber[800],
                                  ),
                                ),
                                Text(
                                  " (${course.totalReviews})",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: responsive.sp(11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Padding(
                  padding: EdgeInsets.only(left: responsive.spacing(8)),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey[300],
                    size: responsive.iconSize(24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Responsive responsive,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(10),
        vertical: responsive.spacing(5),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: responsive.sp(11),
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}
