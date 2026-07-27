import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/models/match_record.dart';

void main() {
  test('MatchRecord round-trips through JSON', () {
    final record = MatchRecord(
      id: 'abc',
      playedAt: DateTime.utc(2026, 7, 26, 18, 0),
      teamAName: 'Man Utd',
      teamBName: 'Chelsea',
      scoreA: 12,
      scoreB: 8,
      winner: 'Man Utd',
      durationSeconds: 5400,
    );
    final copy = MatchRecord.fromJson(record.toJson());
    expect(copy.id, record.id);
    expect(copy.scoreA, 12);
    expect(copy.winner, 'Man Utd');
    expect(copy.durationSeconds, 5400);
  });
}
