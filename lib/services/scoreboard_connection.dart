import '../models/bt_device.dart';
import '../models/scoreboard_telemetry.dart';

abstract class ScoreboardConnection {
  Stream<ScoreboardTelemetry> get telemetry;
  Stream<bool> get connectionChanges;
  bool get isConnected;

  Future<void> connect({BtDevice? device});
  Future<void> disconnect();
  Future<void> send(String command);
  Future<List<BtDevice>> scan({Duration timeout = const Duration(seconds: 5)});
}
