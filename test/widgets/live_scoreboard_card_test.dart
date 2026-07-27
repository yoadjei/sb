import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/models/team.dart';
import 'package:digital_sports_scoreboard/widgets/live_scoreboard_card.dart';

void main() {
  testWidgets('shows team names and scores', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveScoreboardCard(
            teamA: const Team(name: 'Man Utd', color: Colors.green, score: 12),
            teamB: const Team(name: 'Chelsea', color: Colors.orange, score: 8),
            timerLabel: '00:12:44',
          ),
        ),
      ),
    );

    expect(find.text('Man Utd'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('VS'), findsOneWidget);
  });
}
