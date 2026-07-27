import 'dart:async';

import '../models/bt_device.dart';
import '../models/scoreboard_telemetry.dart';
import 'scoreboard_connection.dart';

class SimulationScoreboardConnection implements ScoreboardConnection {
  SimulationScoreboardConnection();

  final _telemetryController =
      StreamController<ScoreboardTelemetry>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  bool _connected = false;
  String? lastCommand;
  String _currentTrack = 'Match Anthem';

  @override
  Stream<ScoreboardTelemetry> get telemetry => _telemetryController.stream;

  @override
  Stream<bool> get connectionChanges => _connectionController.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<List<BtDevice>> scan({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const [
      BtDevice(
        name: 'DSS-ESP32-SIM',
        address: '00:00:00:00:00:00',
      ),
    ];
  }

  @override
  Future<void> connect({BtDevice? device}) async {
    _connected = true;
    _connectionController.add(true);
    _telemetryController.add(const BatteryTelemetry(88));
    _telemetryController.add(TrackTelemetry(_currentTrack));
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _connectionController.add(false);
  }

  @override
  Future<void> send(String command) async {
    if (!_connected) {
      throw StateError('Not connected');
    }

    lastCommand = command.trim();
    _telemetryController.add(const OkTelemetry());

    if (lastCommand == 'PLAY') {
      _telemetryController.add(TrackTelemetry(_currentTrack));
    } else if (lastCommand!.startsWith('PLAYTRACK:')) {
      final trackNumber = lastCommand!.substring('PLAYTRACK:'.length);
      _currentTrack = 'Track $trackNumber';
      _telemetryController.add(TrackTelemetry(_currentTrack));
    }
  }

  void dispose() {
    _telemetryController.close();
    _connectionController.close();
  }
}
