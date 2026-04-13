import 'package:device_volume/device_volume.dart';
import 'package:flutter/foundation.dart';

/// Manages device audio volume and exposes it as reactive state.
///
/// Scoped to the player route — restore system UI on [dispose].
class VolumeProvider extends ChangeNotifier {
  double _value = 0.5;

  /// Current volume level in the 0–1 range.
  double get value => _value;

  /// Reads the current system volume.
  Future<void> init() async {
    try {
      _value = DeviceVolume.getVolume() / 100.0;
    } catch (_) {}
    notifyListeners();
  }

  /// Sets volume to [v] (clamped 0–1) and applies it to the device.
  void setValue(double v) {
    _value = v.clamp(0.0, 1.0);
    DeviceVolume.setVolume((_value * 100).round(), showSystemUi: false);
    notifyListeners();
  }
}
