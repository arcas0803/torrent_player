import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:libtorrent_flutter/libtorrent_flutter.dart';

import '../l10n/app_localizations.dart';
import '../services/torrent_service.dart';

/// Frosted-glass card displaying live torrent and stream statistics
/// (download speed, downloaded bytes, peers, buffer percentage).
class FrostStatsCard extends StatelessWidget {
  /// Latest torrent statistics snapshot.
  final TorrentInfo? torrentInfo;

  /// Latest stream buffer information.
  final StreamInfo? streamInfo;

  const FrostStatsCard({super.key, this.torrentInfo, this.streamInfo});

  @override
  Widget build(BuildContext context) {
    if (torrentInfo == null && streamInfo == null) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (torrentInfo != null) ...[
                  StatItem(
                    icon: Icons.speed,
                    label: l.playerDownloadSpeed,
                    value:
                        '${TorrentService.formatBytes(torrentInfo!.downloadRate)}/s',
                  ),
                  StatItem(
                    icon: Icons.storage,
                    label: l.playerDownloaded,
                    value: TorrentService.formatBytes(torrentInfo!.totalDone),
                  ),
                  StatItem(
                    icon: Icons.people_outline,
                    label: l.playerConnections,
                    value: '${torrentInfo!.numPeers}',
                  ),
                ],
                if (streamInfo != null)
                  StatItem(
                    icon: Icons.downloading,
                    label: l.playerBufferedCache,
                    value: '${streamInfo!.bufferPct}%',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single labelled statistic column used inside [FrostStatsCard].
class StatItem extends StatelessWidget {
  /// Icon displayed above the value.
  final IconData icon;

  /// Descriptive label shown beneath the value.
  final String label;

  /// Formatted metric value.
  final String value;

  const StatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}

/// YouTube-style seek indicator bubble shown during multi-tap seek gestures.
class SeekIndicator extends StatelessWidget {
  /// `true` to place on the left (rewind), `false` for the right (forward).
  final bool left;

  /// Accumulated seek seconds to display.
  final int seconds;

  /// Safe-area insets for proper positioning.
  final EdgeInsets safePadding;

  const SeekIndicator({
    super.key,
    required this.left,
    required this.seconds,
    required this.safePadding,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                left ? Icons.fast_rewind : Icons.fast_forward,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '${seconds}s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vertical progress bar indicating volume (left) or brightness (right)
/// during a vertical swipe gesture.
class SwipeIndicator extends StatelessWidget {
  /// `true` for volume (left side), `false` for brightness (right side).
  final bool isVolume;

  /// Normalized 0–1 value of the current volume or brightness level.
  final double value;

  const SwipeIndicator({
    super.key,
    required this.isVolume,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned.fill(
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 56,
              height: screenHeight * 0.35,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    isVolume ? Icons.volume_up : Icons.brightness_6,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Expanding-circle ripple overlay shown on double-tap seek, similar to
/// Google Files / YouTube. Clips the circle to the tapped half of the screen.
///
/// Restart the animation by incrementing [trigger] (e.g. from PlayerProvider).
class SeekRipple extends StatefulWidget {
  /// Monotonically-increasing counter; animation restarts on each change.
  final int trigger;

  /// `true` = right half (forward), `false` = left half (rewind).
  final bool isRight;

  const SeekRipple({super.key, required this.trigger, required this.isRight});

  @override
  State<SeekRipple> createState() => _SeekRippleState();
}

class _SeekRippleState extends State<SeekRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacity = Tween<double>(
      begin: 0.35,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void didUpdateWidget(SeekRipple oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Circle diameter large enough to fill the half-screen area
    final diameter = size.height * 1.5;
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return ClipRect(
            child: Align(
              alignment: widget.isRight
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              widthFactor: 0.5,
              child: Center(
                child: Transform.scale(
                  scale: _scale.value,
                  child: Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: _opacity.value),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
