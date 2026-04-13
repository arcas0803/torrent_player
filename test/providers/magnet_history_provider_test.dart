import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torrent_player/providers/magnet_history_provider.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MagnetHistoryProvider', () {
    test('starts with empty history', () {
      final provider = MagnetHistoryProvider();
      expect(provider.history, isEmpty);
    });

    test('load returns empty list when nothing persisted', () async {
      final provider = MagnetHistoryProvider();
      await provider.load();
      expect(provider.history, isEmpty);
    });

    test('add inserts magnet at front', () async {
      final provider = MagnetHistoryProvider();
      await provider.add('magnet:?xt=urn:btih:AAA');
      expect(provider.history.first, 'magnet:?xt=urn:btih:AAA');
    });

    test('add deduplicates: existing entry moves to front', () async {
      final provider = MagnetHistoryProvider();
      await provider.add('magnet:?xt=urn:btih:AAA');
      await provider.add('magnet:?xt=urn:btih:BBB');
      await provider.add('magnet:?xt=urn:btih:AAA');
      expect(provider.history.first, 'magnet:?xt=urn:btih:AAA');
      expect(provider.history.length, 2);
    });

    test('remove deletes the entry', () async {
      final provider = MagnetHistoryProvider();
      await provider.add('magnet:?xt=urn:btih:AAA');
      await provider.remove('magnet:?xt=urn:btih:AAA');
      expect(provider.history, isEmpty);
    });

    test('clearAll empties the list', () async {
      final provider = MagnetHistoryProvider();
      await provider.add('magnet:?xt=urn:btih:AAA');
      await provider.add('magnet:?xt=urn:btih:BBB');
      await provider.clearAll();
      expect(provider.history, isEmpty);
    });

    test('history persists across provider instances', () async {
      final first = MagnetHistoryProvider();
      await first.add('magnet:?xt=urn:btih:AAA');

      final second = MagnetHistoryProvider();
      await second.load();
      expect(second.history, ['magnet:?xt=urn:btih:AAA']);
    });
  });
}
