import 'dart:async';

import '../models/bt_device.dart';
import '../models/scoreboard_telemetry.dart';
import '../utils/status_parser.dart';
import 'bluetooth_exception.dart';
import 'bluetooth_service.dart';
import 'scoreboard_connection.dart';

class BluetoothScoreboardConnection implements ScoreboardConnection {
  BluetoothScoreboardConnection({BluetoothService? service})
      : _service = service ?? BluetoothService();

  final BluetoothService _service;
  final _telemetryController =
      StreamController<ScoreboardTelemetry>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  StreamSubscription<String>? _lineSubscription;
  bool _connected = false;

  @override
  Stream<ScoreboardTelemetry> get telemetry => _telemetryController.stream;

  @override
  Stream<bool> get connectionChanges => _connectionController.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<List<BtDevice>> scan({
    Duration timeout = const Duration(seconds: 5),
  }) {
    return _service.discover(timeout: timeout);
  }

  @override
  Future<void> connect({BtDevice? device}) async {
    if (device == null) {
      throw BluetoothException('Device required for Bluetooth connection');
    }

    await _service.connect(device.address);
    _connected = true;
    _connectionController.add(true);

    await _lineSubscription?.cancel();
    _lineSubscription = _service.lines.listen(
      _onLine,
      onError: (_) => unawaited(_handleDisconnect()),
      onDone: () => unawaited(_handleDisconnect()),
    );
  }

  @override
  Future<void> disconnect() async {
    if (!_connected) {
      await _service.disconnect();
      return;
    }

    _connected = false;
    await _lineSubscription?.cancel();
    _lineSubscription = null;
    await _service.disconnect();
    _connectionController.add(false);
  }

  @override
  Future<void> send(String command) async {
    await _service.sendCommand(command);
  }

  void _onLine(String line) {
    final telemetry = StatusParser.parseLine(line);
    if (telemetry != null && !_telemetryController.isClosed) {
      _telemetryController.add(telemetry);
    }
  }

  Future<void> _handleDisconnect() async {
    if (!_connected) {
      return;
    }

    _connected = false;
    await _lineSubscription?.cancel();
    _lineSubscription = null;
    await _service.disconnect();

    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
  }

  void dispose() {
    unawaited(disconnect());
    _telemetryController.close();
    _connectionController.close();
    _service.dispose();
  }
}
