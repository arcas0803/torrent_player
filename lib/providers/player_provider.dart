import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:libtorrent_flutter/libtorrent_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../services/torrent_service.dart';
import 'brightness_provider.dart';
import 'volume_provider.dart';

/// Encapsulates all video-player logic, torrent monitoring, gesture handling,
/// and overlay visibility so the widget layer stays declarative.
///
/// Register via [ChangeNotifierProvider.value] inside [PlayerPage] so the
/// provider is scoped to the route lifetime.
class PlayerProvider extends ChangeNotifier {
  /// Creates a provider for the given torrent stream.
  ///
  /// [streamUrl] – local HTTP URL served by libtorrent.
  /// [torrentId] – the torrent engine handle for status updates.
  /// [cacheSeconds] and [demuxerMaxMb] configure the mpv demuxer.
  PlayerProvider({
    required this.streamUrl,
    required this.torrentId,
    required int cacheSeconds,
    required int demuxerMaxMb,
    required VolumeProvider volumeProvider,
    required BrightnessProvider brightnessProvider,
  }) : _cacheSeconds = cacheSeconds,
       _demuxerMaxMb = demuxerMaxMb,
       _volumeProvider = volumeProvider,
       _brightnessProvider = brightnessProvider {
    _init();
  }

  // ---- Public immutable fields ----

  /// The HTTP stream URL served by libtorrent.
  final String streamUrl;

  /// Engine handle used to subscribe to torrent/stream updates.
  final int torrentId;

  // ---- Private config ----

  final int _cacheSeconds;
  final int _demuxerMaxMb;

  // ---- Sub-providers ----

  final VolumeProvider _volumeProvider;
  final BrightnessProvider _brightnessProvider;

  // ---- Media kit ----

  late final Player _player;
  late final VideoController _videoController;

  /// The [VideoController] to pass to the `Video` widget.
  VideoController get videoController => _videoController;

  /// The underlying [Player] instance (for stream subscriptions in the UI).
  Player get player => _player;

  // ---- Torrent state ----

  final _engine = TorrentService.instance.engine;
  StreamSubscription<Map<int, TorrentInfo>>? _torrentSub;
  StreamSubscription<Map<int, StreamInfo>>? _streamSub;
  bool _torrentDisposed = false;

  TorrentInfo? _torrentInfo;
  StreamInfo? _streamInfo;

  /// Latest torrent statistics (download rate, peers, etc.).
  TorrentInfo? get torrentInfo => _torrentInfo;

  /// Latest stream buffer information.
  StreamInfo? get streamInfo => _streamInfo;

  // ---- Controls visibility ----

  bool _controlsVisible = true;
  Timer? _hideTimer;

  /// Whether the overlay controls are currently visible.
  bool get controlsVisible => _controlsVisible;

  /// Toggles overlay visibility and resets the auto-hide timer.
  void toggleControls() {
    _controlsVisible = !_controlsVisible;
    if (_controlsVisible) {
      _scheduleHide();
    } else {
      _hideTimer?.cancel();
    }
    notifyListeners();
  }

  /// Resets the auto-hide countdown (e.g. on user interaction).
  void resetHideTimer() => _scheduleHide();

