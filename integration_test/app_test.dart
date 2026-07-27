import 'package:digital_sports_scoreboard/app.dart';
import 'package:digital_sports_scoreboard/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('operator can open simulation dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const DigitalSportsScoreboardApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    if (find.text('Continue to Simulation').evaluate().isNotEmpty) {
      await tester.tap(find.text('Continue to Simulation'));
      await tester.pumpAndSettle();
    } else if (find.text('Continue').evaluate().isNotEmpty) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Enter Simulation Mode'), findsOneWidget);
    await tester.tap(find.text('Enter Simulation Mode'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Start Match'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });
}
