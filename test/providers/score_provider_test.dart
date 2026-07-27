import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_sports_scoreboard/providers/score_provider.dart';
import 'package:digital_sports_scoreboard/providers/connection_provider.dart';
import 'package:digital_sports_scoreboard/services/simulation_scoreboard_connection.dart';
import 'package:digital_sports_scoreboard/utils/commands.dart';

void main() {
  test('incrementA updates score and sends A+', () async {
    final sim = SimulationScoreboardConnection();
    await sim.connect();
    final container = ProviderContainer(overrides: [
      scoreboardConnectionProvider.overrideWithValue(sim),
    ]);
    addTearDown(container.dispose);

    await container.read(scoreProvider.notifier).incrementA();
    final state = container.read(scoreProvider);
    expect(state.teamA.score, 1);
    expect(sim.lastCommand, ScoreboardCommands.aPlus);
  });
}
