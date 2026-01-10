import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(ELRateApp());
}

class ELRateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ELRate',
      theme: ThemeData(
        primaryColor: Color(0xFF800000), // UPM Maroon
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF800000),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: CourseListScreen(),
    );
  }
}

// --- 1. CONFIGURATION ---
// PASTE YOUR URLs HERE
const String getCoursesUrl = "https://getcourse-1089993125152.asia-southeast2.run.app";
const String submitReviewUrl = "https://submitreview-1089993125152.asia-southeast2.run.app";
// You need to deploy the 3rd function from Part 1 and paste it here:
const String getReviewsUrl = "https://getreviews-1089993125152.asia-southeast2.run.app"; 

// --- 2. COURSE LIST SCREEN ---
class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  List<dynamic> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final response = await http.get(Uri.parse(getCoursesUrl));
      if (response.statusCode == 200) {
        setState(() {
          _courses = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ELRate Subjects")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF800000)))
          : RefreshIndicator(
              onRefresh: _fetchCourses, // Pull to refresh list
              child: ListView.builder(
                padding: EdgeInsets.all(15),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  // Safety checks for nulls
                  double rating = (course['averageRating'] ?? 0).toDouble();
                  int reviews = course['totalReviews'] ?? 0;

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF800000).withOpacity(0.1),
                        child: Text(course['id'].substring(0, 3), 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800000), fontSize: 12)),
                      ),
                      title: Text(course['id'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course['name']),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              // TAG
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                                child: Text(course['facultyShort'] ?? "Gen", 
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              Spacer(),
                              Icon(Icons.star, size: 14, color: Colors.amber),
                              Text(" ${rating.toStringAsFixed(1)} ($reviews)"),
                            ],
                          )
                        ],
                      ),
                      onTap: () async {
                        // Wait for them to come back, then refresh the list (to update rating)
                        await Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CourseDetailScreen(course: course)
                        ));
                        _fetchCourses(); 
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// --- 3. DETAILS SCREEN (Fetches Reviews via HTTP) ---
class CourseDetailScreen extends StatefulWidget {
  final Map<dynamic, dynamic> course;
  CourseDetailScreen({required this.course});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  List<dynamic> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  // Fetch reviews from your new 'getreviews' Cloud Function
  Future<void> _fetchReviews() async {
    try {
      // We pass the courseId as a query parameter
      final uri = Uri.parse("$getReviewsUrl?courseId=${widget.course['id']}");
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        setState(() {
          _reviews = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching reviews: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course['id'])),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF800000),
        icon: Icon(Icons.edit, color: Colors.white),
        label: Text("Write Review", style: TextStyle(color: Colors.white)),
        onPressed: () async {
           // Go to Add Review Page
           await Navigator.push(context, MaterialPageRoute(
             builder: (_) => AddReviewScreen(courseId: widget.course['id'])
           ));
           // When they come back, REFRESH the reviews to see the new one
           _isLoading = true; 
           setState(() {});
           _fetchReviews();
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.course['name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF800000))),
                  SizedBox(height: 10),
                  Text(widget.course['faculty'], style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                  SizedBox(height: 20),
                  Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 5),
                  Text(widget.course['description'], style: TextStyle(height: 1.5, fontSize: 15)),
                  SizedBox(height: 20),
                  Divider(),
                  Text("Student Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ),
          
          // REVIEWS LIST
          _isLoading 
            ? SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())))
            : _reviews.isEmpty
              ? SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No reviews yet."))))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var data = _reviews[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(radius: 12, backgroundColor: Colors.grey[300], child: Icon(Icons.person, size: 16, color: Colors.white)),
                                  SizedBox(width: 8),
                                  Text(data['studentName'] ?? "Anonymous", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Spacer(),
                                  Icon(Icons.star, size: 16, color: Colors.amber),
                                  Text(" ${data['rating']}"),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(data['comment']),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _reviews.length,
                  ),
                )
        ],
      ),
    );
  }
}

// --- 4. ADD REVIEW SCREEN (HTTP POST) ---
class AddReviewScreen extends StatefulWidget {
  final String courseId;
  AddReviewScreen({required this.courseId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _commentCtrl = TextEditingController();
  double _rating = 5.0;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_commentCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      // Sending data to Cloud Function
      await http.post(
        Uri.parse(submitReviewUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "courseId": widget.courseId,
          "studentName": "Student (App)", 
          "rating": _rating,
          "comment": _commentCtrl.text,
        }),
      );
      
      Navigator.pop(context); // Go back
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Review Posted!")));
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connection Error")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rate ${widget.courseId}")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Rate this course", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(_rating.toStringAsFixed(1), style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF800000))),
            Slider(
              value: _rating, min: 1, max: 5, divisions: 4,
              activeColor: Color(0xFF800000),
              onChanged: (val) => setState(() => _rating = val),
            ),
            TextField(
              controller: _commentCtrl,
              decoration: InputDecoration(
                labelText: "Your experience...",
                border: OutlineInputBorder()
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity, 
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800000), foregroundColor: Colors.white),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("SUBMIT"),
              ),
            )
          ],
        ),
      ),
    );
  }
}