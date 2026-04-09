import 'package:libtorrent_flutter/libtorrent_flutter.dart';

/// Singleton wrapper around the [LibtorrentFlutter] engine.
///
/// Call [init] once before accessing [engine]. Provides a static utility
/// [formatBytes] for human-readable byte formatting.
class TorrentService {
  static final TorrentService instance = TorrentService._();
  TorrentService._();

  bool _initialized = false;

  /// Initialises the libtorrent engine and fetches public trackers.
  Future<void> init() async {
    if (_initialized) return;
    await LibtorrentFlutter.init(fetchTrackers: true);
    _initialized = true;
  }

  /// The underlying libtorrent engine instance.
  LibtorrentFlutter get engine => LibtorrentFlutter.instance;

  /// Formats [bytes] into a human-readable string (B / KB / MB / GB).
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
