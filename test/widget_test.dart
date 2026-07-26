import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:digital_sports_scoreboard/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DigitalSportsScoreboardApp()),
    );

    expect(find.text('DSS'), findsOneWidget);
  });
}
