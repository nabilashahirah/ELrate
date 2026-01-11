import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../models/course.dart';
import 'course_detail_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Courses"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Input
          _buildSearchInput(),

          // Filters
          _buildFilters(),

          // Results
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF800000),
                    ),
                  );
                }

                if (viewModel.errorMessage != null && viewModel.searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          "Error loading courses",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF800000),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => viewModel.initialize(),
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No courses found",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Try adjusting your filters",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            viewModel.clearFilters();
                          },
                          child: Text("Clear Filters"),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.refresh(),
                  child: ListView.separated(
                    padding: EdgeInsets.all(20),
                    itemCount: viewModel.searchResults.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildCourseCard(context, viewModel.searchResults[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF800000),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
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
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Faculty Filter
              Row(
                children: [
                  Icon(Icons.school, size: 16, color: Colors.grey[700]),
                  SizedBox(width: 8),
                  Text(
                    "Faculty:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: viewModel.availableFaculties.map((faculty) {
                          final isSelected = viewModel.selectedFaculty == faculty;
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
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
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Rating Filter
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    "Min Rating: ${viewModel.minRating.toStringAsFixed(1)}",
                    style: TextStyle(
                      fontSize: 14,
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
                    icon: Icon(Icons.clear_all, size: 16),
                    label: Text("Clear All Filters"),
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
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
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
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.id,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF800000),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      course.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            course.facultyShort,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          course.averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          " (${course.totalReviews})",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
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
