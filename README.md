<div align="center">

# 🎬 Torrent Player

**Stream videos directly from torrents — no waiting for them to download.**

[![Android](https://img.shields.io/badge/Android-API_21%2B-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-54C5F8?logo=flutter&logoColor=white)](https://flutter.dev)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/arcas0803/torrent_player?label=Latest%20Release&color=brightgreen)](https://github.com/arcas0803/torrent_player/releases/latest)

[⬇ **Download APK**](https://github.com/arcas0803/torrent_player/releases/latest)

</div>

---

## Features

- **Progressive streaming** — playback starts within seconds via a local HTTP server powered by libtorrent 2.0.
- **Magnet links & `.torrent` files** — paste a magnet link or open a torrent file directly from the file manager, other apps, or the browser.
- **Native intents** — the app registers as a handler for the `magnet:` scheme and `application/x-bittorrent` MIME type.
- **Full-featured player** — playback controls, seekbar with position and duration, swipe gestures for volume and brightness.
- **Picture-in-Picture (PiP)** — tap the PiP button to shrink the player into a floating overlay while using other apps.
- **Background playback** — when the app is sent to the background mid-playback, a foreground service keeps the stream alive with a persistent notification.
- **Chromecast** — cast the stream to any Cast-enabled device on your local network via a dedicated cast screen.
- **Auto-updater** — on launch the app silently checks GitHub Releases and shows a dialog if a new version is available.
- **Status card** — live download/upload speed, seed ratio, download percentage, and total MB downloaded.
- **Magnet history** — saves the last 20 used links for quick access.
- **Adaptive layout** — single-column on phones; dual-pane on tablets (≥ 600 dp).
- **Material 3 / dark theme** — clean dark-mode interface by default.
- **Localisation** — English and Spanish built in.

---

## Platform Support

| Platform | Support |
|---|---|
| Android 5.0+ (API 21+) | ✅ Fully supported |
| iOS | ❌ No plans |
| macOS / Linux / Windows | 🔜 Planned |
| Web | ❌ No plans |

---

## Getting Started

### Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.11
- Android SDK / Android Studio
- An Android device or emulator (API 21+)

### Build from source

```bash
# 1. Clone the repository
git clone https://github.com/arcas0803/torrent_player.git
cd torrent_player

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device
flutter run

# 4. Build a release APK
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

---

## Releases

Releases are published automatically on every push to `master`. The CI/CD workflow:

1. **Analyses** the code with `dart analyze`.
2. **Runs** the unit test suite with `flutter test`.
3. **Builds** the release APK.
4. **Tags** the commit as `v{version}` and **publishes** the GitHub Release with the APK attached.

Always download the latest version from the [**Releases**](https://github.com/arcas0803/torrent_player/releases) section.

---

## Contributing

Contributions are welcome. Please work off the `dev` branch:

```bash
git checkout dev
git checkout -b feature/my-improvement
# … your changes …
git push origin feature/my-improvement
# Open a Pull Request targeting dev
```

Merges to `master` trigger the automatic release.

---

## License

Distributed under the **GPL-3.0** licence. See [LICENSE](LICENSE) for details.

> **Nota:** Este proyecto utiliza `libtorrent_flutter` (GPL-3.0) y `media_kit` (MIT).
> Asegúrate de respetar los términos de cada dependencia al distribuir la app.


