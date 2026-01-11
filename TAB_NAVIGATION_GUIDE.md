# Tab Navigation Guide - ELRate

## Overview
The ELRate app now features a **bottom tab navigation** with three main sections: Home, Search, and Profile. This provides a better user experience with clear separation of concerns and easy access to all features.

---

## 🏗️ Architecture

### Navigation Structure
```
MainNavigation (Bottom Tab Bar)
├── 🏠 Home Tab
├── 🔍 Search Tab
└── 👤 Profile Tab
```

---

## 📱 Tabs Overview

### 1. 🏠 **Home Tab**

**Purpose**: Browse & discover courses

**Features**:
- **Search Bar Shortcut**: Tapping opens the Search tab
- **Faculty Filter**: Horizontal scrollable chips to filter by faculty
  - Options: All, FSKTM, FEP, FPP, FBMK, Gen
- **Course List**: Scrollable list of all courses
- **Pull-to-Refresh**: Swipe down to refresh course data
- **Course Cards**: Display course info with ratings
- **Quick Navigation**: Tap any course → Course details → Add/edit review

**File**: [home_screen.dart](lib/views/home_screen.dart)
**ViewModel**: [course_list_viewmodel.dart](lib/viewmodels/course_list_viewmodel.dart)

**Key Components**:
```dart
- _buildSearchBarShortcut()  // Search bar that opens Search tab
- _buildFacultyFilter()      // Faculty filter chips
- _buildCourseCard()         // Individual course cards
```

---

### 2. 🔍 **Search Tab**

**Purpose**: Advanced search & filtering

**Features**:
- **Search Input**: Real-time search by course code or name
- **Faculty Filter**: Filter by specific faculty
- **Rating Filter**: Slider to set minimum rating (0-5 stars)
- **Clear Filters**: One-tap to reset all filters
- **Live Results**: Results update as you type/filter
- **Pull-to-Refresh**: Swipe down to refresh data
- **Empty States**: Helpful messages when no results found

**File**: [search_screen.dart](lib/views/search_screen.dart)
**ViewModel**: [search_viewmodel.dart](lib/viewmodels/search_viewmodel.dart)

**Search Capabilities**:
| Filter Type | Options |
|-------------|---------|
| **Search Query** | Course code (e.g., "SCSJ2313") or name (e.g., "Mobile") |
| **Faculty** | All, FSKTM, FEP, FPP, FBMK, Gen |
| **Min Rating** | 0.0 to 5.0 stars (slider) |

**Key Components**:
```dart
- _buildSearchInput()   // Search text field
- _buildFilters()       // Faculty & rating filters
- _buildCourseCard()    // Search result cards
```

---

### 3. 👤 **Profile Tab**

**Purpose**: User management & personal reviews

**Features**:
- **Profile Header**:
  - Avatar with user initials
  - Username display
  - Email display
- **Profile Options**:
  - ✏️ Edit Profile (name & email)
  - ⚙️ Settings (coming soon)
  - ❓ Help & Support (coming soon)
  - ℹ️ About (app info)
  - 🚪 Logout
- **My Reviews**: List of user's submitted reviews
- **Empty State**: Encourages users to start rating courses

**File**: [profile_screen.dart](lib/views/profile_screen.dart)
**ViewModel**: [profile_viewmodel.dart](lib/viewmodels/profile_viewmodel.dart)

**Key Components**:
```dart
- _buildProfileHeader()     // Avatar, name, email
- _buildProfileOptions()    // Settings, logout, etc.
- _buildMyReviews()        // User's review list
```

---

## 🎨 UI/UX Features

