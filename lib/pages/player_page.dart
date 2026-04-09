import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/brightness_provider.dart';
import '../providers/cast_provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/volume_provider.dart';
import '../widgets/cast_device_dialog.dart';
import '../widgets/player_overlay_widgets.dart';

/// Arguments required to navigate to [PlayerPage].
class PlayerArgs {
  /// Local HTTP URL served by libtorrent.
  final String streamUrl;

  /// Engine handle for the active torrent.
  final int torrentId;

  const PlayerArgs({required this.streamUrl, required this.torrentId});
}

/// Full-screen video player page.
///
/// Handles orientation lock and system-UI visibility. Creates [VolumeProvider],
/// [BrightnessProvider], and [PlayerProvider] scoped to this route and exposes
/// them via [MultiProvider] so the full sub-tree can consume them reactively.
class PlayerPage extends StatefulWidget {
  /// Navigation arguments containing stream URL and torrent id.
  final PlayerArgs args;

  const PlayerPage({super.key, required this.args});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with WidgetsBindingObserver {
  late final VolumeProvider _volumeProvider;
  late final BrightnessProvider _brightnessProvider;
  late final PlayerProvider _playerProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _volumeProvider = VolumeProvider();
    _brightnessProvider = BrightnessProvider();

    final settings = context.read<SettingsProvider>();
    _playerProvider = PlayerProvider(
      streamUrl: widget.args.streamUrl,
      torrentId: widget.args.torrentId,
      cacheSeconds: settings.cacheSeconds,
      demuxerMaxMb: settings.demuxerMaxMb,
      volumeProvider: _volumeProvider,
      brightnessProvider: _brightnessProvider,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _playerProvider.cleanupTorrent();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playerProvider.dispose();
    _volumeProvider.dispose();
    _brightnessProvider.dispose();
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<VolumeProvider>.value(value: _volumeProvider),
        ChangeNotifierProvider<BrightnessProvider>.value(value: _brightnessProvider),
        ChangeNotifierProvider<PlayerProvider>.value(value: _playerProvider),
      ],
      child: const _PlayerBody(),
    );
  }
}

// ---------------------------------------------------------------------------
// Player body – pure presentation widget
// ---------------------------------------------------------------------------

/// Thin presentational widget that reads all playback state from
/// [PlayerProvider], [VolumeProvider], and [BrightnessProvider].
/// Contains no business logic — every user action is delegated to a provider.
class _PlayerBody extends StatelessWidget {
  const _PlayerBody();

  // ---- Track selection sheets (require BuildContext) ----

  void _showAudioTrackPicker(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.read<PlayerProvider>();
    final tracks = prov.tracks.audio;
    final current = prov.currentTrack.audio;
    _showTrackSheet<AudioTrack>(
      context: context,
      title: l.playerAudioTrack,
      items: tracks,
      currentId: current.id,
      labelBuilder: (t) {
        if (t.id == 'auto') return l.playerTrackAuto;
        if (t.id == 'no') return l.playerTrackOff;
        final parts = <String>[];
        if (t.title != null && t.title!.isNotEmpty) parts.add(t.title!);
        if (t.language != null && t.language!.isNotEmpty) {
          parts.add(t.language!);
        }
        return parts.isNotEmpty
            ? parts.join(' - ')
            : l.playerTrackLabel(tracks.indexOf(t));
      },
      onSelected: (t) => prov.setAudioTrack(t),
    );
  }

  void _showSubtitleTrackPicker(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.read<PlayerProvider>();
    final tracks = prov.tracks.subtitle;
    final current = prov.currentTrack.subtitle;
    _showTrackSheet<SubtitleTrack>(
      context: context,
      title: l.playerSubtitleTrack,
      items: tracks,
      currentId: current.id,
      labelBuilder: (t) {
        if (t.id == 'auto') return l.playerTrackAuto;
        if (t.id == 'no') return l.playerTrackOff;
        final parts = <String>[];
        if (t.title != null && t.title!.isNotEmpty) parts.add(t.title!);
        if (t.language != null && t.language!.isNotEmpty) {
          parts.add(t.language!);
        }
        return parts.isNotEmpty
            ? parts.join(' - ')
            : l.playerTrackLabel(tracks.indexOf(t));
      },
      onSelected: (t) => prov.setSubtitleTrack(t),
    );
  }

