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

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize search when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                      : "All Subjects"),
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
          child: CircularProgressIndicator(
            color: Color(0xFF800000),
          ),
        ),
      );
    }

    if (viewModel.errorMessage != null && viewModel.searchResults.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: responsive.iconSize(60), color: Colors.red),
              SizedBox(height: responsive.spacing(16)),
              Text(
                "Error loading courses",
                style: TextStyle(fontSize: responsive.sp(18), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: responsive.spacing(8)),
              SizedBox(
                height: responsive.buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF800000),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => viewModel.initialize(),
                  child: Text("Retry", style: TextStyle(fontSize: responsive.sp(14))),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.searchResults.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: responsive.iconSize(60), color: Colors.grey),
              SizedBox(height: responsive.spacing(16)),
              Text(
                "No courses found",
                style: TextStyle(fontSize: responsive.sp(18), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: responsive.spacing(8)),
              Text(
                "Try adjusting your filters",
                style: TextStyle(color: Colors.grey[600], fontSize: responsive.sp(14)),
              ),
              SizedBox(height: responsive.spacing(16)),
              // Suggest adding the course if not found
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF800000),
                  foregroundColor: Colors.white,
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
                icon: Icon(Icons.add),
                label: Text("Add This Course"),
              ),
              SizedBox(height: responsive.spacing(12)),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  viewModel.clearFilters();
                },
                child: Text("Clear Filters", style: TextStyle(fontSize: responsive.sp(14))),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.all(responsive.spacing(20)),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = viewModel.searchResults[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index != viewModel.searchResults.length - 1
                    ? responsive.spacing(16)
                    : 0,
              ),
              child: _buildCourseCard(context, course),
            );
          },
          childCount: viewModel.searchResults.length,
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    final responsive = context.responsive;

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF800000),
      ),
      padding: EdgeInsets.fromLTRB(
        responsive.spacing(20),
        0,
        responsive.spacing(20),
        responsive.spacing(30)
      ),
      child: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          return TextField(
            controller: _searchController,
            onChanged: (value) {
              viewModel.updateSearchQuery(value);
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search by course code or name...",
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.search, color: Colors.white),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.updateSearchQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    final responsive = context.responsive;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        responsive.spacing(20),
        responsive.spacing(20),
        responsive.spacing(20),
        responsive.spacing(10)
      ),
      child: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Faculty Filter
              Row(
                children: [
                  Icon(Icons.school, size: responsive.iconSize(16), color: Colors.grey[700]),
                  SizedBox(width: responsive.spacing(8)),
                  Text(
                    "Faculty:",
                    style: TextStyle(
                      fontSize: responsive.sp(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: responsive.spacing(10)),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: viewModel.availableFaculties.map((faculty) {
                          final isSelected = viewModel.selectedFaculty == faculty;
                          return Padding(
                            padding: EdgeInsets.only(right: responsive.spacing(8)),
                            child: FilterChip(
                              label: Text(faculty),
                              selected: isSelected,
                              onSelected: (selected) {
                                viewModel.updateFacultyFilter(faculty);
                              },
                              selectedColor: Color(0xFF800000),
                              backgroundColor: Colors.grey[200],
                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: responsive.sp(12),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(15)),

              // Rating Filter
              Row(
                children: [
                  Icon(Icons.star, size: responsive.iconSize(16), color: Colors.amber),
                  SizedBox(width: responsive.spacing(8)),
                  Text(
                    "Min Rating: ${viewModel.minRating.toStringAsFixed(1)}",
                    style: TextStyle(
                      fontSize: responsive.sp(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: viewModel.minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      activeColor: Color(0xFF800000),
                      onChanged: (value) {
                        viewModel.updateRatingFilter(value);
                      },
                    ),
                  ),
                ],
              ),

              // Clear Filters Button
              if (viewModel.searchQuery.isNotEmpty ||
                  viewModel.selectedFaculty != 'All' ||
                  viewModel.minRating > 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      viewModel.clearFilters();
                    },
                    icon: Icon(Icons.clear_all, size: responsive.iconSize(16)),
                    label: Text("Clear All Filters", style: TextStyle(fontSize: responsive.sp(14))),
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF800000),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    final responsive = context.responsive;
    final cardIconSize = responsive.isMobile ? 50.0 : 60.0;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
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
              Container(
                width: cardIconSize,
                height: cardIconSize,
                decoration: BoxDecoration(
                  color: Color(0xFF800000).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  course.id.substring(0, min(3, course.id.length)),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800000),
                    fontSize: responsive.sp(14),
                  ),
                ),
              ),
              SizedBox(width: responsive.spacing(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.id,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF800000),
                        fontSize: responsive.sp(12),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      course.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: responsive.sp(15),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: responsive.spacing(12)),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(8),
                            vertical: responsive.spacing(4)
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            course.facultyShort,
                            style: TextStyle(
                              fontSize: responsive.sp(11),
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.star_rounded, size: responsive.iconSize(16), color: Colors.amber),
                        SizedBox(width: responsive.spacing(4)),
                        Text(
                          course.averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: responsive.sp(13),
                          ),
                        ),
                        Text(
                          " (${course.totalReviews})",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: responsive.sp(13),
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
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}
