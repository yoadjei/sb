import 'package:digital_sports_scoreboard/services/bluetooth_exception.dart';
import 'package:digital_sports_scoreboard/utils/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('strips bluetooth exception prefix', () {
    expect(
      friendlyError(BluetoothException('Failed to send command: boom')),
      'Could not send command to the scoreboard',
    );
  });

  test('maps not connected bad state', () {
    expect(
      friendlyError(StateError('Not connected')),
      'Not connected to the scoreboard',
    );
  });

  test('maps connection closed', () {
    expect(
      friendlyError(BluetoothException('Connection closed')),
      'Connection lost',
    );
  });
}
