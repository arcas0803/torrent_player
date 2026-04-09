import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'services/torrent_service.dart';

/// Application entry point.
///
/// Initialises Flutter bindings, the media-kit native backend, and the
/// libtorrent engine before launching the widget tree.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await TorrentService.instance.init();
  runApp(const App());
}
