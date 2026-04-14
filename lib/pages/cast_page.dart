import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/entities.dart';
import 'package:flutter_chrome_cast/enums.dart';
import 'package:flutter_chrome_cast/media.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/cast_provider.dart';

/// Full-screen page shown while a Chromecast session is active.
///
/// Keeps the torrent engine alive (the [PlayerPage] stays in the back-stack
/// behind this route), pauses local playback, and provides a disconnect button.
class CastPage extends StatelessWidget {
  const CastPage({super.key});

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cast = context.watch<CastProvider>();
    final client = GoogleCastRemoteMediaClient.instance;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            cast.disconnect();
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cast_connected, size: 80, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              l.castCastingTo(deviceName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Seekbar + position
            StreamBuilder<Duration>(
              stream: client.playerPositionStream,
              builder: (context, posSnap) {
                final position = posSnap.data ?? Duration.zero;
                return StreamBuilder<GoggleCastMediaStatus?>(
                  stream: client.mediaStatusStream,
                  builder: (context, statusSnap) {
                    final status = statusSnap.data;
                    final mediaInfo = status?.mediaInformation;
                    final duration = mediaInfo?.duration ?? Duration.zero;

                    final progress = duration.inSeconds > 0
                        ? (position.inSeconds / duration.inSeconds).clamp(
                            0.0,
                            1.0,
                          )
                        : 0.0;

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white30,
                            thumbColor: Colors.white,
                            overlayColor: Colors.white24,
                          ),
                          child: Slider(
                            value: progress,
                            onChanged: duration.inSeconds > 0
                                ? (v) {
                                    final target = Duration(
                                      seconds: (v * duration.inSeconds).round(),
                                    );
                                    client.seek(
                                      GoogleCastMediaSeekOption(
                                        position: target,
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Play / Pause buttons with live state
            StreamBuilder<GoggleCastMediaStatus?>(
              stream: client.mediaStatusStream,
              builder: (context, snap) {
                final status = snap.data;
                final playerState = status?.playerState;

                // Show a loading indicator while the receiver is loading/buffering
                if (playerState == null ||
                    playerState == CastMediaPlayerState.loading ||
                    playerState == CastMediaPlayerState.buffering) {
                  return Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.white54),
                      const SizedBox(height: 8),
                      Text(
                        playerState == null ? l.castConnecting : l.castLoading,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }

                // Show error if receiver failed
                if (playerState == CastMediaPlayerState.idle) {
                  return Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.castError,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  );
                }

                final isPlaying = playerState == CastMediaPlayerState.playing;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 64,
                      onPressed: isPlaying
                          ? cast.pauseRemote
                          : cast.resumeRemote,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            FilledButton.icon(
              onPressed: () {
                cast.disconnect();
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
