# ELRate MVVM Architecture Documentation

## Overview
This project follows the **MVVM (Model-View-ViewModel)** architectural pattern, which provides a clean separation of concerns and makes the code more maintainable, testable, and scalable.

## Architecture Layers

### 1. **Model** (`lib/models/`)
Models represent the data structures used throughout the app.

- **`course.dart`**: Represents a university course with properties like id, name, faculty, description, ratings, etc.
- **`review.dart`**: Represents a student review with courseId, studentName, rating, and comment.

**Responsibilities:**
- Define data structures
- Handle JSON serialization/deserialization
- Provide factory constructors for creating objects from API responses

**Example:**
```dart
final course = Course.fromJson(jsonData);
final jsonMap = course.toJson();
```

---

### 2. **View** (`lib/views/`)
Views are the UI components that display data to users and capture user interactions.

- **`course_list_screen.dart`**: Displays list of all courses with ratings
- **`course_detail_screen.dart`**: Shows course details and reviews
- **`add_review_screen.dart`**: Form for submitting new reviews

**Responsibilities:**
- Render UI components
- Display data from ViewModels
- Capture user input
- Navigate between screens
- **NO business logic or data manipulation**

**Key Principles:**
- Views should be "dumb" - they only display data
- Use `Consumer` or `context.watch()` to listen to ViewModel changes
- Use `context.read()` to call ViewModel methods
- Always check `mounted` before using `BuildContext` after async operations

**Example:**
```dart
Consumer<CourseListViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.isLoading) {
      return CircularProgressIndicator();
    }
    return ListView(...);
  },
)
```

---

### 3. **ViewModel** (`lib/viewmodels/`)
ViewModels act as a bridge between Views and Models/Services, managing UI state and business logic.

- **`course_list_viewmodel.dart`**: Manages course list state and operations
- **`course_detail_viewmodel.dart`**: Manages course details and reviews
- **`add_review_viewmodel.dart`**: Manages review submission logic

**Responsibilities:**
- Hold UI state (loading, error messages, data)
- Fetch data from services
- Transform data for display
- Handle business logic
- Notify views of state changes via `notifyListeners()`

**Key Principles:**
- Extend `ChangeNotifier` for reactive updates
- Expose only getters (immutable state to views)
- Provide methods for actions (e.g., `fetchCourses()`, `submitReview()`)
- Handle errors gracefully
- **NO direct UI code (no Widgets, BuildContext, etc.)**

**Example:**
```dart
class CourseListViewModel extends ChangeNotifier {
  List<Course> _courses = [];
  bool _isLoading = false;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;

  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _courses = await _apiService.getCourses();
    } catch (e) {
      // handle error
    }

    _isLoading = false;
    notifyListeners();
  }
}
```

---

### 4. **Service** (`lib/services/`)
Services handle external communication and data operations.

- **`api_service.dart`**: Handles all HTTP requests to backend APIs

**Responsibilities:**
- Make network calls
- Handle HTTP requests/responses
- Convert raw data to Models
- Centralize API endpoint management
- Implement singleton pattern for shared instances

**Key Principles:**
- Should be stateless
- Return Models, not raw JSON
- Throw exceptions on errors (let ViewModels handle them)
- Use singleton pattern for efficiency

**Example:**
```dart
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  Future<List<Course>> getCourses() async {
    final response = await http.get(Uri.parse(_url));
    final jsonData = json.decode(response.body);
    return jsonData.map((json) => Course.fromJson(json)).toList();
  }
}
```

---

### 5. **Utils** (`lib/utils/`)
Utility classes and constants.

- **`constants.dart`**: App-wide constants (API URLs, colors, strings)

---

## Data Flow

```
User Interaction → View → ViewModel → Service → API
                    ↑         ↓
                    ← notifyListeners() ←
```

