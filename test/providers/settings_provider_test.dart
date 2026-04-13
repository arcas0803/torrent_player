import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torrent_player/providers/settings_provider.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsProvider defaults', () {
    test('cacheSeconds defaults to 10', () {
      expect(SettingsProvider().cacheSeconds, 10);
    });

    test('demuxerMaxMb defaults to 50', () {
      expect(SettingsProvider().demuxerMaxMb, 50);
    });

    test('locale defaults to es', () {
      expect(SettingsProvider().locale, 'es');
    });
  });

  group('SettingsProvider setters (no engine)', () {
    test('setCacheSeconds updates value and persists', () async {
      final provider = SettingsProvider();
      await provider.setCacheSeconds(30);
      expect(provider.cacheSeconds, 30);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('settings_cache_seconds'), 30);
    });

    test('setDemuxerMaxMb updates value and persists', () async {
      final provider = SettingsProvider();
      await provider.setDemuxerMaxMb(128);
      expect(provider.demuxerMaxMb, 128);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('settings_demuxer_max_mb'), 128);
    });

    test('setLocale updates value and persists', () async {
      final provider = SettingsProvider();
      await provider.setLocale('en');
      expect(provider.locale, 'en');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings_locale'), 'en');
    });
  });
}
