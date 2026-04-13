import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Top-level entry point for the foreground service isolate.
@pragma('vm:entry-point')
void _backgroundEntryPoint() {
  FlutterForegroundTask.setTaskHandler(_TorrentTaskHandler());
}

class _TorrentTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

/// Manages the Android foreground service that keeps the torrent engine alive
/// while the app is not visible to the user.
class BackgroundService {
  /// Must be called once at app startup (before [runApp]).
  static void init() {
    if (!Platform.isAndroid) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'torrent_bg_channel',
        channelName: 'Background Download',
        channelDescription: 'Torrent download running in the background',
        channelImportance: NotificationChannelImportance.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWifiLock: true,
      ),
    );
  }

  /// Starts the foreground service with a status-bar notification.
  static Future<void> start({
    required String title,
    required String text,
  }) async {
    if (!Platform.isAndroid) return;
    await FlutterForegroundTask.startService(
      notificationTitle: title,
      notificationText: text,
      callback: _backgroundEntryPoint,
    );
  }

  /// Stops the foreground service.
  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    await FlutterForegroundTask.stopService();
  }
}
