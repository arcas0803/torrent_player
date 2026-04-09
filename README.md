<div align="center">

# 🎬 Torrent Player

**Reproduce vídeos directamente desde torrents — sin esperar a que descarguen.**

[![Android](https://img.shields.io/badge/Android-API_21%2B-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-54C5F8?logo=flutter&logoColor=white)](https://flutter.dev)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/arcas0803/torrent_player?label=Latest%20Release&color=brightgreen)](https://github.com/arcas0803/torrent_player/releases/latest)

[⬇ **Download APK**](https://github.com/arcas0803/torrent_player/releases/latest)

</div>

---

## Features

- **Streaming progresivo** — el vídeo empieza a reproducirse en segundos gracias a un servidor HTTP local (libtorrent 2.0).
- **Magnet links & archivos `.torrent`** — pega un magnet link o abre un archivo directamente desde el gestor de archivos, otras apps o el navegador.
- **Intents nativos** — la app se registra como gestor del esquema `magnet:` y del tipo MIME `application/x-bittorrent`.
- **Reproductor completo** — controles de reproducción, seekbar con posición y duración, volumen y brillo ajustables con swipe.
- **Chromecast** — envía el stream a cualquier dispositivo Cast de tu red local.
- **Tarjeta de estado** — velocidad de descarga/upload, ratio de semillas, porcentaje descargado y MB descargados en tiempo real.
- **Historial de magnets** — guarda los últimos links usados para acceso rápido.
- **Diseño adaptativo** — layout en columna única en teléfonos; panel dual en tablets (≥ 600 dp).
- **Material 3 / tema oscuro** — interfaz limpia en modo oscuro por defecto.

---

## Platform Support

| Plataforma | Soporte |
|---|---|
| Android 5.0+ (API 21+) | ✅ |
| iOS | ❌ (no planificado) |
| Desktop / Web | ❌ (no planificado) |

---

## Getting Started

### Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.x
- Android SDK / Android Studio
- Un dispositivo o emulador Android (API 21+)

### Build desde el código fuente

```bash
# 1. Clonar el repositorio
git clone https://github.com/arcas0803/torrent_player.git
cd torrent_player

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en un dispositivo conectado
flutter run

# 4. Generar APK de release (firma debug, sin keystore adicional)
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

---

## Releases

Las releases se publican automáticamente cada vez que se hace push a `master`. El workflow de CI/CD:

1. **Analiza** el código con `dart analyze`.
2. **Construye** el APK de release.
3. **Publica** la release en GitHub con el APK adjunto.

Descarga siempre la última versión desde la sección [**Releases**](https://github.com/arcas0803/torrent_player/releases).

---

## Contributing

Las contribuciones son bienvenidas. Por favor, trabaja sobre la rama `dev`:

```bash
git checkout dev
git checkout -b feature/mi-mejora
# … tus cambios …
git push origin feature/mi-mejora
# Abre un Pull Request hacia dev
```

Los merges a `master` son los que disparan la release automática.

---

## License

Distribuido bajo la licencia **GPL-3.0**. Ver [LICENSE](LICENSE) para más detalles.

> **Nota:** Este proyecto utiliza `libtorrent_flutter` (GPL-3.0) y `media_kit` (MIT).
> Asegúrate de respetar los términos de cada dependencia al distribuir la app.


