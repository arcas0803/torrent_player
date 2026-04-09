import 'package:shared_preferences/shared_preferences.dart';

/// Legacy static helper for magnet-link history persistence.
///
/// Prefer [MagnetHistoryProvider] for new code; this class is retained for
/// backward compatibility.
class MagnetHistory {
  static const _key = 'magnet_history';
  static const _maxItems = 20;

  /// Loads the saved history list from disk.
  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Adds a magnet link at the front of the list, deduplicating if present.
  static Future<void> add(String magnet) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(magnet);
    list.insert(0, magnet);
    if (list.length > _maxItems) list.removeLast();
    await prefs.setStringList(_key, list);
  }

  /// Removes a magnet link from the history.
  static Future<void> remove(String magnet) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(magnet);
    await prefs.setStringList(_key, list);
  }
}
