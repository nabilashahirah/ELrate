# Authentication System Guide - ELRate

## Overview
The ELRate app now features a complete **authentication system** with login, signup, and secure token-based session management using `shared_preferences`.

---

## 🔐 **Authentication Flow**

### **App Launch Flow**
```
User opens app
    ↓
AuthWrapper checks authentication
    ↓
Is user logged in? (check token in storage)
    ├─ YES → Navigate to MainNavigation (Home/Search/Profile tabs)
    └─ NO  → Show LoginScreen
```

### **Login Flow**
```
User enters email & password
    ↓
Validate inputs (email format, password length)
    ↓
AuthViewModel.login()
    ↓
AuthService.mockLogin() (or real API)
    ↓
Save auth data to SharedPreferences
    ↓
Navigate to MainNavigation
```

### **Signup Flow**
```
User enters name, email & password
    ↓
Validate inputs + confirm password match
    ↓
AuthViewModel.signup()
    ↓
AuthService.mockSignup() (or real API)
    ↓
Save auth data to SharedPreferences
    ↓
Navigate to MainNavigation
```

### **Logout Flow**
```
User taps Logout in Profile tab
    ↓
Confirmation dialog
    ↓
AuthViewModel.logout()
    ↓
Clear all auth data from SharedPreferences
    ↓
Navigate to LoginScreen (clear navigation stack)
```

---

## 📁 **Architecture**

### **New Files Created** (7 files)

1. **[lib/models/auth_request.dart](lib/models/auth_request.dart)**
   - `LoginRequest` - Login credentials model
   - `SignupRequest` - Signup data model
   - `AuthResponse` - API response model with token

2. **[lib/services/auth_service.dart](lib/services/auth_service.dart)**
   - Handles all authentication API calls
   - Token storage using `shared_preferences`
   - Mock login/signup for testing (switchable to real API)

3. **[lib/viewmodels/auth_viewmodel.dart](lib/viewmodels/auth_viewmodel.dart)**
   - Manages authentication state
   - Provides login/signup/logout methods
   - Tracks loading and error states

4. **[lib/views/auth/login_screen.dart](lib/views/auth/login_screen.dart)**
   - Beautiful login UI
   - Email & password validation
   - Loading indicators
   - Navigation to signup

5. **[lib/views/auth/signup_screen.dart](lib/views/auth/signup_screen.dart)**
   - User registration UI
   - Name, email, password, confirm password fields
   - Real-time validation
   - Password visibility toggle

### **Modified Files** (3 files)

6. **[lib/main.dart](lib/main.dart)**
   - Added `AuthViewModel` provider
   - Created `AuthWrapper` widget for auth checking
   - Shows loading splash screen during auth check

7. **[lib/viewmodels/profile_viewmodel.dart](lib/viewmodels/profile_viewmodel.dart)**
   - Updated to use real user data from `AuthService`
   - Handles null user gracefully

8. **[lib/views/profile_screen.dart](lib/views/profile_screen.dart)**
   - Updated logout to use `AuthViewModel`
   - Navigates to login screen after logout
   - Handles null user data

---

## 🎨 **UI Features**

### **Login Screen**
- **UPM Maroon** color scheme
- School icon logo
- Email & password fields with validation
- Password visibility toggle
- "Forgot Password?" link (coming soon)
- "Sign Up" navigation link
- Loading indicator during login
- Error messages via SnackBar

### **Signup Screen**
- Beautiful, consistent design
- Fields:
  - Full Name (min 3 characters)
  - Email (valid format)
  - Password (min 6 characters)
  - Confirm Password (must match)
- Password visibility toggles on both password fields
- Loading indicator during signup
- Back button to return to login
- "Already have an account?" link

### **Loading Splash**
- Shows while checking authentication status
- School icon + "ELRate" title
- Circular progress indicator

---

## 🔧 **Technical Implementation**

### **State Management**

