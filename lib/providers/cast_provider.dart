import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/discovery.dart';
import 'package:flutter_chrome_cast/entities.dart';
import 'package:flutter_chrome_cast/media.dart';
import 'package:flutter_chrome_cast/models.dart';
import 'package:flutter_chrome_cast/session.dart';

import '../services/cast_service.dart';

/// Possible states for the Chromecast discovery and connection flow.
enum CastDiscoveryState {
  /// No discovery in progress.
  idle,

  /// Actively scanning the network for Cast devices.
  searching,

  /// Search finished without finding any devices.
  noDevices,
}

/// Manages Chromecast device discovery, session lifecycle, and media loading.
///
/// Exposes reactive state so the UI can reflect discovery progress, available
/// devices, and whether a Cast session is active.
class CastProvider extends ChangeNotifier {
  CastDiscoveryState _discoveryState = CastDiscoveryState.idle;
  bool _isCasting = false;
  String? _castDeviceName;
  Timer? _searchTimer;

  /// Current discovery state.
  CastDiscoveryState get discoveryState => _discoveryState;

  /// Whether a Cast session is currently active and streaming media.
  bool get isCasting => _isCasting;

  /// Friendly name of the device currently being cast to.
  String? get castDeviceName => _castDeviceName;

  /// Live stream of discovered [GoogleCastDevice] instances on the network.
  Stream<List<GoogleCastDevice>> get devicesStream =>
      GoogleCastDiscoveryManager.instance.devicesStream;

  /// Snapshot of currently known devices.
  List<GoogleCastDevice> get devices =>
      GoogleCastDiscoveryManager.instance.devices;

  /// Starts network discovery for Cast devices.
  ///
  /// After [timeout] elapses without finding devices the state transitions
  /// to [CastDiscoveryState.noDevices].
  void startDiscovery({Duration timeout = const Duration(seconds: 5)}) {
    _searchTimer?.cancel();
    _discoveryState = CastDiscoveryState.searching;
    notifyListeners();

    GoogleCastDiscoveryManager.instance.startDiscovery();

    _searchTimer = Timer(timeout, () {
      if (_discoveryState == CastDiscoveryState.searching) {
        _discoveryState = CastDiscoveryState.noDevices;
        notifyListeners();
      }
    });
  }

  /// Stops the active discovery scan, if any.
  void stopDiscovery() {
    _searchTimer?.cancel();
    GoogleCastDiscoveryManager.instance.stopDiscovery();
    _discoveryState = CastDiscoveryState.idle;
    notifyListeners();
  }

  /// Connects to [device] and begins casting the media at [streamUrl].
  ///
  /// The [streamUrl] is a local libtorrent HTTP address which gets rewritten
  /// to the device LAN IP via [CastService.buildCastUrl] so the Chromecast
  /// can reach it.
  Future<void> connectAndCast(GoogleCastDevice device, String streamUrl) async {
    stopDiscovery();
    _isCasting = true;
    _castDeviceName = device.friendlyName;
    notifyListeners();

    try {
      await GoogleCastSessionManager.instance.startSessionWithDevice(device);
      final castUrl = await CastService.buildCastUrl(streamUrl);
      if (castUrl == null) return;

      await GoogleCastRemoteMediaClient.instance.loadMedia(
        GoogleCastMediaInformationAndroid(
          contentId: castUrl,
          streamType: CastMediaStreamType.live,
          contentUrl: Uri.parse(castUrl),
          contentType: 'video/mp4',
          metadata: GoogleCastMovieMediaMetadata(
            title: '',
            studio: '',
            releaseDate: DateTime.now(),
          ),
        ),
        autoPlay: true,
        playPosition: Duration.zero,
      );
    } catch (_) {
      _isCasting = false;
      _castDeviceName = null;
      notifyListeners();
    }
  }

  /// Pauses playback on the remote Cast device.
  Future<void> pauseRemote() async {
    try {
      await GoogleCastRemoteMediaClient.instance.pause();
    } catch (_) {}
  }

  /// Resumes playback on the remote Cast device.
  Future<void> resumeRemote() async {
    try {
      await GoogleCastRemoteMediaClient.instance.play();
    } catch (_) {}
  }

  /// Ends the current Cast session and stops casting.
  void disconnect() {
    GoogleCastSessionManager.instance.endSessionAndStopCasting();
    _isCasting = false;
    _castDeviceName = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    stopDiscovery();
    super.dispose();
  }
}
