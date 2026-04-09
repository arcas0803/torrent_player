# Torrent Video Player — Especificaciones

## 1. Visión general

Aplicación Flutter para reproducir vídeos directamente desde torrents (magnet o archivo `.torrent`) sin necesidad de descargar el fichero completo. El motor de torrents hace _streaming_ progresivo mediante un servidor HTTP local; el reproductor de vídeo se conecta a esa URL como si fuera un stream de red.

---

## 2. Stack tecnológico

| Paquete | Versión | Rol |
|---|---|---|
| `libtorrent_flutter` | `^1.7.8` | Motor de torrents (libtorrent 2.0 via FFI). Servidor HTTP local de streaming. |
| `media_kit` | `^1.2.6` | Motor de reproducción multimedia (libmpv via FFI). |
| `media_kit_video` | `^2.0.1` | Widget `Video` y controles de reproducción. |
| `media_kit_libs_video` | `^1.0.7` | Librerías nativas de vídeo para `media_kit`. |
| `file_picker` | `^8.x` | Selector de archivos `.torrent` del sistema de ficheros. |
| `flutter` | SDK | Framework UI. |

> **Nota de licencias:** `libtorrent_flutter` tiene licencia GPL-3.0. Asegúrate de que la licencia de distribución de tu aplicación sea compatible.

---

## 3. Plataforma objetivo

**Solo Android** (Android 5.0+ / API 21+).

La app está adaptada para dos factores de forma:

| Factor de forma | Breakpoint | Comportamiento |
|---|---|---|
| **Phone** | ancho < 600 dp | Layout en columna única, orientación libre. |
| **Tablet** | ancho ≥ 600 dp | Layout de dos paneles donde el espacio extra se usa para mostrar el estado del torrent junto al input. |

---

## 4. Diseño visual

- **Design system:** Material 3 (`useMaterial3: true`).
- **Tema:** Modo oscuro por defecto (`themeMode: ThemeMode.dark`).
- **Seed color:** azul profundo (`Color(0xFF1565C0)`) — evoca tecnología sin ser llamativo.
- **Typography:** valores predeterminados de Material 3.
- **No hay modo claro** en la primera versión (app solo oscura).
- **Responsive:** Uso de `LayoutBuilder` / `MediaQuery.of(context).size.width` para adaptar el layout a phone (< 600 dp) y tablet (≥ 600 dp).
- **Densidad táctil:** Targets mínimos de toque de 48×48 dp en phone, 56×56 dp en tablet.

### Paleta oscura generada por `ColorScheme.fromSeed`

```
brightness: Brightness.dark
seedColor: Color(0xFF1565C0)
```

---

## 5. Arquitectura de la app

```
lib/
├── main.dart                  # Punto de entrada; inicializa MediaKit y LibtorrentFlutter
├── app.dart                   # MaterialApp, tema M3 oscuro, rutas
├── pages/
│   ├── home_page.dart         # Pantalla de entrada: input magnet / selector .torrent
│   └── player_page.dart       # Reproductor a pantalla completa
├── services/
│   └── torrent_service.dart   # Wrapper de LibtorrentFlutter (singleton)
└── widgets/
    ├── torrent_status_card.dart  # Tarjeta de estado de descarga / buffer
    └── adaptive_layout.dart      # Helper que expone isTablet y devuelve el layout correcto
```

---

## 6. Flujo de usuario

```
[Home Page]
    │
    ├─── Usuario pega un magnet link  ──► [Botón "Reproducir"] ─► addMagnet()
    │                                                               │
    └─── Usuario pulsa "Abrir .torrent" ─► file_picker ──────────► addTorrentFile()
                                                                    │
                                                    esperar hasMetadata == true
                                                                    │
                                                    getFiles()  →  filtrar isStreamable
                                                                    │
                                              ¿hay ficheros de vídeo? ──── No ──► Snackbar "Sin vídeo"
                                                                    │ Sí
                                              ¿hay más de un vídeo?
                                              │ Sí ──► BottomSheet con lista de archivos
                                              │         └── Usuario selecciona uno
                                              │ No ──► usa el único disponible
                                                                    │
                                                              startStream(id, fileIndex)
                                                              (descarga empieza aquí)
                                                                    │
                                                           [Player Page]
                                                     media_kit abre stream.url
                                                     overlay stats visible al tocar
                                                                    │
                                                        [Usuario pulsa Atrás]
                                                     stopAllStreamsForTorrent()
                                                     removeTorrent(id, deleteFiles: true)
```

---

## 7. Pantallas detalladas

### 7.1 Home Page (`home_page.dart`)

**Widget auxiliar `_VideoFilePickerSheet`:**

BottomSheet modal que aparece cuando el torrent contiene más de un archivo de vídeo. Muestra una lista de `ListTile` con nombre, tamaño formateado y un icono de vídeo. Al pulsar uno navega al reproductor con ese archivo.

