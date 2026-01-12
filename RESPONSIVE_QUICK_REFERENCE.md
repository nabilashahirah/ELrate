# Responsive Design Quick Reference

## Import
```dart
import '../utils/responsive.dart';
```

## Usage
```dart
final responsive = context.responsive;
```

## Common Operations

### Screen Dimensions
```dart
responsive.width          // Full width in pixels
responsive.height         // Full height in pixels
responsive.wp(50)         // 50% of screen width
responsive.hp(30)         // 30% of screen height
```

### Device Checks
```dart
responsive.isMobile       // < 600px width
responsive.isTablet       // 600-1024px width
responsive.isPortrait     // Portrait orientation
responsive.isLandscape    // Landscape orientation
```

### Responsive Sizing
```dart
responsive.sp(16)         // Font size (auto-scales: 14px→16px→18px→21px)
responsive.spacing(20)    // Spacing (auto-scales: 16px→20px→26px→30px)
responsive.iconSize(24)   // Icon size (auto-scales: 20px→24px→29px→34px)
```

### Predefined Sizes
```dart
responsive.logoSize       // 70→100→130→150px
responsive.avatarSize     // 40→50→65→80px
responsive.buttonHeight   // 48→54→60→66px
responsive.cardWidth      // 42%→45%→30%→25% of width
responsive.cardHeight     // 22%→28% of height
```

### Padding/Margin
```dart
responsive.horizontalPadding    // Auto horizontal padding
responsive.verticalPadding      // Auto vertical padding
responsive.allPadding          // Auto all-around padding
```

### Layouts
```dart
responsive.gridColumns          // 1-4 columns based on device
responsive.centerContent(child) // Center on tablets/desktop
```

## Examples

### Container
```dart
Container(
  width: responsive.cardWidth,
  height: responsive.cardHeight,
  padding: EdgeInsets.all(responsive.spacing(16)),
)
```

### Text
```dart
Text(
  "Hello",
  style: TextStyle(fontSize: responsive.sp(18)),
)
```

### Icon
```dart
Icon(Icons.star, size: responsive.iconSize(20))
```

### SizedBox
```dart
SizedBox(
  width: responsive.spacing(16),
  height: responsive.spacing(20),
)
```

### Button
```dart
SizedBox(
  height: responsive.buttonHeight,
  child: ElevatedButton(...),
)
```

### Conditional Layout
```dart
if (responsive.isMobile)
  MobileLayout()
else if (responsive.isTablet)
  TabletLayout()
else
  DesktopLayout()
```

## Device Breakpoints
- **Small Mobile**: < 360px
- **Large Mobile**: 360-599px
- **Small Tablet**: 600-767px
- **Large Tablet**: 768-1023px
- **Desktop**: ≥ 1024px

## Testing
```bash
# Analyze
flutter analyze

# Build and test
flutter build apk --debug
flutter install

# Run on emulator
flutter run
```
