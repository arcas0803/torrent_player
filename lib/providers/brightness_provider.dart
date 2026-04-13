import 'package:device_screen_brightness/device_screen_brightness.dart';
import 'package:flutter/foundation.dart';

/// Manages screen brightness and exposes it as reactive state.
///
/// Scoped to the player route — resets to original brightness on [dispose].
class BrightnessProvider extends ChangeNotifier {
  double _value = 0.5;
  int _originalBrightness = 50;

  /// Current brightness level in the 0–1 range.
  double get value => _value;

  /// Reads the current screen brightness from the system.
  Future<void> init() async {
    try {
      _originalBrightness = DeviceScreenBrightness.getBrightness(
        mode: BrightnessMode.app,
      );
      _value = _originalBrightness / 100.0;
    } catch (_) {
      _value = 0.5;
    }
    notifyListeners();
  }

  /// Sets brightness to [v] (clamped 0–1) and applies it to the screen.
  void setValue(double v) {
    _value = v.clamp(0.0, 1.0);
    DeviceScreenBrightness.setBrightness(
      (_value * 100).round(),
      mode: BrightnessMode.app,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    try {
      DeviceScreenBrightness.setBrightness(
        _originalBrightness,
        mode: BrightnessMode.app,
      );
    } catch (_) {}
    super.dispose();
  }
}
