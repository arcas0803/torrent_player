import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/torrent_service.dart';

/// Persists and exposes user-configurable settings (speed limits, cache,
/// demuxer buffer, locale) using [SharedPreferences].
///
/// Call [load] once at startup to hydrate from disk. Each setter writes
/// through to shared preferences and notifies listeners immediately.
class SettingsProvider extends ChangeNotifier {
  static const _keyDownload = 'settings_download_limit';
  static const _keyUpload = 'settings_upload_limit';
  static const _keyCacheSec = 'settings_cache_seconds';
  static const _keyDemuxMb = 'settings_demuxer_max_mb';
  static const _keyLocale = 'settings_locale';

  int _downloadLimitBytes = 0;
  int _uploadLimitBytes = 0;
  int _cacheSeconds = 10;
  int _demuxerMaxMb = 50;
  String _locale = 'es';

  /// Maximum download speed in bytes/s (0 = unlimited).
  int get downloadLimitBytes => _downloadLimitBytes;

  /// Maximum upload speed in bytes/s (0 = unlimited).
  int get uploadLimitBytes => _uploadLimitBytes;

  /// Seconds of cache to maintain for mpv's demuxer.
  int get cacheSeconds => _cacheSeconds;

  /// Maximum demuxer buffer in megabytes.
  int get demuxerMaxMb => _demuxerMaxMb;

  /// BCP-47 locale tag ('en' or 'es').
  String get locale => _locale;

  /// Loads persisted settings from disk and applies speed limits to the engine.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _downloadLimitBytes = prefs.getInt(_keyDownload) ?? 0;
    _uploadLimitBytes = prefs.getInt(_keyUpload) ?? 0;
    _cacheSeconds = prefs.getInt(_keyCacheSec) ?? 10;
    _demuxerMaxMb = prefs.getInt(_keyDemuxMb) ?? 50;
    _locale = prefs.getString(_keyLocale) ?? 'es';

    // Apply saved speed limits to the engine immediately on load
    final engine = TorrentService.instance.engine;
    engine.setDownloadLimit(_downloadLimitBytes);
    engine.setUploadLimit(_uploadLimitBytes);

    notifyListeners();
  }

  /// Updates the download speed limit and persists the new value.
  Future<void> setDownloadLimitBytes(int value) async {
    _downloadLimitBytes = value;
    TorrentService.instance.engine.setDownloadLimit(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDownload, value);
    notifyListeners();
  }

  /// Updates the upload speed limit and persists the new value.
  Future<void> setUploadLimitBytes(int value) async {
    _uploadLimitBytes = value;
    TorrentService.instance.engine.setUploadLimit(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUpload, value);
    notifyListeners();
  }

  /// Updates the cache-seconds value and persists the new value.
  Future<void> setCacheSeconds(int value) async {
    _cacheSeconds = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCacheSec, value);
    notifyListeners();
  }

  /// Updates the demuxer max-MB value and persists the new value.
  Future<void> setDemuxerMaxMb(int value) async {
    _demuxerMaxMb = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDemuxMb, value);
    notifyListeners();
  }

  /// Switches the application locale and persists the new value.
  Future<void> setLocale(String locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale);
    notifyListeners();
  }
}
