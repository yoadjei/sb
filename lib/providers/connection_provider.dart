import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bt_device.dart';
import '../models/connection_status.dart';
import '../models/scoreboard_telemetry.dart';
import '../services/bluetooth_scoreboard_connection.dart';
import '../services/scoreboard_connection.dart';
import '../services/simulation_scoreboard_connection.dart';

export '../services/scoreboard_connection.dart';

class _ConnectionInstances {
  _ConnectionInstances()
      : bluetooth = BluetoothScoreboardConnection(),
        simulation = SimulationScoreboardConnection() {
    _active = simulation;
  }

  final BluetoothScoreboardConnection bluetooth;
  final SimulationScoreboardConnection simulation;
  late ScoreboardConnection _active;

  ScoreboardConnection get active => _active;

  void useBluetooth() => _active = bluetooth;

  void useSimulation() => _active = simulation;

  void dispose() {
    bluetooth.dispose();
    simulation.dispose();
  }
}

final _connectionInstancesProvider = Provider<_ConnectionInstances>((ref) {
  final instances = _ConnectionInstances();
  instances.useSimulation();
  ref.onDispose(instances.dispose);
  return instances;
});

/// Overridable in tests; defaults to the active connection from [connectionProvider].
final scoreboardConnectionProvider = Provider<ScoreboardConnection>((ref) {
  ref.watch(connectionProvider);
  return ref.read(connectionProvider.notifier).connection;
});

final connectionProvider =
    NotifierProvider<ConnectionNotifier, ConnectionStatus>(
  ConnectionNotifier.new,
);

class ConnectionNotifier extends Notifier<ConnectionStatus> {
  StreamSubscription<ScoreboardTelemetry>? _telemetrySub;
  StreamSubscription<bool>? _connectionSub;
  BtDevice? _lastDevice;
  bool _useSimulation = false;
  bool _wasConnected = false;

  bool connectionLost = false;

  ScoreboardConnection get connection {
    final instances = ref.read(_connectionInstancesProvider);
    return _useSimulation ? instances.simulation : instances.bluetooth;
  }

  @override
  ConnectionStatus build() {
    ref.onDispose(_cancelSubscriptions);
    return const ConnectionStatus(mode: ConnectionMode.disconnected);
  }

  Future<void> startScan() async {
    connectionLost = false;
    _useSimulation = false;
    state = state.copyWith(
      mode: ConnectionMode.scanning,
      clearError: true,
      clearDevices: true,
    );

    try {
      final devices = await connection.scan();
      if (state.mode == ConnectionMode.scanning) {
        state = state.copyWith(
          mode: ConnectionMode.disconnected,
          discoveredDevices: devices,
        );
      }
    } catch (error) {
      state = state.copyWith(
        mode: ConnectionMode.disconnected,
        lastError: error.toString(),
      );
    }
  }

  Future<bool> isBluetoothEnabled() {
    final bluetooth = ref.read(_connectionInstancesProvider).bluetooth;
    return bluetooth.isBluetoothEnabled();
  }

  Future<bool> requestEnableBluetooth() {
    final bluetooth = ref.read(_connectionInstancesProvider).bluetooth;
    return bluetooth.requestEnableBluetooth();
  }

  Future<void> openBluetoothSettings() {
    final bluetooth = ref.read(_connectionInstancesProvider).bluetooth;
    return bluetooth.openBluetoothSettings();
  }

  /// Listen for adapter on/off changes (Android).
  StreamSubscription<dynamic> listenBluetoothAdapterState(
    void Function() onChanged,
  ) {
    final bluetooth = ref.read(_connectionInstancesProvider).bluetooth;
    return bluetooth.onBluetoothStateChanged.listen((_) => onChanged());
  }

  Future<void> connectDevice(BtDevice device) async {
    _useSimulation = false;
    _lastDevice = device;
    connectionLost = false;
    state = state.copyWith(
      mode: ConnectionMode.connecting,
      deviceName: device.name,
      deviceAddress: device.address,
      clearError: true,
    );

    try {
      await connection.connect(device: device);
      _wasConnected = true;
      _listenToConnection();
      state = state.copyWith(mode: ConnectionMode.connected);
    } catch (error) {
      state = state.copyWith(
        mode: ConnectionMode.disconnected,
        lastError: error.toString(),
      );
    }
  }

  Future<void> enterSimulation() async {
    _useSimulation = true;
    _lastDevice = null;
    connectionLost = false;
    state = state.copyWith(
      mode: ConnectionMode.connecting,
      clearError: true,
    );

    try {
      await connection.connect();
      _wasConnected = true;
      _listenToConnection();
      state = state.copyWith(
        mode: ConnectionMode.simulation,
        deviceName: 'Simulation',
        deviceAddress: null,
      );
    } catch (error) {
      state = state.copyWith(
        mode: ConnectionMode.disconnected,
        lastError: error.toString(),
      );
    }
  }

  Future<void> disconnect() async {
    connectionLost = false;
    _wasConnected = false;
    await _cancelSubscriptions();
    try {
      await connection.disconnect();
    } catch (error) {
      state = state.copyWith(lastError: error.toString());
    }
    state = const ConnectionStatus(mode: ConnectionMode.disconnected);
  }

  Future<void> reconnect() async {
    connectionLost = false;
    if (_useSimulation) {
      await enterSimulation();
      return;
    }
    final device = _lastDevice;
    if (device != null) {
      await connectDevice(device);
    } else {
      state = state.copyWith(
        lastError: 'No device to reconnect to',
      );
    }
  }

  void _listenToConnection() {
    unawaited(_cancelSubscriptions());

    _telemetrySub = connection.telemetry.listen((telemetry) {
      if (telemetry is BatteryTelemetry) {
        state = state.copyWith(batteryPercent: telemetry.percent);
      }
    });

    _connectionSub = connection.connectionChanges.listen((connected) {
      if (!connected && _wasConnected) {
        connectionLost = true;
        _wasConnected = false;
        state = state.copyWith(
          mode: ConnectionMode.disconnected,
          lastError: 'Connection lost',
        );
      }
    });
  }

  Future<void> _cancelSubscriptions() async {
    await _telemetrySub?.cancel();
    await _connectionSub?.cancel();
    _telemetrySub = null;
    _connectionSub = null;
  }
}
