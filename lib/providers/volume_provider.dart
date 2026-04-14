import 'package:device_volume/device_volume.dart';
import 'package:flutter/foundation.dart';

/// Manages device audio volume and exposes it as reactive state.
///
/// Scoped to the player route — restore system UI on [dispose].
class VolumeProvider extends ChangeNotifier {
  double _value = 0.5;

  /// Timestamp of the last native [setVolume] call.
  /// Used to throttle platform-channel calls and avoid frame-skipping jank.
  DateTime _lastNativeSet = DateTime.fromMillisecondsSinceEpoch(0);

  /// Current volume level in the 0–1 range.
  double get value => _value;

  /// Reads the current system volume.
  Future<void> init() async {
    try {
      _value = DeviceVolume.getVolume() / 100.0;
    } catch (_) {
      _value = 0.5;
    }
    notifyListeners();
  }

  /// Sets volume to [v] (clamped 0–1) and applies it to the device.
  /// Native calls are throttled to at most once per 16 ms to avoid flooding
  /// the platform channel during high-frequency drag gestures.
  void setValue(double v) {
    _value = v.clamp(0.0, 1.0);
    final now = DateTime.now();
    if (now.difference(_lastNativeSet).inMilliseconds >= 16) {
      _lastNativeSet = now;
      try {
        DeviceVolume.setVolume((_value * 100).round(), showSystemUi: false);
      } catch (_) {}
    }
    notifyListeners();
  }
}