### Bottom Navigation Bar
- **Selected Color**: UPM Maroon (#800000)
- **Unselected Color**: Grey
- **Icons**:
  - Home: `Icons.home`
  - Search: `Icons.search`
  - Profile: `Icons.person`

### Screen Transitions
- Uses `IndexedStack` for instant tab switching
- Preserves state across tabs (no data reload)
- Smooth animations

### Color Scheme
- **Primary**: UPM Maroon (#800000)
- **Background**: Light Grey (#FAFAFA)
- **Cards**: White with elevation
- **Accents**: Amber (for ratings)

---

## 📊 Data Flow

### Home Tab Flow
```
User opens app
    ↓
HomeScreen loads
    ↓
CourseListViewModel.fetchCourses()
    ↓
ApiService.getCourses()
    ↓
Display course list
    ↓
User taps search bar → Navigate to Search tab
User taps faculty filter → Filter locally
User taps course → Navigate to CourseDetailScreen
```

### Search Tab Flow
```
User switches to Search tab
    ↓
SearchScreen loads
    ↓
SearchViewModel.initialize()
    ↓
Fetch all courses
    ↓
User types search query
    ↓
SearchViewModel.updateSearchQuery()
    ↓
_applyFilters() → Live filtering
    ↓
Display filtered results
```

### Profile Tab Flow
```
User switches to Profile tab
    ↓
ProfileScreen loads
    ↓
Display user info
    ↓
ProfileViewModel.fetchMyReviews()
    ↓
Display user's reviews (or empty state)
```

---

## 🔧 Technical Implementation

### Files Created/Modified

**New Files** (11):
1. [lib/views/main_navigation.dart](lib/views/main_navigation.dart) - Tab navigation container
2. [lib/views/home_screen.dart](lib/views/home_screen.dart) - Home tab UI
3. [lib/views/search_screen.dart](lib/views/search_screen.dart) - Search tab UI
4. [lib/views/profile_screen.dart](lib/views/profile_screen.dart) - Profile tab UI
5. [lib/viewmodels/search_viewmodel.dart](lib/viewmodels/search_viewmodel.dart) - Search logic
6. [lib/viewmodels/profile_viewmodel.dart](lib/viewmodels/profile_viewmodel.dart) - Profile logic
7. [lib/models/user.dart](lib/models/user.dart) - User data model

**Modified Files** (1):
1. [lib/main.dart](lib/main.dart) - Added SearchViewModel & ProfileViewModel providers

### State Management

All tabs use **Provider** for state management:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CourseListViewModel()),
    ChangeNotifierProvider(create: (_) => SearchViewModel()),
    ChangeNotifierProvider(create: (_) => ProfileViewModel()),
  ],
  child: MaterialApp(
    home: MainNavigation(),
  ),
)
```

### Navigation Pattern

**Tab Switching**:
- Uses `BottomNavigationBar.onTap`
- Updates `_currentIndex` state
- `IndexedStack` displays corresponding screen

**Cross-Tab Navigation**:
- Home → Search: Callback pattern (`onSearchTap`)
- Any tab → Course Details: Standard `Navigator.push()`

---

## 🎯 User Journeys

### Journey 1: Browse by Faculty
```
1. User opens app (Home tab)
2. User taps faculty filter (e.g., "FSKTM")
3. Course list filters to show only FSKTM courses
4. User taps a course
5. User views details and reviews
6. User taps "Write Review"
7. User submits review
8. Returns to filtered Home view
```

### Journey 2: Search for Specific Course
```
1. User taps Search tab
2. User types course code (e.g., "SCSJ2313")
3. Results filter in real-time
4. User adjusts min rating filter
5. User taps matching course
6. User views details and submits review
```

### Journey 3: Manage Profile
```
1. User taps Profile tab
2. User views their profile info
3. User taps "Edit Profile"
4. User updates name/email
5. User saves changes
6. Profile updates immediately
7. User views their past reviews
```

---

## 📈 Features Comparison

| Feature | Home Tab | Search Tab | Profile Tab |
|---------|----------|------------|-------------|
| Browse Courses | ✅ | ✅ | ❌ |
| Search by Name/Code | ❌ | ✅ | ❌ |
| Faculty Filter | ✅ | ✅ | ❌ |
| Rating Filter | ❌ | ✅ | ❌ |
| Quick Search Bar | ✅ (shortcut) | ✅ (full) | ❌ |
| Pull-to-Refresh | ✅ | ✅ | ❌ |
| User Info | ❌ | ❌ | ✅ |
| My Reviews | ❌ | ❌ | ✅ |
| Settings | ❌ | ❌ | ✅ |

---

## 🚀 Future Enhancements

### Planned Features

**Home Tab**:
- [ ] Recently viewed courses
- [ ] Recommended courses based on ratings
- [ ] Quick stats (total courses, avg rating, etc.)

**Search Tab**:
- [ ] Search history
- [ ] Save search filters
- [ ] Sort options (by rating, reviews, alphabetical)
- [ ] Advanced filters (course level, semester, etc.)

**Profile Tab**:
- [ ] Upload profile picture
- [ ] View review analytics (total reviews, avg rating given)
- [ ] Edit/delete own reviews
- [ ] Notification settings
- [ ] Dark mode toggle
- [ ] Language preferences

**General**:
- [ ] Offline mode with local caching
- [ ] Push notifications for new reviews
- [ ] Share course links
- [ ] Bookmark favorite courses
- [ ] Report inappropriate reviews

---

## 🐛 Known Issues & Solutions

### Issue 1: Tab state reset
**Problem**: Tabs lose state when switching
**Solution**: Using `IndexedStack` instead of conditional rendering

### Issue 2: Search bar doesn't navigate
**Problem**: DefaultTabController not available
**Solution**: Callback pattern from MainNavigation to HomeScreen

### Issue 3: Profile reviews always empty
**Current**: Placeholder implementation
**Future**: Backend API integration needed

---

## 📝 Code Examples

### Adding a New Tab

```dart
// 1. Create the screen widget
class NewTabScreen extends StatefulWidget { ... }

