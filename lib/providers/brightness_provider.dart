import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Manages screen brightness and exposes it as reactive state.
///
/// Scoped to the player route — resets to system brightness on [dispose].
class BrightnessProvider extends ChangeNotifier {
  double _value = 0.5;

  /// Current brightness level in the 0–1 range.
  double get value => _value;

  /// Reads the current screen brightness from the system.
  Future<void> init() async {
    try {
      _value = await ScreenBrightness().current;
    } catch (_) {
      _value = 0.5;
    }
    notifyListeners();
  }

  /// Sets brightness to [v] (clamped 0–1) and applies it to the screen.
  void setValue(double v) {
    _value = v.clamp(0.0, 1.0);
    ScreenBrightness().setScreenBrightness(_value);
    notifyListeners();
  }

  @override
  void dispose() {
    ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }
}
