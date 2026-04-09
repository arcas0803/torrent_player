import 'package:flutter_test/flutter_test.dart';
import 'package:torrent_player/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Torrent Player'), findsOneWidget);
  });
}
