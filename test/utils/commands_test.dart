import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/utils/commands.dart';

void main() {
  test('score and match commands are exact protocol strings', () {
    expect(ScoreboardCommands.start, 'START');
    expect(ScoreboardCommands.end, 'END');
    expect(ScoreboardCommands.reset, 'RESET');
    expect(ScoreboardCommands.aPlus, 'A+');
    expect(ScoreboardCommands.aMinus, 'A-');
    expect(ScoreboardCommands.bPlus, 'B+');
    expect(ScoreboardCommands.bMinus, 'B-');
    expect(ScoreboardCommands.audio, 'AUDIO');
  });

  test('name and track builders format payloads', () {
    expect(ScoreboardCommands.nameA('Man Utd'), 'NAMEA:Man Utd');
    expect(ScoreboardCommands.nameB('Chelsea'), 'NAMEB:Chelsea');
    expect(ScoreboardCommands.playTrack(5), 'PLAYTRACK:5');
  });

  test('wire format appends newline', () {
    expect(ScoreboardCommands.wire('START'), 'START\n');
  });
}
