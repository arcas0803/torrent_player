import 'dart:io';

/// Resolves the device's local WiFi IP and builds a Chromecast-accessible URL
/// from a libtorrent stream URL (which uses 127.0.0.1).
class CastService {
  CastService._();

  /// Returns the first non-loopback IPv4 address on an active WiFi/LAN interface,
  /// or null if unavailable (e.g. no WiFi).
  static Future<String?> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Replaces `127.0.0.1` in [streamUrl] with the device LAN IP so Chromecast
  /// can reach the libtorrent HTTP server.
  ///
  /// Returns null if no LAN IP is available.
  static Future<String?> buildCastUrl(String streamUrl) async {
    final ip = await getLocalIp();
    if (ip == null) return null;
    return streamUrl.replaceFirst('127.0.0.1', ip);
  }
}
