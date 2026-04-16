import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Torrent Player'**
  String get appTitle;

  /// No description provided for @labelMagnetLink.
  ///
  /// In en, this message translates to:
  /// **'Magnet link'**
  String get labelMagnetLink;

  /// No description provided for @hintMagnetLink.
  ///
  /// In en, this message translates to:
  /// **'magnet:?xt=urn:btih:…'**
  String get hintMagnetLink;

  /// No description provided for @btnPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get btnPlay;

  /// No description provided for @btnOpenTorrent.
  ///
  /// In en, this message translates to:
  /// **'Open .torrent'**
  String get btnOpenTorrent;

  /// No description provided for @labelHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get labelHistory;

  /// No description provided for @btnClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get btnClearHistory;

  /// No description provided for @confirmClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear all history?'**
  String get confirmClearHistory;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// No description provided for @snackNoVideo.
  ///
  /// In en, this message translates to:
  /// **'No video files found in the torrent'**
  String get snackNoVideo;

  /// No description provided for @dialogSelectVideo.
  ///
  /// In en, this message translates to:
  /// **'Select video'**
  String get dialogSelectVideo;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTabSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsTabSystem;

  /// No description provided for @settingsSectionTorrent.
  ///
  /// In en, this message translates to:
  /// **'Torrent client'**
  String get settingsSectionTorrent;

  /// No description provided for @settingsDownloadSpeed.
  ///
  /// In en, this message translates to:
  /// **'Download limit'**
  String get settingsDownloadSpeed;

  /// No description provided for @settingsUploadSpeed.
  ///
  /// In en, this message translates to:
  /// **'Upload limit'**
  String get settingsUploadSpeed;

  /// No description provided for @settingsUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get settingsUnlimited;

  /// No description provided for @settingsSectionPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get settingsSectionPlayer;

  /// No description provided for @settingsCacheSeconds.
  ///
  /// In en, this message translates to:
  /// **'Cache ahead (seconds)'**
  String get settingsCacheSeconds;

  /// No description provided for @settingsDemuxerMaxMb.
  ///
  /// In en, this message translates to:
  /// **'Demuxer buffer (MB)'**
  String get settingsDemuxerMaxMb;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsLangEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLangEs;

  /// No description provided for @settingsLangEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLangEn;

  /// No description provided for @castButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cast to TV'**
  String get castButtonTooltip;

  /// No description provided for @castDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cast to device'**
  String get castDialogTitle;

  /// No description provided for @castNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No Cast devices found on your WiFi'**
  String get castNoDevices;

  /// No description provided for @castConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get castConnecting;

  /// No description provided for @castUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown title'**
  String get castUnknownTitle;

  /// No description provided for @castCastingTo.
  ///
  /// In en, this message translates to:
  /// **'Casting to {device}'**
  String castCastingTo(String device);

  /// No description provided for @castNoCaptions.
  ///
  /// In en, this message translates to:
  /// **'No captions available'**
  String get castNoCaptions;

  /// No description provided for @castCaptionsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get castCaptionsOff;

  /// No description provided for @castTrackFallback.
  ///
  /// In en, this message translates to:
  /// **'Track {id}'**
  String castTrackFallback(int id);

  /// No description provided for @playerAudioTrack.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get playerAudioTrack;

  /// No description provided for @playerSubtitleTrack.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get playerSubtitleTrack;

  /// No description provided for @playerTrackOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get playerTrackOff;

  /// No description provided for @playerTrackAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get playerTrackAuto;

  /// No description provided for @playerTrackLabel.
  ///
  /// In en, this message translates to:
  /// **'Track {index}'**
  String playerTrackLabel(int index);

  /// No description provided for @playerVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get playerVolume;

  /// No description provided for @playerBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get playerBrightness;

  /// No description provided for @playerSeekForward.
  ///
  /// In en, this message translates to:
  /// **'+{seconds}s'**
  String playerSeekForward(int seconds);

  /// No description provided for @playerSeekBackward.
  ///
  /// In en, this message translates to:
  /// **'-{seconds}s'**
  String playerSeekBackward(int seconds);

  /// No description provided for @playerBuffering.
  ///
  /// In en, this message translates to:
  /// **'Buffering…'**
  String get playerBuffering;

  /// No description provided for @playerDownloadSpeed.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get playerDownloadSpeed;

  /// No description provided for @playerConnections.
  ///
  /// In en, this message translates to:
  /// **'Peers'**
  String get playerConnections;

  /// No description provided for @playerBufferedCache.
  ///
  /// In en, this message translates to:
  /// **'Buffer'**
  String get playerBufferedCache;

  /// No description provided for @playerDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get playerDownloaded;

  /// No description provided for @castRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get castRetry;

  /// No description provided for @castSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching for devices…'**
  String get castSearching;

  /// No description provided for @castDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Stop casting'**
  String get castDisconnect;

  /// No description provided for @castLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get castLoading;

  /// No description provided for @castError.
  ///
  /// In en, this message translates to:
  /// **'Playback failed on the TV'**
  String get castError;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @updateVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available'**
  String updateVersion(String version);

  /// No description provided for @updateDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateDownload;

  /// No description provided for @updateLatest.
  ///
  /// In en, this message translates to:
  /// **'You have the latest version'**
  String get updateLatest;

  /// No description provided for @updateCheckError.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates'**
  String get updateCheckError;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updateChecking;

  /// No description provided for @settingsSectionUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get settingsSectionUpdates;

  /// No description provided for @settingsCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get settingsCheckUpdates;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsAppVersion(String version);

  /// No description provided for @backgroundNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Torrent Player'**
  String get backgroundNotifTitle;

  /// No description provided for @backgroundNotifText.
  ///
  /// In en, this message translates to:
  /// **'Download in progress'**
  String get backgroundNotifText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
