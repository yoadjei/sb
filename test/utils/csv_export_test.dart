import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/models/match_record.dart';
import 'package:digital_sports_scoreboard/utils/csv_export.dart';

void main() {
  test('exports header and row', () {
    final csv = CsvExport.fromMatches([
      MatchRecord(
        id: '1',
        playedAt: DateTime.utc(2026, 7, 26, 18, 0),
        teamAName: 'A',
        teamBName: 'B',
        scoreA: 2,
        scoreB: 1,
        winner: 'A',
        durationSeconds: 60,
      ),
    ]);
    expect(csv.split('\n').first, contains('id,playedAt,teamAName'));
    expect(csv, contains('A,B,2,1,A,60'));
  });
}