1. **User interacts** with View (tap button, pull to refresh)
2. **View calls** ViewModel method (e.g., `viewModel.fetchCourses()`)
3. **ViewModel calls** Service to fetch data
4. **Service makes** HTTP request and returns Models
5. **ViewModel updates** state and calls `notifyListeners()`
6. **View rebuilds** automatically via `Consumer`/`watch()`

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, sets up providers
├── models/
│   ├── course.dart                    # Course data model
│   └── review.dart                    # Review data model
├── viewmodels/
│   ├── course_list_viewmodel.dart     # Course list business logic
│   ├── course_detail_viewmodel.dart   # Course detail business logic
│   └── add_review_viewmodel.dart      # Add review business logic
├── views/
│   ├── course_list_screen.dart        # Course list UI
│   ├── course_detail_screen.dart      # Course detail UI
│   └── add_review_screen.dart         # Add review UI
├── services/
│   └── api_service.dart               # HTTP API service
└── utils/
    └── constants.dart                 # App constants
```

---

## State Management: Provider

This project uses **Provider** for state management.

### Setting up Providers

In `main.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CourseListViewModel()),
  ],
  child: MaterialApp(...),
)
```

### Accessing ViewModels in Views

**Read-only access (triggers rebuild):**
```dart
final viewModel = context.watch<CourseListViewModel>();
// or
Consumer<CourseListViewModel>(
  builder: (context, viewModel, child) {
    return Text(viewModel.courses.length.toString());
  },
)
```

**Write-only access (no rebuild):**
```dart
context.read<CourseListViewModel>().fetchCourses();
```

---

## Benefits of MVVM

1. **Separation of Concerns**: Each layer has a clear responsibility
2. **Testability**: ViewModels can be unit tested without UI
3. **Reusability**: ViewModels and Models can be reused across different Views
4. **Maintainability**: Changes in one layer don't affect others
5. **Scalability**: Easy to add new features following the same pattern
6. **Reactive UI**: UI automatically updates when state changes

---

## Best Practices

### ✅ DO:
- Keep Views simple and focused on UI
- Put business logic in ViewModels
- Use Models for data structures
- Handle errors gracefully in ViewModels
- Use `notifyListeners()` after state changes
- Check `mounted` before using context after async operations
- Use `const` constructors where possible
- Dispose controllers and resources properly

### ❌ DON'T:
- Put business logic in Views
- Make ViewModels aware of UI (no Widgets, BuildContext)
- Directly call APIs from Views
- Mutate state without calling `notifyListeners()`
- Expose mutable state from ViewModels (use getters)
- Forget to handle loading and error states

---

## Example: Adding a New Feature

To add a "Favorite Courses" feature:

1. **Update Model** (`course.dart`):
   ```dart
   final bool isFavorite;
   ```

2. **Create/Update Service** (`api_service.dart`):
   ```dart
   Future<void> toggleFavorite(String courseId) async { ... }
   ```

3. **Update ViewModel** (`course_list_viewmodel.dart`):
   ```dart
   Future<void> toggleFavorite(String courseId) async {
     await _apiService.toggleFavorite(courseId);
     await fetchCourses(); // refresh
   }
   ```

4. **Update View** (`course_list_screen.dart`):
   ```dart
   IconButton(
     icon: Icon(course.isFavorite ? Icons.favorite : Icons.favorite_border),
     onPressed: () => context.read<CourseListViewModel>().toggleFavorite(course.id),
   )
   ```

---

## Testing Strategy

### Unit Tests (ViewModels & Services):
```dart
test('fetchCourses updates courses list', () async {
  final viewModel = CourseListViewModel();
  await viewModel.fetchCourses();
  expect(viewModel.courses.isNotEmpty, true);
  expect(viewModel.isLoading, false);
});
```

### Widget Tests (Views):
```dart
testWidgets('CourseListScreen displays courses', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => MockCourseListViewModel(),
      child: MaterialApp(home: CourseListScreen()),
    ),
  );
  expect(find.text('ELRate Subjects'), findsOneWidget);
});
```

---

## Migration from Old Code

The old monolithic `main.dart` (334 lines) has been refactored into:
- 2 Model classes (clean data structures)
- 1 API Service (centralized networking)
- 3 ViewModels (business logic separation)
- 3 View screens (pure UI)
- 1 Constants file (configuration)

**Result**: Better organization, testability, and maintainability!

---

## References

- [Flutter Provider Documentation](https://pub.dev/packages/provider)
- [MVVM Pattern Explained](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
