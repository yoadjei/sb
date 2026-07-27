import 'package:digital_sports_scoreboard/themes/app_theme.dart';
import 'package:digital_sports_scoreboard/themes/colors.dart';
import 'package:digital_sports_scoreboard/themes/stadium_style.dart';
import 'package:digital_sports_scoreboard/widgets/hub_tile.dart';
import 'package:digital_sports_scoreboard/widgets/stadium_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('light stadium scaffold uses light gradient surfaces', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: StadiumScaffold(
          body: Builder(
            builder: (context) {
              final style = StadiumStyle.of(context);
              return Text(
                style.isDark ? 'dark' : 'light',
                style: TextStyle(color: style.title),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('light'), findsOneWidget);
    final style = StadiumStyle.of(
      tester.element(find.text('light')),
    );
    expect(style.isDark, isFalse);
    expect(style.scaffoldGradient.first, StadiumColors.surfaceLight);
    expect(style.title, StadiumColors.textDark);
  });

  testWidgets('dss logo mark uses brand gold color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: DssLogoMark())),
      ),
    );

    final text = tester.widget<Text>(find.text('AB'));
    expect(text.style?.color, StadiumColors.brand);
  });

  testWidgets('hub tile is readable in light mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        home: Scaffold(
          body: HubTile(
            icon: Icons.sports_score,
            label: 'Score',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Score'), findsOneWidget);
    final label = tester.widget<Text>(find.text('Score'));
    expect(label.style?.color, isNot(equals(Colors.white)));
  });
}