// 2. Create the ViewModel
class NewTabViewModel extends ChangeNotifier { ... }

// 3. Add provider in main.dart
ChangeNotifierProvider(create: (_) => NewTabViewModel()),

// 4. Add to MainNavigation
final screens = [
  HomeScreen(...),
  SearchScreen(),
  ProfileScreen(),
  NewTabScreen(), // Add here
];

// 5. Add bottom navigation item
BottomNavigationBarItem(
  icon: Icon(Icons.new_icon),
  label: 'New Tab',
),
```

### Implementing Search

```dart
// In ViewModel
void updateSearchQuery(String query) {
  _searchQuery = query;
  _applyFilters();
}

void _applyFilters() {
  _searchResults = _allCourses.where((course) {
    return course.name.toLowerCase().contains(_searchQuery.toLowerCase());
  }).toList();
  notifyListeners();
}

// In View
TextField(
  onChanged: (value) {
    context.read<SearchViewModel>().updateSearchQuery(value);
  },
)
```

---

## ✅ Testing Checklist

- [x] Tab navigation works smoothly
- [x] Home tab displays courses
- [x] Faculty filter works on Home tab
- [x] Search bar shortcut navigates to Search tab
- [x] Search functionality works in real-time
- [x] Faculty filter works on Search tab
- [x] Rating filter works on Search tab
- [x] Clear filters button works
- [x] Profile displays user info
- [x] Edit profile dialog works
- [x] About dialog displays
- [x] Logout confirmation works
- [x] State persists when switching tabs
- [x] Pull-to-refresh works on Home and Search
- [x] Course navigation works from all tabs
- [x] Empty states display correctly
- [x] Error states display correctly
- [x] Loading states display correctly

---

## 🎓 Learning Resources

- [Flutter BottomNavigationBar](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html)
- [IndexedStack Widget](https://api.flutter.dev/flutter/widgets/IndexedStack-class.html)
- [Provider State Management](https://pub.dev/packages/provider)
- [Material Design Navigation](https://m3.material.io/components/navigation-bar/overview)

---

## 📞 Support

For questions or issues:
1. Check [MVVM_ARCHITECTURE.md](MVVM_ARCHITECTURE.md) for architecture details
2. Review [REFACTORING_SUMMARY.md](REFACTORING_SUMMARY.md) for project structure
3. Contact your development team

---

**Version**: 2.0.0
**Last Updated**: January 2026
**Authors**: Claude Code (Anthropic)

**Happy Navigating! 🚀**
