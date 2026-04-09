import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:libtorrent_flutter/libtorrent_flutter.dart';

import '../services/torrent_service.dart';

/// Lifecycle states of a torrent being loaded.
enum TorrentLoadState { idle, loading, ready, error }

/// Manages the torrent lifecycle: adding magnets or .torrent files, waiting
/// for metadata, resolving streamable video files, and starting a stream.
///
/// Exposes reactive state via [ChangeNotifier] so the UI can reflect loading
/// progress, errors, and available video files.
class TorrentProvider extends ChangeNotifier {
  final _engine = TorrentService.instance.engine;

  TorrentLoadState _state = TorrentLoadState.idle;
  int? _torrentId;
  String? _torrentFilePath;
  TorrentInfo? _torrentInfo;
  List<FileInfo> _videoFiles = [];
  String? _errorMessage;
  StreamSubscription<Map<int, TorrentInfo>>? _torrentSub;

  /// Current loading state.
  TorrentLoadState get state => _state;

  /// Engine handle for the active torrent, if any.
  int? get torrentId => _torrentId;

  /// Path of a .torrent file selected by the user.
  String? get torrentFilePath => _torrentFilePath;

  /// Latest torrent info snapshot from the engine.
  TorrentInfo? get torrentInfo => _torrentInfo;

  /// Streamable video files found after metadata resolution.
  List<FileInfo> get videoFiles => _videoFiles;

  /// Human-readable error message, if [state] is [TorrentLoadState.error].
  String? get errorMessage => _errorMessage;

  /// Convenience flag for showing progress indicators.
  bool get isLoading => _state == TorrentLoadState.loading;

  /// Sets the .torrent file path and notifies listeners.
  set torrentFilePath(String? path) {
    _torrentFilePath = path;
    notifyListeners();
  }

  /// Resets the torrent state, removing the active torrent from the engine.
  void reset() {
    _torrentSub?.cancel();
    if (_torrentId != null) {
      _engine.removeTorrent(_torrentId!, deleteFiles: true);
    }
    _state = TorrentLoadState.idle;
    _torrentId = null;
    _torrentFilePath = null;
    _torrentInfo = null;
    _videoFiles = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Adds a magnet link and begins downloading metadata.
  Future<void> addMagnet(String magnet) async {
    if (_state == TorrentLoadState.loading) return;
    _state = TorrentLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _torrentId = _engine.addMagnet(magnet);
      _listenForMetadata(_torrentId!);
    } catch (e) {
      _state = TorrentLoadState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Adds a .torrent file by path and begins downloading metadata.
  Future<void> addTorrentFile(String path) async {
    if (_state == TorrentLoadState.loading) return;
    _state = TorrentLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _torrentId = _engine.addTorrentFile(path);
      _listenForMetadata(_torrentId!);
    } catch (e) {
      _state = TorrentLoadState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _listenForMetadata(int id) {
    _torrentSub?.cancel();
    _torrentSub = _engine.torrentUpdates.listen((torrents) {
      final info = torrents[id];
      if (info == null) return;

      _torrentInfo = info;
      notifyListeners();

      if (info.hasMetadata) {
        _torrentSub?.cancel();
        _resolveVideoFiles(id);
      }
    });
  }

  void _resolveVideoFiles(int id) {
    final files = _engine.getFiles(id);
    _videoFiles = files.where((f) => f.isStreamable).toList();

    if (_videoFiles.isEmpty) {
      _engine.removeTorrent(id, deleteFiles: true);
      _state = TorrentLoadState.error;
      _errorMessage = 'No se encontraron archivos de vídeo en el torrent';
      _torrentId = null;
    } else {
      _state = TorrentLoadState.ready;
    }
    notifyListeners();
  }

  /// Starts streaming the selected file. Returns the stream URL.
  String startStream(FileInfo file) {
    final stream = _engine.startStream(
      _torrentId!,
      fileIndex: file.index,
      maxCacheBytes: 500 * 1024 * 1024,
    );
    // Reset UI state for next use without killing the torrent
    _state = TorrentLoadState.idle;
    _torrentFilePath = null;
    _videoFiles = [];
    notifyListeners();
    return stream.url;
  }

  @override
  void dispose() {
    _torrentSub?.cancel();
    super.dispose();
  }
}