```dart
ListTile(
  leading: const Icon(Icons.movie_outlined),
  title: Text(file.name),
  subtitle: Text(_formatBytes(file.size)),
  onTap: () => Navigator.pop(context, file),
)
```

**Layout adaptativo:**

- **Phone (< 600 dp):** Todo en una sola columna. `TorrentStatusCard` aparece debajo del input al detectar un torrent activo.
- **Tablet (≥ 600 dp):** Dos columnas con `Row`. Columna izquierda (flex 1): input magnet + botones. Columna derecha (flex 1): `TorrentStatusCard` siempre visible (vacía si no hay torrent).

```dart
// Detección de factor de forma
final isTablet = MediaQuery.of(context).size.width >= 600;
```

**Elementos UI:**

| Widget | Descripción |
|---|---|
| `AppBar` | Título "Torrent Player", sin acciones. Color de fondo `surface`. |
| `TextField` (magnet) | Campo de texto multilínea con hint `magnet:?xt=urn:btih:…`. Tiene un botón de limpiar al final. Validación básica: debe empezar por `magnet:`. |
| `FilledButton` "Reproducir" | Activo sólo cuando el campo magnet tiene texto válido o se ha seleccionado un archivo. |
| `OutlinedButton` "Abrir .torrent" | Abre `file_picker` filtrando extensión `.torrent`. |
| `LinearProgressIndicator` | Visible cuando el estado es `_State.loading` (buscando metadatos). |
| `TorrentStatusCard` | Phone: aparece debajo del input. Tablet: panel derecho fijo. |
| Error `SnackBar` | Si no se detecta ningún archivo de vídeo en el torrent. |

**Estados internos (`enum _HomeState`):**

- `idle` — estado inicial, sin torrent.
- `loading` — magnet/archivo añadido, esperando metadatos (`hasMetadata=false`).
- `selecting` — metadatos disponibles; si hay más de un vídeo se muestra un `ModalBottomSheet` con la lista. Si solo hay uno se navega directamente.
- `error` — sin archivos de vídeo o fallo de red.

**Lógica clave:**

```dart
// 1. Añadir torrent
final torrentId = engine.addMagnet(magnetText);
// o bien:
final torrentId = engine.addTorrentFile(filePath);

// 2. Esperar metadatos (escuchar torrentUpdates stream)
engine.torrentUpdates.listen((torrents) {
  if (torrents[torrentId]?.hasMetadata == true) {
    _onMetadataReady(torrentId);
  }
});

// 3. Filtrar archivos de vídeo
final files = engine.getFiles(torrentId);
final videoFiles = files.where((f) => f.isStreamable).toList();

if (videoFiles.isEmpty) {
  // Mostrar error
  return;
}

// 4. Si hay más de un vídeo, mostrar BottomSheet de selección
FileInfo selectedFile;
if (videoFiles.length == 1) {
  selectedFile = videoFiles.first;
} else {
  selectedFile = await showModalBottomSheet<FileInfo>(
    context: context,
    builder: (_) => _VideoFilePickerSheet(files: videoFiles),
  );
  if (selectedFile == null) return; // usuario canceló
}

// 5. Iniciar stream (la descarga comienza aquí)
final stream = engine.startStream(torrentId, fileIndex: selectedFile.index);

// 6. Navegar al reproductor
Navigator.pushNamed(
  context,
  '/player',
  arguments: PlayerArgs(streamUrl: stream.url, torrentId: torrentId),
);
```

---

### 7.2 Player Page (`player_page.dart`)

**Características:**

- Pantalla completa, sin `AppBar` visible por defecto (controles de vídeo superpuestos).
- **La descarga arranca en cuanto se abre la página** — `startStream()` ya se llamó en Home antes de navegar, por lo que el motor está activo desde el primer frame.
- Fuerza orientación **landscape** al entrar (`SystemChrome.setPreferredOrientations([landscape])`), tanto en phone como en tablet.
- Restaura orientación libre (`DeviceOrientation.values`) al salir (`dispose`).
- Oculta barras del sistema: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)`.
- Usa `MaterialVideoControls` de `media_kit_video` (controles Material 3).
- **Tablet:** Los controles tienen mayor `buttonBarButtonSize` (32 dp en lugar de 24 dp) y más padding en la barra de controles para aprovechar la pantalla grande.
- **Phone:** Controles estándar. Botones de 24 dp.
- **Al salir (back o botón atrás):** se detienen los streams y se elimina el torrent con `deleteFiles: true`, borrando todo lo descargado.

**Elementos UI:**

| Widget | Descripción |
|---|---|
| `Video` | Ocupa 100% de pantalla. `fit: BoxFit.contain`. |
| Controles nativos `media_kit_video` | Play/Pausa, barra de progreso, tiempo, fullscreen, volumen. Tamaño adaptado según factor de forma. |
| `IconButton` "Atrás" (en `topButtonBar`) | Detiene stream, elimina torrent con `deleteFiles: true` y llama a `Navigator.pop()`. |
| **`TorrentStatsOverlay`** (overlay tap-to-toggle) | Panel semitransparente superpuesto sobre el vídeo. Oculto por defecto; se muestra/oculta con un toque fuera de los controles. Contiene los tres indicadores en tiempo real (ver detalle abajo). |

**`TorrentStatsOverlay` — contenido:**

| Indicador | Fuente de datos | Formato |
|---|---|---|
| Peers conectados | `TorrentInfo.numPeers` (stream `torrentUpdates`) | `👥 12 peers` |
| Velocidad de descarga | `TorrentInfo.downloadRate` (bytes/s) | `⬇ 2.4 MB/s` |
| Almacenado en dispositivo | `TorrentInfo.totalDone` (bytes descargados a disco) | `💾 148 MB / 1.2 GB` |

El overlay se actualiza en cada tick del stream `torrentUpdates` (cada ~500 ms por defecto).

```dart
// Escucha en initState del PlayerPage
_statsSub = engine.torrentUpdates.listen((torrents) {
  final info = torrents[widget.torrentId];
  if (info != null && mounted) setState(() => _stats = info);
});
```

**Lógica clave:**

```dart
late final Player player = Player();
late final VideoController controller = VideoController(player);

