import 'package:digital_sports_scoreboard/app.dart';
import 'package:digital_sports_scoreboard/models/app_settings.dart';
import 'package:digital_sports_scoreboard/providers/settings_provider.dart';
import 'package:digital_sports_scoreboard/themes/stadium_style.dart';
import 'package:digital_sports_scoreboard/widgets/stadium_scaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End to end style flow tests (widget harness, no real Bluetooth).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpApp(
    WidgetTester tester, {
    ThemePreference theme = ThemePreference.system,
  }) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await tester.binding.setSurfaceSize(const Size(1200, 1600));

    SharedPreferences.setMockInitialValues({
      'settings.theme': theme.index,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const DigitalSportsScoreboardApp(),
      ),
    );
  }

  Future<void> finish(WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = null;
    await tester.binding.setSurfaceSize(null);
  }

  Future<void> advanceSplash(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> enterSimulation(WidgetTester tester) async {
    expect(find.text('Continue to Simulation'), findsOneWidget);
    await tester.tap(find.text('Continue to Simulation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Enter Simulation Mode'), findsOneWidget);
    await tester.tap(find.text('Enter Simulation Mode'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
  }

  testWidgets('splash shows brand mark then preview continue', (tester) async {
    await pumpApp(tester);
    await tester.pump();

    expect(find.text('ArenaBoard'), findsOneWidget);

    await advanceSplash(tester);

    expect(find.text('Preview Mode'), findsOneWidget);
    expect(find.text('Continue to Simulation'), findsOneWidget);
    expect(find.textContaining('HC-05'), findsNothing);
    expect(find.textContaining('—'), findsNothing);
    await finish(tester);
  });

  testWidgets('simulation path reaches dashboard hub', (tester) async {
    await pumpApp(tester);
    await advanceSplash(tester);
    await enterSimulation(tester);

    expect(find.byType(DssLogoMark), findsOneWidget);
    expect(find.text('Start Match'), findsOneWidget);
    expect(find.text('Score'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('light theme applies light stadium surfaces on settings', (tester) async {
    await pumpApp(tester, theme: ThemePreference.light);
    await advanceSplash(tester);
    await enterSimulation(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Light'), findsOneWidget);

    final context = tester.element(find.text('Light'));
    final style = StadiumStyle.of(context);
    expect(style.isDark, isFalse);
    expect(style.title, isNot(equals(Colors.white)));
    await finish(tester);
  });

  testWidgets('score control screen opens from dashboard hub', (tester) async {
    await pumpApp(tester);
    await advanceSplash(tester);
    await enterSimulation(tester);

    final scoreTile = find.text('Score');
    await tester.ensureVisible(scoreTile);
    await tester.tap(scoreTile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Score Control'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsWidgets);
    expect(find.byIcon(Icons.remove_rounded), findsWidgets);
    await finish(tester);
  });
}
