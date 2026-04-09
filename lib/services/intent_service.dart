import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';

/// Listens for incoming deep-link and file intents on Android and resolves
/// them to strings that the UI can act on:
///
/// - `magnet:?xt=...` links are passed through as-is.
/// - `.torrent` `file://` URIs are converted to absolute file paths.
/// - `.torrent` `content://` URIs are copied to a temp file via a native
///   [MethodChannel] call; the resulting absolute path is emitted.
///
/// Use [getInitialUri] once in [initState] to handle cold-start intents, and
/// subscribe to [stream] to handle intents while the app is already running.
class IntentService {
  IntentService._();

  /// Singleton instance.
  static final instance = IntentService._();

  static const _channel = MethodChannel('torrent_player/intent');
  final _appLinks = AppLinks();

  /// Stream of resolved values emitted while the app is running.
  ///
  /// Emits magnet-link strings or absolute file paths for `.torrent` files.
  /// Invalid or unrecognised URIs are filtered out.
  Stream<String> get stream => _appLinks.uriLinkStream
      .asyncMap(_resolve)
      .where((s) => s != null)
      .cast<String>();

  /// Returns the URI from the intent that cold-started the app, or `null`
  /// if the app was launched normally.
  Future<String?> getInitialUri() async {
    final uri = await _appLinks.getInitialLink();
    if (uri == null) return null;
    return _resolve(uri);
  }

  // ---- Private ----

  Future<String?> _resolve(Uri uri) async {
    final s = uri.toString();
    if (s.startsWith('magnet:')) return s;
    if (uri.scheme == 'file') return uri.toFilePath();
    if (uri.scheme == 'content') {
      try {
        return await _channel.invokeMethod<String>('copyContentUri', {
          'uri': s,
        });
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
