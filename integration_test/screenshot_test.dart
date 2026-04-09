import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:torrent_player/main.dart' as app;
import 'package:torrent_player/pages/player_page.dart';
import 'package:torrent_player/providers/brightness_provider.dart';
import 'package:torrent_player/providers/cast_provider.dart';
import 'package:torrent_player/providers/player_provider.dart';
import 'package:torrent_player/providers/settings_provider.dart';
import 'package:torrent_player/providers/volume_provider.dart';

/// Public test MP4 — small, no torrent engine needed.
const _testStreamUrl =
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Ensure the screenshots directory exists on device storage.
    final dir = Directory('/sdcard/Pictures/screenshots');
    if (!dir.existsSync()) dir.createSync(recursive: true);
  });

  /// Saves a screenshot to /sdcard/Pictures/screenshots/{name}.png.
  Future<void> screenshot(String name) async {
    final bytes = await binding.takeScreenshot(name);
    final file = File('/sdcard/Pictures/screenshots/$name.png');
    await file.writeAsBytes(bytes);
  }

  testWidgets('01 — Home screen', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await screenshot('01_home_phone');
  });

  testWidgets('02 — Settings screen', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Tap the settings icon in the AppBar.
    final settingsBtn = find.byIcon(Icons.settings);
    await tester.tap(settingsBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await screenshot('02_settings_phone');
  });

  testWidgets('03 — Player screen with controls visible', (tester) async {
    // Build a minimal MultiProvider tree that mirrors PlayerPage's expectations
    // without the torrent engine (uses a public MP4 URL instead).
    final settingsProvider = SettingsProvider();
    await settingsProvider.load();
    final volumeProvider = VolumeProvider();
    final brightnessProvider = BrightnessProvider();
    final playerProvider = PlayerProvider(
      streamUrl: _testStreamUrl,
      torrentId: 0,
      cacheSeconds: settingsProvider.cacheSeconds,
      demuxerMaxMb: settingsProvider.demuxerMaxMb,
      volumeProvider: volumeProvider,
      brightnessProvider: brightnessProvider,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
          ),
          ChangeNotifierProvider<CastProvider>(create: (_) => CastProvider()),
          ChangeNotifierProvider<VolumeProvider>.value(value: volumeProvider),
          ChangeNotifierProvider<BrightnessProvider>.value(
            value: brightnessProvider,
          ),
          ChangeNotifierProvider<PlayerProvider>.value(value: playerProvider),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: _TestPlayerBody(),
        ),
      ),
    );

    // Wait for the player to initialise and buffer a few frames.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Ensure controls are visible by tapping the gesture layer.
    await tester.tapAt(const Offset(200, 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    await screenshot('03_player_phone');

    // Clean up
    playerProvider.dispose();
    volumeProvider.dispose();
    brightnessProvider.dispose();
  });
}

/// Thin wrapper that renders only the [_PlayerBody] without orientation
/// locks (which would fail on the emulator during tests).
class _TestPlayerBody extends StatelessWidget {
  const _TestPlayerBody();

  @override
  Widget build(BuildContext context) {
    // Import the private _PlayerBody is not possible; instead we replicate
    // the Scaffold+Stack structure via PlayerPage's public surface by pushing
    // the route programmatically so that PlayerPage handles its own build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayerPage(
            args: const PlayerArgs(
              streamUrl: _testStreamUrl,
              torrentId: 0,
            ),
          ),
        ),
      );
    });
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
