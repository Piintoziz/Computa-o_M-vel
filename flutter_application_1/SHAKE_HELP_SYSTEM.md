# Shake-to-Help System

This document explains the shake-to-help system implemented in the Flutter application, similar to Instagram's help feature.

## Overview

The shake-to-help system allows users to shake their phone on any page to trigger a help dialog where they can describe their problem and request assistance.

## Components

### 1. ShakeService (`lib/services/shake_service.dart`)
- Singleton service that detects phone shakes using the accelerometer
- Uses a buffer system to analyze acceleration data
- Prevents multiple triggers in a short time window
- Configurable sensitivity and time window

### 2. HelpDialog (`lib/widgets/help_dialog.dart`)
- Beautiful dialog with green theme using `Theme.of(context).colorScheme.primary`
- Text field for users to describe their problem
- Submit button with loading state
- Success/error feedback via SnackBar

### 3. ShakeDetectorMixin (`lib/widgets/shake_detector_mixin.dart`)
- Mixin that can be added to any StatefulWidget
- Automatically starts/shuts down shake detection
- Shows the help dialog when shake is detected

## How to Use

### Adding Shake Detection to a Page

Simply add the `ShakeDetectorMixin` to any StatefulWidget:

```dart
import '../widgets/shake_detector_mixin.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with ShakeDetectorMixin {
  // Your page implementation
}
```

### Converting StatelessWidget to StatefulWidget

If your page is currently a StatelessWidget, convert it to StatefulWidget:

```dart
// Before
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Your implementation
  }
}

// After
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with ShakeDetectorMixin {
  @override
  Widget build(BuildContext context) {
    // Your implementation
  }
}
```

## Configuration

### Shake Sensitivity
You can adjust the shake detection sensitivity in `ShakeService`:

```dart
final double _shakeThreshold = 15.0; // Lower = more sensitive
final Duration _shakeTimeWindow = const Duration(milliseconds: 500); // Cooldown period
```

### Help Dialog Customization
The help dialog can be customized in `HelpDialog`:
- Colors and styling
- Text content
- Form validation
- Submission logic

## Implementation Status

The shake detection system has been added to:
- ✅ Welcome Page
- ✅ Home Navigation (affects all main pages)
- ✅ Menu Principal
- ✅ Login Page

## Dependencies

The system requires:
- `sensors_plus: ^4.0.2` - For accelerometer access

## Testing

To test the shake detection:
1. Run the app on a physical device (not emulator)
2. Navigate to any page with shake detection enabled
3. Shake the phone moderately
4. The help dialog should appear

## Future Enhancements

Potential improvements:
- Add vibration feedback when shake is detected
- Customize help categories
- Integrate with backend support system
- Add analytics for help requests
- Implement help request history

## Troubleshooting

- **Shake not detected**: Check if running on physical device
- **Too sensitive/not sensitive enough**: Adjust `_shakeThreshold` in ShakeService
- **Multiple dialogs**: Check `_shakeTimeWindow` configuration
- **Permission issues**: Ensure app has sensor permissions 