import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:torrent_player/main.dart' as app;
import 'package:torrent_player/pages/player_page.dart';

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
    expect(settingsBtn, findsOneWidget);
    await tester.tap(settingsBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await screenshot('02_settings_phone');
  });

  testWidgets('03 — Player screen with controls visible', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Navigate to the player route using the app's own navigator so every
    // ancestor provider (SettingsProvider, CastProvider…) is available.
    final navState = tester.state<NavigatorState>(find.byType(Navigator).last);
    navState.pushNamed(
      '/player',
      arguments: const PlayerArgs(
        streamUrl: _testStreamUrl,
        torrentId: -1, // no real torrent — only the HTTP stream matters
      ),
    );

    // Allow time for the player to initialise, buffer and render.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tap the centre of the screen to make controls visible.
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(size.width / 2, size.height / 2));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    await screenshot('03_player_phone');
  });
}
