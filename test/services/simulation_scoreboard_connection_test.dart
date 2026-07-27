import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/services/simulation_scoreboard_connection.dart';

void main() {
  late SimulationScoreboardConnection connection;

  setUp(() {
    connection = SimulationScoreboardConnection();
  });

  tearDown(() {
    connection.dispose();
  });

  test('connect, send START, disconnect lifecycle', () async {
    expect(connection.isConnected, isFalse);

    await connection.connect();
    expect(connection.isConnected, isTrue);

    await connection.send('START');
    expect(connection.lastCommand, 'START');

    await connection.disconnect();
    expect(connection.isConnected, isFalse);
  });
}
