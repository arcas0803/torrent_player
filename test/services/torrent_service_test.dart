import 'package:flutter_test/flutter_test.dart';
import 'package:torrent_player/services/torrent_service.dart';

void main() {
  group('TorrentService.formatBytes', () {
    test('formats 0 as bytes', () {
      expect(TorrentService.formatBytes(0), '0 B');
    });

    test('formats small values as bytes', () {
      expect(TorrentService.formatBytes(512), '512 B');
    });

    test('formats exactly 1023 as bytes', () {
      expect(TorrentService.formatBytes(1023), '1023 B');
    });

    test('formats 1024 as 1.0 KB', () {
      expect(TorrentService.formatBytes(1024), '1.0 KB');
    });

    test('formats values in the KB range', () {
      expect(TorrentService.formatBytes(2048), '2.0 KB');
    });

    test('formats 1 MB boundary as 1.0 MB', () {
      expect(TorrentService.formatBytes(1024 * 1024), '1.0 MB');
    });

    test('formats 1 GB boundary', () {
      expect(TorrentService.formatBytes(1024 * 1024 * 1024), '1.00 GB');
    });
  });
}