  /// Cancels the auto-hide timer (e.g. while the user drags the seek bar).
  void cancelHideTimer() => _hideTimer?.cancel();

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (_controlsVisible) {
        _controlsVisible = false;
        notifyListeners();
      }
    });
  }

  // ---- Seek / skip ----

  /// Seeks backward by [seconds] (clamped to zero).
  void skipBackward([int seconds = 10]) {
    final pos = _player.state.position;
    final target = pos - Duration(seconds: seconds);
    _player.seek(target < Duration.zero ? Duration.zero : target);
  }

  /// Seeks forward by [seconds] (clamped to duration).
  void skipForward([int seconds = 10]) {
    final pos = _player.state.position;
    final dur = _player.state.duration;
    final target = pos + Duration(seconds: seconds);
    _player.seek(target > dur ? dur : target);
  }

  // ---- YouTube-style multi-tap seek ----

  int _tapSeekSeconds = 0;
  Timer? _tapResetTimer;
  bool _seekIndicatorLeft = false;
  bool _seekIndicatorRight = false;

  /// Accumulated seconds shown in the seek indicator.
  int get tapSeekSeconds => _tapSeekSeconds;

  /// Whether the left seek indicator bubble is visible.
  bool get showSeekIndicatorLeft => _seekIndicatorLeft;

  /// Whether the right seek indicator bubble is visible.
  bool get showSeekIndicatorRight => _seekIndicatorRight;

  /// Registers a double-tap seek gesture.
  ///
  /// [isRight] – `true` for forward (right side), `false` for rewind (left).
  void onDoubleTapSeek(bool isRight) {
    _tapSeekSeconds += 10;
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(milliseconds: 600), () {
      if (isRight) {
        skipForward(_tapSeekSeconds);
      } else {
        skipBackward(_tapSeekSeconds);
      }
      _tapSeekSeconds = 0;
      _seekIndicatorLeft = false;
      _seekIndicatorRight = false;
      notifyListeners();
    });

    _seekIndicatorLeft = !isRight;
    _seekIndicatorRight = isRight;
    notifyListeners();
  }

  // ---- Vertical swipe (volume / brightness) ----

  bool _isSwiping = false;
  bool _swipeIsVolume = false;
  double _currentSwipeValue = 0;

  /// Whether a vertical-drag gesture is in progress.
  bool get isSwiping => _isSwiping;

  /// `true` while swiping volume (left side), `false` for brightness (right).
  bool get swipeIsVolume => _swipeIsVolume;

  /// Normalized 0–1 value of the current swipe (volume or brightness).
  double get currentSwipeValue => _currentSwipeValue;

  /// Called when a vertical drag starts.
  ///
  /// [globalX] – horizontal position of the finger.
  /// [screenWidth] – total screen width to determine left/right half.
  void onVerticalDragStart(double globalX, double screenWidth) {
    final isLeft = globalX < screenWidth / 2;
    _isSwiping = true;
    _swipeIsVolume = isLeft;
    _currentSwipeValue = isLeft
        ? _volumeProvider.value
        : _brightnessProvider.value;
    notifyListeners();
  }

  /// Called on each vertical drag update to adjust volume or brightness.
  ///
  /// [deltaY] – vertical movement delta (negative = upward).
  /// [screenHeight] – total screen height for sensitivity calculation.
  void onVerticalDragUpdate(double deltaY, double screenHeight) {
    if (!_isSwiping) return;
    final delta = -deltaY / (screenHeight * 0.5);
    _currentSwipeValue = (_currentSwipeValue + delta).clamp(0.0, 1.0);

    if (_swipeIsVolume) {
      _volumeProvider.setValue(_currentSwipeValue);
    } else {
      _brightnessProvider.setValue(_currentSwipeValue);
    }
    notifyListeners();
  }

  /// Ends the current vertical drag gesture.
  void onVerticalDragEnd() {
    _isSwiping = false;
    notifyListeners();
  }

  // ---- Track selection ----

  /// Available audio and subtitle tracks (updated reactively).
  Tracks get tracks => _player.state.tracks;

  /// Currently selected tracks.
  Track get currentTrack => _player.state.track;

  /// Selects the given [track] as the active audio track.
  void setAudioTrack(AudioTrack track) => _player.setAudioTrack(track);

  /// Selects the given [track] as the active subtitle track.
  void setSubtitleTrack(SubtitleTrack track) => _player.setSubtitleTrack(track);

  // ---- Helpers ----

  /// Formats a [Duration] as `H:MM:SS` or `MM:SS`.
  String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  // ---- Lifecycle ----

  Future<void> _init() async {
    _player = Player();
    _videoController = VideoController(_player);

    unawaited(_volumeProvider.init());
    unawaited(_brightnessProvider.init());
    await _configureMpv();
    await _player.open(Media(streamUrl));

    _torrentSub = _engine.torrentUpdates.listen((torrents) {
      final info = torrents[torrentId];
      if (info != null) {
        _torrentInfo = info;
        notifyListeners();
      }
    });

    _streamSub = _engine.streamUpdates.listen((streams) {
      for (final s in streams.values) {
        if (s.url == streamUrl) {
          _streamInfo = s;
          notifyListeners();
          break;
        }
      }
    });

    _scheduleHide();
  }

  Future<void> _configureMpv() async {
    if (_player.platform is NativePlayer) {
      final native = _player.platform as NativePlayer;
      await native.setProperty('cache', 'yes');
      await native.setProperty('cache-secs', '$_cacheSeconds');
      await native.setProperty('demuxer-max-bytes', '${_demuxerMaxMb}MiB');
      await native.setProperty('demuxer-readahead-secs', '5');
      await native.setProperty('network-timeout', '30');
      await native.setProperty('hwdec', 'no');
    }
  }

  /// Disposes the underlying torrent resources.
  ///
  /// Safe to call multiple times; only the first invocation takes effect.
  void cleanupTorrent() {
    if (_torrentDisposed) return;
    _torrentDisposed = true;
    try {
      _engine.disposeTorrent(torrentId);
    } catch (_) {
      // The torrent may have already been removed or never existed (e.g. in
      // integration tests with a dummy torrentId). Swallow the error so that
      // dispose() can finish cleanly.
    }
  }

  @override
  void dispose() {
    _torrentSub?.cancel();
    _streamSub?.cancel();
    _hideTimer?.cancel();
    _tapResetTimer?.cancel();
    _player.dispose();
    cleanupTorrent();
    super.dispose();
  }
}
