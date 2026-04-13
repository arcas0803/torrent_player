import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/cast_provider.dart';

/// Full-screen page shown while a Chromecast session is active.
///
/// Keeps the torrent engine alive (the [PlayerPage] stays in the back-stack
/// behind this route), pauses local playback, and provides a disconnect button.
class CastPage extends StatelessWidget {
  const CastPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cast = context.watch<CastProvider>();
    final deviceName = cast.castDeviceName ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          l.castCastingTo(deviceName),
          style: const TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cast_connected, size: 96, color: Colors.white70),
            const SizedBox(height: 24),
            Text(
              l.castCastingTo(deviceName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 56,
                  onPressed: cast.pauseRemote,
                  icon: const Icon(
                    Icons.pause_circle_outline,
                    color: Colors.white70,
                  ),
                  tooltip: 'Pause',
                ),
                const SizedBox(width: 16),
                IconButton(
                  iconSize: 56,
                  onPressed: cast.resumeRemote,
                  icon: const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white70,
                  ),
                  tooltip: 'Play',
                ),
              ],
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () {
                cast.disconnect();
                // Pop back to player (which stays in the back-stack)
                Navigator.pop(context);
              },
              icon: const Icon(Icons.cast),
              label: Text(l.castDisconnect),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
