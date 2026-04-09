import 'package:flutter_test/flutter_test.dart';
import 'package:torrent_player/pages/player_page.dart';
import 'package:torrent_player/services/torrent_service.dart';

void main() {
  test('PlayerArgs stores streamUrl and torrentId', () {
    const args = PlayerArgs(
      streamUrl: 'http://localhost/video.mp4',
      torrentId: 42,
    );
    expect(args.streamUrl, 'http://localhost/video.mp4');
    expect(args.torrentId, 42);
  });

  test('TorrentService.formatBytes returns human-readable units', () {
    expect(TorrentService.formatBytes(500), '500 B');
    expect(TorrentService.formatBytes(1536), '1.5 KB');
    expect(TorrentService.formatBytes(2 * 1024 * 1024), '2.0 MB');
    expect(TorrentService.formatBytes(3 * 1024 * 1024 * 1024), '3.00 GB');
  });
}
