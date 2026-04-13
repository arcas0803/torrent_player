import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Holds information about an available GitHub release.
class UpdateInfo {
  final String version;
  final String downloadUrl;

  const UpdateInfo({required this.version, required this.downloadUrl});
}

/// Queries the GitHub Releases API and compares with the installed version.
class UpdateService {
  static const _apiUrl =
      'https://api.github.com/repos/arcas0803/torrent_player/releases/latest';

  /// Returns [UpdateInfo] if a newer release is available, otherwise `null`.
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final response = await http
          .get(
            Uri.parse(_apiUrl),
            headers: {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = (data['tag_name'] as String? ?? '').replaceFirst(
        RegExp(r'^v'),
        '',
      );
      final downloadUrl = data['html_url'] as String? ?? '';

      if (tagName.isNotEmpty && _isNewer(tagName, packageInfo.version)) {
        return UpdateInfo(version: tagName, downloadUrl: downloadUrl);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static bool _isNewer(String remote, String local) {
    final r = _parse(remote);
    final l = _parse(local);
    for (int i = 0; i < r.length && i < l.length; i++) {
      if (r[i] > l[i]) return true;
      if (r[i] < l[i]) return false;
    }
    return r.length > l.length;
  }

  @visibleForTesting
  static bool isNewer(String remote, String local) => _isNewer(remote, local);

  static List<int> _parse(String v) =>
      v.split('.').map((s) => int.tryParse(s) ?? 0).toList();
}
