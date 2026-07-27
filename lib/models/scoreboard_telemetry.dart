sealed class ScoreboardTelemetry {
  const ScoreboardTelemetry();
}

class BatteryTelemetry extends ScoreboardTelemetry {
  final int percent;
  const BatteryTelemetry(this.percent);
}

class TrackTelemetry extends ScoreboardTelemetry {
  final String title;
  const TrackTelemetry(this.title);
}

class OkTelemetry extends ScoreboardTelemetry {
  const OkTelemetry();
}