@override
void initState() {
  super.initState();
  _lockLandscape();
  player.open(Media(widget.streamUrl));
}

@override
void dispose() {
  _statsSub.cancel();
  player.dispose();
  engine.stopAllStreamsForTorrent(widget.torrentId);
  // Elimina el torrent Y borra los archivos descargados
  engine.removeTorrent(widget.torrentId, deleteFiles: true);
  _restoreOrientation();
  super.dispose();
}
```

---

## 8. Servicio de torrent (`torrent_service.dart`)

Singleton que envuelve `LibtorrentFlutter`:

```dart
class TorrentService {
  static final TorrentService instance = TorrentService._();
  TorrentService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await LibtorrentFlutter.init(fetchTrackers: true);
    _initialized = true;
  }

  LibtorrentFlutter get engine => LibtorrentFlutter.instance;
}
```

---

## 9. Inicialización (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await TorrentService.instance.init();
  runApp(const App());
}
```

---

## 10. Tema Material 3 (`app.dart`)

```dart
MaterialApp(
  title: 'Torrent Player',
  themeMode: ThemeMode.dark,
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.dark,
    ),
  ),
  ...
)
```

---

## 11. Permisos Android (`AndroidManifest.xml`)

```xml
<!-- Acceso a internet para torrents y tracker DHT -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Leer archivos .torrent del almacenamiento (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />

<!-- Leer archivos .torrent del almacenamiento (Android ≤12) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

> No se necesitan permisos adicionales. El servidor HTTP de streaming usa `localhost`, por lo que no requiere permisos de red local.

---

## 12. `pubspec.yaml` final

```yaml
dependencies:
  flutter:
    sdk: flutter
  libtorrent_flutter: ^1.7.8
  media_kit: ^1.2.6
  media_kit_video: ^2.0.1
  media_kit_libs_video: ^1.0.7
  file_picker: ^8.3.2
  cupertino_icons: ^1.0.8
```

---

## 13. Consideraciones de seguridad y privacidad

- El servidor HTTP de streaming escucha **sólo en localhost** (`127.0.0.1`). No expone flujo de datos a la red local.
- No se almacena ningún magnet link ni historial de torrents de forma persistente (primera versión).
- Los ficheros descargados se guardan en el directorio temporal del sistema (`system temp`), que el SO puede limpiar automáticamente.
- Llamar a `engine.disposeAll()` al cerrar la app garantiza que todos los ficheros temporales y streams se liberan limpiamente.

---

## 14. Limitaciones conocidas (v1.0)

| Limitación | Motivo |
|---|---|
| Solo Android | Scope reducido a una plataforma para simplificar mantenimiento. |
| Sin persistencia de sesión | Al cerrar o salir del reproductor, el torrent se elimina junto con sus archivos. |
| Sin descarga completa en background | Requiere `flutter_foreground_task` (Foreground Service); fuera del scope v1. |
| No se puede volver a un torrent pausado | Al salir del reproductor la descarga se limpia; hay que volver a añadirlo. |

---

## 15. Roadmap futuro

- [ ] Historial de magnet links recientes (almacenado localmente con `shared_preferences`).
- [ ] Background streaming con Foreground Service (Android).
- [ ] Soporte de subtítulos externos (SRT/WebVTT) via `media_kit`.
- [ ] Control de velocidad de descarga/subida desde la UI.
- [ ] Gestión de torrent activo (pausar, reanudar, eliminar) desde la Home Page.
- [ ] Soporte de picture-in-picture (PiP) en Android para continuar viendo el vídeo al minimizar.