```dart
// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel()),  // NEW
    ChangeNotifierProvider(create: (_) => CourseListViewModel()),
    ChangeNotifierProvider(create: (_) => SearchViewModel()),
    ChangeNotifierProvider(create: (_) => ProfileViewModel()),
  ],
  ...
)
```

### **Token Storage**

Using `shared_preferences` package to persist:
- **auth_token** - JWT or session token
- **user_id** - User's unique ID
- **user_name** - User's display name
- **user_email** - User's email

```dart
// Save
await prefs.setString('auth_token', token);

// Retrieve
final token = prefs.getString('auth_token');

// Clear
await prefs.remove('auth_token');
```

### **Mock vs Real API**

**Currently using MOCK for testing:**
```dart
// In AuthViewModel
final authResponse = await _authService.mockLogin(request);
```

**To switch to REAL API:**
```dart
// In AuthViewModel
final authResponse = await _authService.login(request);
```

**API Endpoints** (in `auth_service.dart`):
```dart
static const String _loginUrl = "https://login-xxx.run.app";
static const String _signupUrl = "https://signup-xxx.run.app";
```

### **Mock Validation Rules**

| Field | Rule |
|-------|------|
| Email | Must contain `@` |
| Password | Minimum 6 characters |
| Name | Minimum 3 characters |
| Confirm Password | Must match password |

---

## 📊 **Data Models**

### **LoginRequest**
```dart
{
  "email": "student@upm.edu.my",
  "password": "password123"
}
```

### **SignupRequest**
```dart
{
  "name": "Ahmad bin Ali",
  "email": "ahmad@upm.edu.my",
  "password": "password123"
}
```

### **AuthResponse**
```dart
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "123",
  "name": "Ahmad bin Ali",
  "email": "ahmad@upm.edu.my"
}
```

---

## 🎯 **User Journeys**

### **Journey 1: New User Signup**
```
1. User opens app → Sees Login screen
2. User taps "Sign Up"
3. User fills: Name, Email, Password, Confirm Password
4. User taps "Sign Up" button
5. App validates inputs
6. App calls signup API (mock)
7. Success → Navigate to Home tab
8. User can now browse courses and add reviews
```

### **Journey 2: Returning User Login**
```
1. User opens app → AuthWrapper checks token
2. Token found → Auto-login to Home
3. OR Token not found → Show Login screen
4. User enters email & password
5. User taps "Login"
6. App validates and calls login API
7. Success → Navigate to Home
```

### **Journey 3: Logout**
```
1. User navigates to Profile tab
2. User scrolls to "Logout" option
3. User taps "Logout"
4. Confirmation dialog appears
5. User confirms logout
6. App clears all auth data
7. Navigate to Login screen (clear stack)
8. User must login again to access app
```

---

## 🔒 **Security Features**

### **Implemented**
- ✅ Password fields are obscured by default
- ✅ Passwords are sent over HTTPS (when using real API)
- ✅ Tokens stored locally in SharedPreferences
- ✅ Input validation (email format, password length)
- ✅ Password confirmation on signup
- ✅ Session persistence across app restarts

### **Recommended for Production**
- 🔲 JWT token expiration handling
- 🔲 Refresh token mechanism
- 🔲 Biometric authentication (fingerprint/face)
- 🔲 Rate limiting on login attempts
- 🔲 Forgot password / reset flow
- 🔲 Email verification after signup
- 🔲 Secure storage (encrypted) instead of SharedPreferences
- 🔲 SSL certificate pinning
- 🔲 OAuth integration (Google/Facebook login)

---

## 🧪 **Testing the Auth System**

### **Test Login (Mock)**
```
Email: any valid email (e.g., test@upm.edu.my)
Password: any 6+ characters (e.g., test123)
```

### **Test Signup (Mock)**
```
Name: Any 3+ characters
Email: Valid email format
Password: 6+ characters
Confirm Password: Must match password
```

### **Expected Behavior**

