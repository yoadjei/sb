import '../services/bluetooth_exception.dart';

/// User-facing error copy without raw exception prefixes.
String friendlyError(Object error) {
  var message = error is BluetoothException
      ? error.message.trim()
      : error.toString().trim();

  const prefixes = [
    'BluetoothException: ',
    'Exception: ',
    'Bad state: ',
  ];
  for (final prefix in prefixes) {
    if (message.startsWith(prefix)) {
      message = message.substring(prefix.length).trim();
      break;
    }
  }

  final lower = message.toLowerCase();
  if (lower.contains('not connected')) {
    return 'Not connected to the scoreboard';
  }
  if (lower.contains('bluetooth is disabled')) {
    return 'Bluetooth is off. Turn it on and try again.';
  }
  if (lower.contains('failed to connect')) {
    return 'Could not connect. Ensure the scoreboard is powered on and paired.';
  }
  if (lower.contains('discovery failed') ||
      (lower.contains('scan') && lower.contains('fail'))) {
    return 'Scan failed. Check permissions and try again.';
  }
  if (lower.contains('failed to send') || lower.contains('send command')) {
    return 'Could not send command to the scoreboard';
  }
  if (lower.contains('connection closed') || lower.contains('connection lost')) {
    return 'Connection lost';
  }

  return message.isEmpty ? 'Something went wrong. Try again.' : message;
}
