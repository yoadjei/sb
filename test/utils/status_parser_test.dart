import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/utils/status_parser.dart';
import 'package:digital_sports_scoreboard/models/scoreboard_telemetry.dart';

void main() {
  test('parses battery and track lines', () {
    final bat = StatusParser.parseLine('BAT:85');
    expect(bat, isA<BatteryTelemetry>());
    expect((bat as BatteryTelemetry).percent, 85);

    final track = StatusParser.parseLine('TRACK:Match Anthem');
    expect(track, isA<TrackTelemetry>());
    expect((track as TrackTelemetry).title, 'Match Anthem');
  });

  test('parses OK and ignores unknown', () {
    expect(StatusParser.parseLine('OK'), isA<OkTelemetry>());
    expect(StatusParser.parseLine('NOISE'), isNull);
    expect(StatusParser.parseLine(''), isNull);
  });
}
