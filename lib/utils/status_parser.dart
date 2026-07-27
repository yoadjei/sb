import '../models/scoreboard_telemetry.dart';

class StatusParser {
  static ScoreboardTelemetry? parseLine(String raw) {
    final line = raw.trim();
    if (line.isEmpty) return null;
    if (line == 'OK') return const OkTelemetry();
    if (line.startsWith('BAT:')) {
      final value = int.tryParse(line.substring(4).trim());
      if (value == null) return null;
      return BatteryTelemetry(value.clamp(0, 100));
    }
    if (line.startsWith('TRACK:')) {
      final title = line.substring(6).trim();
      if (title.isEmpty) return null;
      return TrackTelemetry(title);
    }
    return null;
  }
}
