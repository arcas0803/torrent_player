import 'package:flutter/foundation.dart';
import 'package:volume_controller/volume_controller.dart';

/// Manages device audio volume and exposes it as reactive state.
///
/// Scoped to the player route — restore system UI on [dispose].
class VolumeProvider extends ChangeNotifier {
  double _value = 0.5;

  /// Current volume level in the 0–1 range.
  double get value => _value;

  /// Reads the current system volume and hides the native volume UI overlay.
  Future<void> init() async {
    try {
      _value = await VolumeController().getVolume();
      VolumeController().showSystemUI = false;
    } catch (_) {}
    notifyListeners();
  }

  /// Sets volume to [v] (clamped 0–1) and applies it to the device.
  void setValue(double v) {
    _value = v.clamp(0.0, 1.0);
    VolumeController().setVolume(_value);
    notifyListeners();
  }

  @override
  void dispose() {
    VolumeController().showSystemUI = true;
    super.dispose();
  }
}
