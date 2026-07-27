import 'bt_device.dart';

enum ConnectionMode { disconnected, scanning, connecting, connected, simulation }

class ConnectionStatus {
  final ConnectionMode mode;
  final String? deviceName;
  final String? deviceAddress;
  final int? batteryPercent;
  final String? lastError;
  final List<BtDevice> discoveredDevices;

  const ConnectionStatus({
    required this.mode,
    this.deviceName,
    this.deviceAddress,
    this.batteryPercent,
    this.lastError,
    this.discoveredDevices = const [],
  });

  bool get isLive =>
      mode == ConnectionMode.connected || mode == ConnectionMode.simulation;

  ConnectionStatus copyWith({
    ConnectionMode? mode,
    String? deviceName,
    String? deviceAddress,
    int? batteryPercent,
    String? lastError,
    List<BtDevice>? discoveredDevices,
    bool clearError = false,
    bool clearDevices = false,
  }) {
    return ConnectionStatus(
      mode: mode ?? this.mode,
      deviceName: deviceName ?? this.deviceName,
      deviceAddress: deviceAddress ?? this.deviceAddress,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      lastError: clearError ? null : (lastError ?? this.lastError),
      discoveredDevices:
          clearDevices ? const [] : (discoveredDevices ?? this.discoveredDevices),
    );
  }
}
