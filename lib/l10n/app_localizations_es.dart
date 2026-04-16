// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Torrent Player';

  @override
  String get labelMagnetLink => 'Magnet link';

  @override
  String get hintMagnetLink => 'magnet:?xt=urn:btih:…';

  @override
  String get btnPlay => 'Reproducir';

  @override
  String get btnOpenTorrent => 'Abrir .torrent';

  @override
  String get labelHistory => 'Historial';

  @override
  String get btnClearHistory => 'Borrar todo';

  @override
  String get confirmClearHistory => '¿Borrar todo el historial?';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnConfirm => 'Confirmar';

  @override
  String get snackNoVideo =>
      'No se encontraron archivos de vídeo en el torrent';

  @override
  String get dialogSelectVideo => 'Seleccionar vídeo';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsTabSystem => 'Sistema';

  @override
  String get settingsSectionTorrent => 'Cliente torrent';

  @override
  String get settingsDownloadSpeed => 'Límite de descarga';

  @override
  String get settingsUploadSpeed => 'Límite de subida';

  @override
  String get settingsUnlimited => 'Ilimitado';

  @override
  String get settingsSectionPlayer => 'Reproductor';

  @override
  String get settingsCacheSeconds => 'Caché anticipada (segundos)';

  @override
  String get settingsDemuxerMaxMb => 'Búfer demuxer (MB)';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsLangEs => 'Español';

  @override
  String get settingsLangEn => 'Inglés';

  @override
  String get castButtonTooltip => 'Enviar al TV';

  @override
  String get castDialogTitle => 'Enviar a dispositivo';

  @override
  String get castNoDevices => 'No se encontraron dispositivos Cast en tu WiFi';

  @override
  String get castConnecting => 'Conectando…';

  @override
  String get castUnknownTitle => 'Título desconocido';

  @override
  String castCastingTo(String device) {
    return 'Enviando a $device';
  }

  @override
  String get castNoCaptions => 'Sin subtítulos disponibles';

  @override
  String get castCaptionsOff => 'Desactivar';

  @override
  String castTrackFallback(int id) {
    return 'Pista $id';
  }

  @override
  String get playerAudioTrack => 'Audio';

  @override
  String get playerSubtitleTrack => 'Subtítulos';

  @override
  String get playerTrackOff => 'Desactivado';

  @override
  String get playerTrackAuto => 'Automático';

  @override
  String playerTrackLabel(int index) {
    return 'Pista $index';
  }

  @override
  String get playerVolume => 'Volumen';

  @override
  String get playerBrightness => 'Brillo';

  @override
  String playerSeekForward(int seconds) {
    return '+${seconds}s';
  }

  @override
  String playerSeekBackward(int seconds) {
    return '-${seconds}s';
  }

  @override
  String get playerBuffering => 'Cargando…';

  @override
  String get playerDownloadSpeed => 'Descarga';

  @override
  String get playerConnections => 'Pares';

  @override
  String get playerBufferedCache => 'Búfer';

  @override
  String get playerDownloaded => 'Descargado';

  @override
  String get castRetry => 'Reintentar';

  @override
  String get castSearching => 'Buscando dispositivos…';

  @override
  String get castDisconnect => 'Detener reproducción';

  @override
  String get castLoading => 'Cargando…';

  @override
  String get castError => 'Error de reproducción en el TV';

  @override
  String get updateAvailable => 'Actualización disponible';

  @override
  String updateVersion(String version) {
    return 'La versión $version está disponible';
  }

  @override
  String get updateDownload => 'Descargar';

  @override
  String get updateLatest => 'Ya tienes la última versión';

  @override
  String get updateCheckError => 'Error al buscar actualizaciones';

  @override
  String get updateChecking => 'Buscando actualizaciones…';

  @override
  String get settingsSectionUpdates => 'Actualizaciones';

  @override
  String get settingsCheckUpdates => 'Buscar actualizaciones';

  @override
  String settingsAppVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get backgroundNotifTitle => 'Torrent Player';

  @override
  String get backgroundNotifText => 'Descarga en progreso';
}
