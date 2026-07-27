import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/widgets/connection_lost_dialog.dart';

void main() {
  testWidgets('finds Reconnect', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  ConnectionLostDialog.show(
                    context,
                    onReconnect: () {},
                    onUseSimulation: () {},
                  );
                },
                child: const Text('Show dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Reconnect'), findsOneWidget);
    expect(find.text('Use Simulation'), findsOneWidget);
  });
}
