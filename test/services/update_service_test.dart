import 'package:flutter_test/flutter_test.dart';
import 'package:torrent_player/services/update_service.dart';

void main() {
  group('UpdateService.isNewer', () {
    test('returns true when remote major is greater', () {
      expect(UpdateService.isNewer('2.0.0', '1.0.0'), isTrue);
    });

    test('returns true when remote minor is greater', () {
      expect(UpdateService.isNewer('1.4.0', '1.3.0'), isTrue);
    });

    test('returns true when remote patch is greater', () {
      expect(UpdateService.isNewer('1.3.1', '1.3.0'), isTrue);
    });

    test('returns false when versions are equal', () {
      expect(UpdateService.isNewer('1.4.0', '1.4.0'), isFalse);
    });

    test('returns false when remote is older', () {
      expect(UpdateService.isNewer('1.2.0', '1.4.0'), isFalse);
    });

    test('returns false when remote patch is older', () {
      expect(UpdateService.isNewer('1.3.0', '1.3.1'), isFalse);
    });

    test('returns true when remote has more segments and is newer', () {
      expect(UpdateService.isNewer('1.4.0.1', '1.4.0'), isTrue);
    });

    test('returns false when remote has fewer segments and equal prefix', () {
      expect(UpdateService.isNewer('1.4', '1.4.0'), isFalse);
    });
  });
}
