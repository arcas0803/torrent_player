import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists a bounded list of recently used magnet links.
///
/// The history is capped at [_maxItems] entries and stored via
/// [SharedPreferences]. Call [load] once at startup.
class MagnetHistoryProvider extends ChangeNotifier {
  static const _key = 'magnet_history';
  static const _maxItems = 20;

  List<String> _history = [];

  /// The most recent magnet links, newest first.
  List<String> get history => _history;

  /// Loads the persisted history from disk.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _history = prefs.getStringList(_key) ?? [];
    notifyListeners();
  }

  /// Adds a magnet to the front of the history, deduplicating if present.
  Future<void> add(String magnet) async {
    final prefs = await SharedPreferences.getInstance();
    _history.remove(magnet);
    _history.insert(0, magnet);
    if (_history.length > _maxItems) _history.removeLast();
    await prefs.setStringList(_key, _history);
    notifyListeners();
  }

  /// Removes a single magnet from the history.
  Future<void> remove(String magnet) async {
    final prefs = await SharedPreferences.getInstance();
    _history.remove(magnet);
    await prefs.setStringList(_key, _history);
    notifyListeners();
  }

  /// Clears the entire history.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    _history = [];
    await prefs.remove(_key);
    notifyListeners();
  }
}