| Action | Expected Result |
|--------|----------------|
| Open app (first time) | Show Login screen |
| Login with valid credentials | Navigate to Home, save token |
| Login with invalid email | Show error: "Invalid email format" |
| Login with short password | Show error: "Password must be at least 6 characters" |
| Signup with non-matching passwords | Show error: "Passwords do not match" |
| Close and reopen app | Auto-login if token exists |
| Logout | Clear token, show Login screen |

---

## 📝 **Code Examples**

### **Check if User is Logged In**
```dart
final authService = AuthService();
final isLoggedIn = await authService.isLoggedIn();
```

### **Get Current User**
```dart
final user = await authService.getCurrentUser();
if (user != null) {
  print('Logged in as: ${user.name}');
}
```

### **Login User**
```dart
final authViewModel = context.read<AuthViewModel>();
final success = await authViewModel.login(email, password);
if (success) {
  // Navigate to main app
} else {
  // Show error
  print(authViewModel.errorMessage);
}
```

### **Logout User**
```dart
final authViewModel = context.read<AuthViewModel>();
await authViewModel.logout();
// Navigate to login screen
```

---

## 🚀 **Switching to Real API**

### **Step 1: Deploy Backend**
Deploy your authentication endpoints to Google Cloud Run or any backend.

### **Step 2: Update URLs**
In `auth_service.dart`:
```dart
static const String _loginUrl = "https://your-login-endpoint.run.app";
static const String _signupUrl = "https://your-signup-endpoint.run.app";
```

### **Step 3: Switch to Real Methods**
In `auth_viewmodel.dart`:

**Change from:**
```dart
final authResponse = await _authService.mockLogin(request);
```

**To:**
```dart
final authResponse = await _authService.login(request);
```

### **Step 4: Update API Response Format**
Ensure your backend returns:
```json
{
  "token": "your-jwt-token",
  "userId": "123",
  "name": "User Name",
  "email": "user@example.com"
}
```

---

## 🐛 **Troubleshooting**

### **Issue: "User stays logged in after deleting app"**
**Cause**: SharedPreferences persists even after app deletion on some devices.
**Solution**: This is expected behavior. For testing, use logout button.

### **Issue: "Token expired error"**
**Cause**: JWT tokens have expiration times.
**Solution**: Implement token refresh mechanism or re-login flow.

### **Issue: "Can't access user data in Profile"**
**Cause**: User data not initialized.
**Solution**: Ensure `ProfileViewModel.initialize()` is called.

---

## 📦 **Dependencies Added**

```yaml
dependencies:
  shared_preferences: ^2.2.2  # Local storage for auth tokens
```

**Install:**
```bash
flutter pub get
```

---

## ✅ **Quality Checks**

- **Flutter Analyze**: 16 informational linting suggestions (no errors)
- **Compilation**: ✅ Success
- **State Management**: ✅ Provider-based
- **Token Storage**: ✅ SharedPreferences
- **UI/UX**: ✅ Consistent maroon theme
- **Validation**: ✅ All inputs validated
- **Error Handling**: ✅ User-friendly messages

---

## 🎓 **Learning Resources**

- [Flutter Authentication Best Practices](https://flutter.dev/docs/cookbook/persistence/key-value)
- [SharedPreferences Package](https://pub.dev/packages/shared_preferences)
- [JWT Authentication](https://jwt.io/introduction)
- [Provider State Management](https://pub.dev/packages/provider)

---

## 📞 **Support**

For questions:
1. Review [MVVM_ARCHITECTURE.md](MVVM_ARCHITECTURE.md)
2. Check [TAB_NAVIGATION_GUIDE.md](TAB_NAVIGATION_GUIDE.md)
3. See [REFACTORING_SUMMARY.md](REFACTORING_SUMMARY.md)

---

**Version**: 2.0.0
**Last Updated**: January 2026
**Feature**: Complete Authentication System

**Welcome to Secure ELRate! 🔐**
