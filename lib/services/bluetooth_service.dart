import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../models/bt_device.dart';
import '../utils/commands.dart';
import 'bluetooth_exception.dart';

class BluetoothService {
  BluetoothService({FlutterBluetoothSerial? serial})
      : _serial = serial ?? FlutterBluetoothSerial.instance;

  final FlutterBluetoothSerial _serial;
  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _inputSubscription;
  final _lineController = StreamController<String>.broadcast();
  String _lineBuffer = '';

  Stream<String> get lines => _lineController.stream;

  bool get isConnected => _connection?.isConnected ?? false;

  Future<bool> get isEnabled async {
    final enabled = await _serial.isEnabled;
    if (enabled == null) {
      throw BluetoothException('Unable to determine Bluetooth state');
    }
    return enabled;
  }

  Future<bool> requestEnable() async {
    final result = await _serial.requestEnable();
    if (result == null) {
      throw BluetoothException('Failed to enable Bluetooth');
    }
    return result;
  }

  Future<List<BtDevice>> discover({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final enabled = await isEnabled;
    if (!enabled) {
      throw BluetoothException('Bluetooth is disabled');
    }

    final devices = <String, BtDevice>{};
    StreamSubscription<BluetoothDiscoveryResult>? subscription;
    Timer? timer;

    try {
      final completer = Completer<List<BtDevice>>();
      subscription = _serial.startDiscovery().listen(
        (result) {
          final device = result.device;
          devices[device.address] = BtDevice(
            name: _deviceName(device),
            address: device.address,
            rssi: result.rssi,
          );
        },
        onError: (Object error) {
          if (!completer.isCompleted) {
            completer.completeError(
              BluetoothException('Discovery failed: $error'),
            );
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(devices.values.toList());
          }
        },
      );

      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.complete(devices.values.toList());
        }
      });

      return await completer.future;
    } catch (error) {
      if (error is BluetoothException) {
        rethrow;
      }
      throw BluetoothException('Discovery failed: $error');
    } finally {
      timer?.cancel();
      await subscription?.cancel();
      try {
        await _serial.cancelDiscovery();
      } catch (_) {
        // Discovery may already be stopped.
      }
    }
  }

  Future<void> connect(String address) async {
    await disconnect();
    try {
      _connection = await BluetoothConnection.toAddress(address);
    } catch (error) {
      throw BluetoothException('Failed to connect to $address: $error');
    }
    _listenToInput();
  }

  Future<void> sendCommand(String command) async {
    final connection = _connection;
    if (connection == null || !connection.isConnected) {
      throw BluetoothException('Not connected');
    }

    try {
      connection.output.add(utf8.encode(ScoreboardCommands.wire(command)));
      await connection.output.allSent;
    } catch (error) {
      throw BluetoothException('Failed to send command: $error');
    }
  }

  Future<void> disconnect() async {
    await _inputSubscription?.cancel();
    _inputSubscription = null;

    final connection = _connection;
    _connection = null;
    _lineBuffer = '';

    if (connection != null) {
      try {
        await connection.close();
      } catch (_) {
        // Socket may already be closed.
      }
    }
  }

  void dispose() {
    disconnect();
    _lineController.close();
  }

  void _listenToInput() {
    final input = _connection?.input;
    if (input == null) {
      return;
    }

    _inputSubscription = input.listen(
      _onInputData,
      onError: (Object error) {
        if (!_lineController.isClosed) {
          _lineController.addError(
            BluetoothException('Connection read error: $error'),
          );
        }
      },
      onDone: () {
        unawaited(disconnect());
      },
      cancelOnError: false,
    );
  }

  void _onInputData(Uint8List data) {
    _lineBuffer += utf8.decode(data, allowMalformed: true);

    final parts = _lineBuffer.split('\n');
    _lineBuffer = parts.removeLast();

    for (final part in parts) {
      final line = part.replaceAll('\r', '').trim();
      if (line.isNotEmpty && !_lineController.isClosed) {
        _lineController.add(line);
      }
    }
  }

  String _deviceName(BluetoothDevice device) {
    final name = device.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Unknown';
  }
}
