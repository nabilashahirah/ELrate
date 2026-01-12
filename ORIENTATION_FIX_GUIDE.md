# Orientation Support Guide

## Quick Fix for Landscape/Portrait Support

Your app's responsive system already detects orientation. To prevent layout issues when rotating:

### 1. **Already Handled** ✅
- Signup screen: Uses `Flexible` header that hides when keyboard appears
- Profile, Search, Course List: Already scrollable
- Home screen: Scrollable content

### 2. **Simple Solution for Login Screen**

The login screen uses `Expanded` which can overflow in landscape. Here are two options:

#### Option A: Keep Current Design (Recommended for most cases)
Add `resizeToAvoidBottomInset: false` to prevent keyboard from pushing content:

```dart
return Scaffold(
  backgroundColor: Color(0xFF800000),
  resizeToAvoidBottomInset: false,  // Add this line
  body: Stack(
    children: [
      // existing code...
    ],
  ),
);
```

#### Option B: Make Fully Adaptive (For extreme landscape scenarios)
Wrap the Column in SingleChildScrollView and use LayoutBuilder:

```dart
return Scaffold(
  body: SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        // Detect if in cramped landscape
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final isCramped = isLandscape && constraints.maxHeight < 400;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  if (!isCramped) HeaderSection(),  // Hide header in cramped landscape
                  FormSection(),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ),
);
```

### 3. **Testing Orientation**

```bash
# Run app
flutter run

# In Android Emulator:
- Press Ctrl + F11 (Windows) or Cmd + Left/Right Arrow (Mac) to rotate
- Test all screens in both orientations
```

### 4. **What to Check**

✅ **Portrait Mode:**
- All content visible
- No overflow
- Proper spacing

✅ **Landscape Mode:**
- Content scrollable
- No red overflow errors
- Keyboard doesn't cover inputs
- Navigation accessible

## Current Status

Your app already handles orientation well because:
1. Responsive utility detects `isPortrait` and `isLandscape`
2. Most screens use `SingleChildScrollView`
3. Signup screen conditionally shows header based on keyboard
4. All spacing scales with `responsive.spacing()`

The main thing is ensuring scrollable content where needed!
