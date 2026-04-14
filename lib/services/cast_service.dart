import 'dart:io';

import 'package:flutter/foundation.dart';

/// Resolves the device's local WiFi IP and builds a Chromecast-accessible URL
/// from a libtorrent stream URL (which uses 127.0.0.1).
///
/// Strategy:
/// 1. Try a simple IP substitution (works when libtorrent binds to 0.0.0.0).
/// 2. If the LAN IP is not reachable, spin up an internal HTTP proxy that
///    listens on all interfaces and forwards to the loopback server.
class CastService {
  CastService._();

  // ── Proxy state ────────────────────────────────────────────────────────────
  static HttpServer? _proxy;
  static int _proxyPort = 0;
  static int _proxiedPort = 0; // upstream libtorrent port the proxy forwards to

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns the first non-loopback IPv4 address on an active WiFi/LAN
  /// interface, or null if unavailable (e.g. no WiFi).
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

  /// Returns a ({url, contentType}) record pointing to the libtorrent stream
  /// in a way that the Chromecast device can reach.
  ///
  /// First tries a direct LAN IP substitution.  If the server is loopback-only,
  /// starts a transparent HTTP proxy bound to all interfaces and returns a URL
  /// that points to the proxy instead.
  ///
  /// Returns null if no LAN IP is available.
  static Future<({String url, String contentType})?> buildCastUrl(
    String streamUrl,
  ) async {
    final ip = await getLocalIp();
    if (ip == null) return null;

    final upstreamUri = Uri.parse(streamUrl);

    // ── Try direct substitution first ───────────────────────────────────────
    final directUrl = streamUrl.replaceFirst('127.0.0.1', ip);
    final directResult = await _headRequest(directUrl);
    if (directResult != null) {
      debugPrint('[CastService] Direct LAN URL reachable: $directUrl');
      return (
        url: directUrl,
        contentType: _guessContentType(directResult, upstreamUri.path),
      );
    }

    debugPrint('[CastService] Direct URL unreachable – starting proxy');

    // ── Fall back to internal HTTP proxy ────────────────────────────────────
    await _ensureProxy(upstreamUri.port);
    final proxyUrl = Uri(
      scheme: 'http',
      host: ip,
      port: _proxyPort,
      path: upstreamUri.path,
      query: upstreamUri.query.isEmpty ? null : upstreamUri.query,
    ).toString();

    // Verify proxy is working (HEAD to 127.0.0.1 via proxy)
    final proxyResult = await _headRequest(proxyUrl);
    return (
      url: proxyUrl,
      contentType: _guessContentType(proxyResult, upstreamUri.path),
    );
  }

  /// Stops the proxy server (call when Cast session ends).
  static Future<void> stopProxy() async {
    await _proxy?.close(force: true);
    _proxy = null;
    _proxyPort = 0;
    _proxiedPort = 0;
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  /// Starts (or reuses) the transparent proxy forwarding to [upstreamPort].
  static Future<void> _ensureProxy(int upstreamPort) async {
    if (_proxy != null && _proxiedPort == upstreamPort) return;

    await _proxy?.close(force: true);
    _proxy = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _proxyPort = _proxy!.port;
    _proxiedPort = upstreamPort;
    debugPrint(
      '[CastService] Proxy listening on port $_proxyPort → 127.0.0.1:$upstreamPort',
    );

    _proxy!.listen((HttpRequest req) async {
      final targetUri = Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: upstreamPort,
        path: req.uri.path,
        query: req.uri.query.isEmpty ? null : req.uri.query,
      );
      final client = HttpClient();
      try {
        final proxyReq = await client.openUrl(req.method, targetUri);
        req.headers.forEach((name, values) {
          if (name.toLowerCase() != 'host') {
            for (final v in values) {
              proxyReq.headers.add(name, v);
            }
          }
        });
        proxyReq.headers.host = '127.0.0.1';
        proxyReq.headers.port = upstreamPort;

        final proxyResp = await proxyReq.close();
        req.response.statusCode = proxyResp.statusCode;
        proxyResp.headers.forEach((name, values) {
          for (final v in values) {
            req.response.headers.add(name, v);
          }
        });
        // Ensure CORS is present even for proxy responses
        req.response.headers.set('access-control-allow-origin', '*');
        await proxyResp.pipe(req.response);
      } catch (e) {
        debugPrint('[CastService] Proxy error for ${req.uri}: $e');
        req.response.statusCode = HttpStatus.badGateway;
        await req.response.close();
      } finally {
        client.close();
      }
    });
  }

  /// Sends a HEAD request and returns the response headers, or null on error.
  static Future<HttpHeaders?> _headRequest(String url) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    try {
      final req = await client.headUrl(Uri.parse(url));
      final resp = await req.close();
      await resp.drain<void>();
      if (resp.statusCode >= 200 && resp.statusCode < 500) return resp.headers;
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  /// Picks a MIME type from [headers] or falls back to a guess from [path].
  static String _guessContentType(HttpHeaders? headers, String path) {
    final fromServer = headers?.value(HttpHeaders.contentTypeHeader);
    if (fromServer != null && fromServer.startsWith('video/')) {
      return fromServer.split(';').first.trim();
    }
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'mkv' => 'video/x-matroska',
      'avi' => 'video/x-msvideo',
      'webm' => 'video/webm',
      'ts' => 'video/mp2t',
      _ => 'video/mp4',
    };
  }
}
