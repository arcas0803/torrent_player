// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Torrent Player';

  @override
  String get labelMagnetLink => 'Magnet link';

  @override
  String get hintMagnetLink => 'magnet:?xt=urn:btih:…';

  @override
  String get btnPlay => 'Play';

  @override
  String get btnOpenTorrent => 'Open .torrent';

  @override
  String get labelHistory => 'History';

  @override
  String get btnClearHistory => 'Clear all';

  @override
  String get confirmClearHistory => 'Clear all history?';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get snackNoVideo => 'No video files found in the torrent';

  @override
  String get dialogSelectVideo => 'Select video';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionTorrent => 'Torrent client';

  @override
  String get settingsDownloadSpeed => 'Download limit';

  @override
  String get settingsUploadSpeed => 'Upload limit';

  @override
  String get settingsUnlimited => 'Unlimited';

  @override
  String get settingsSectionPlayer => 'Player';

  @override
  String get settingsCacheSeconds => 'Cache ahead (seconds)';

  @override
  String get settingsDemuxerMaxMb => 'Demuxer buffer (MB)';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsLangEs => 'Spanish';

  @override
  String get settingsLangEn => 'English';

  @override
  String get castButtonTooltip => 'Cast to TV';

  @override
  String get castDialogTitle => 'Cast to device';

  @override
  String get castNoDevices => 'No Cast devices found on your WiFi';

  @override
  String get castConnecting => 'Connecting…';

  @override
  String get castUnknownTitle => 'Unknown title';

  @override
  String castCastingTo(String device) {
    return 'Casting to $device';
  }

  @override
  String get castNoCaptions => 'No captions available';

  @override
  String get castCaptionsOff => 'Off';

  @override
  String castTrackFallback(int id) {
    return 'Track $id';
  }

  @override
  String get playerAudioTrack => 'Audio';

  @override
  String get playerSubtitleTrack => 'Subtitles';

  @override
  String get playerTrackOff => 'Off';

  @override
  String get playerTrackAuto => 'Auto';

  @override
  String playerTrackLabel(int index) {
    return 'Track $index';
  }

  @override
  String get playerVolume => 'Volume';

  @override
  String get playerBrightness => 'Brightness';

  @override
  String playerSeekForward(int seconds) {
    return '+${seconds}s';
  }

  @override
  String playerSeekBackward(int seconds) {
    return '-${seconds}s';
  }

  @override
  String get playerBuffering => 'Buffering…';

  @override
  String get playerDownloadSpeed => 'Download';

  @override
  String get playerConnections => 'Peers';

  @override
  String get playerBufferedCache => 'Buffer';

  @override
  String get playerDownloaded => 'Downloaded';

  @override
  String get castRetry => 'Retry';

  @override
  String get castSearching => 'Searching for devices…';
}