  void _showTrackSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String currentId,
    required String Function(T) labelBuilder,
    required void Function(T) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...items.map((t) {
              final id = (t as dynamic).id as String;
              final selected = id == currentId;
              return ListTile(
                leading: selected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : const SizedBox(width: 24),
                title: Text(
                  labelBuilder(t),
                  style: TextStyle(
                    color: selected ? Colors.blue : Colors.white,
                  ),
                ),
                onTap: () {
                  onSelected(t);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Shows the Chromecast device discovery dialog.
  void _showCastDialog(BuildContext context) {
    final url = context.read<PlayerProvider>().streamUrl;
    showDialog<void>(
      context: context,
      builder: (_) => CastDeviceDialog(streamUrl: url),
    );
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PlayerProvider>();
    final cast = context.watch<CastProvider>();
    final size = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video surface
          Positioned.fill(
            child: Video(
              controller: prov.videoController,
              controls: NoVideoControls,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),

          // Gesture layer
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: prov.toggleControls,
              onDoubleTapDown: (details) {
                final isRight = details.globalPosition.dx > size.width / 2;
                prov.onDoubleTapSeek(isRight);
              },
              onDoubleTap: () {},
              onVerticalDragStart: (d) =>
                  prov.onVerticalDragStart(d.globalPosition.dx, size.width),
              onVerticalDragUpdate: (d) =>
                  prov.onVerticalDragUpdate(d.delta.dy, size.height),
              onVerticalDragEnd: (_) => prov.onVerticalDragEnd(),
            ),
          ),

          // Seek indicators (YouTube style)
          if (prov.showSeekIndicatorLeft)
            SeekIndicator(
              left: true,
              seconds: prov.tapSeekSeconds,
              safePadding: safePadding,
            ),
          if (prov.showSeekIndicatorRight)
            SeekIndicator(
              left: false,
              seconds: prov.tapSeekSeconds,
              safePadding: safePadding,
            ),

          // Volume / brightness swipe indicator
          if (prov.isSwiping)
            SwipeIndicator(
              isVolume: prov.swipeIsVolume,
              value: prov.currentSwipeValue,
            ),

          // Buffering spinner
          StreamBuilder<bool>(
            stream: prov.player.stream.buffering,
            builder: (ctx, snap) {
              if (!(snap.data ?? true)) return const SizedBox.shrink();
              return const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            },
          ),

          // Controls overlay
          AnimatedOpacity(
            opacity: prov.controlsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !prov.controlsVisible,
              child: Container(
                color: Colors.black38,
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(context, safePadding, prov, cast),
                      const Spacer(),
                      _buildCenterControls(prov),
                      const Spacer(),
                      _buildSeekBar(context, prov),
                      const SizedBox(height: 8),
                      FrostStatsCard(
                        torrentInfo: prov.torrentInfo,
                        streamInfo: prov.streamInfo,
                      ),
                      SizedBox(height: safePadding.bottom + 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Private sub-builders ----

  Widget _buildTopBar(
    BuildContext context,
    EdgeInsets safePadding,
    PlayerProvider prov,
    CastProvider cast,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: safePadding.left + 8,
        right: safePadding.right + 8,
        top: 4,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
          StreamBuilder<Tracks>(
            stream: prov.player.stream.tracks,
            builder: (ctx, snap) {
              final tracks = snap.data ?? prov.tracks;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tracks.audio.length > 1)
                    IconButton(
                      onPressed: () => _showAudioTrackPicker(context),
                      icon: const Icon(Icons.audiotrack, color: Colors.white),
                      tooltip: AppLocalizations.of(context)!.playerAudioTrack,
                    ),
                  if (tracks.subtitle.length > 1)
                    IconButton(
                      onPressed: () => _showSubtitleTrackPicker(context),
                      icon: const Icon(Icons.subtitles, color: Colors.white),
                      tooltip:
                          AppLocalizations.of(context)!.playerSubtitleTrack,
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () => _showCastDialog(context),
            icon: Icon(
              cast.isCasting ? Icons.cast_connected : Icons.cast,
              color: cast.isCasting
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls(PlayerProvider prov) {
    return StreamBuilder<bool>(
      stream: prov.player.stream.playing,
      builder: (ctx, snap) {
        final playing = snap.data ?? false;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: prov.skipBackward,
              iconSize: 40,
              icon: const Icon(Icons.replay_10, color: Colors.white),
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: prov.player.playOrPause,
              iconSize: 56,
              icon: Icon(
                playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: prov.skipForward,
              iconSize: 40,
              icon: const Icon(Icons.forward_10, color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeekBar(BuildContext context, PlayerProvider prov) {
    final primary = Theme.of(context).colorScheme.primary;
    return StreamBuilder<Duration>(
      stream: prov.player.stream.position,
      builder: (ctx, posSnap) {
        return StreamBuilder<Duration>(
          stream: prov.player.stream.duration,
          builder: (ctx, durSnap) {
            final position = posSnap.data ?? Duration.zero;
            final duration = durSnap.data ?? const Duration(seconds: 1);
            final max = duration.inMilliseconds
                .toDouble()
                .clamp(1.0, double.infinity);
            final value =
                position.inMilliseconds.toDouble().clamp(0.0, max);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    prov.formatDuration(position),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                        activeTrackColor: primary,
                        inactiveTrackColor: primary.withValues(alpha: 0.25),
                        thumbColor: primary,
                        overlayColor: primary.withValues(alpha: 0.12),
                      ),
                      child: Slider(
                        value: value,
                        max: max,
                        onChanged: (v) => prov.player.seek(
                          Duration(milliseconds: v.round()),
                        ),
                        onChangeStart: (_) => prov.cancelHideTimer(),
                        onChangeEnd: (_) => prov.resetHideTimer(),
                      ),
                    ),
                  ),
                  Text(
                    prov.formatDuration(duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
