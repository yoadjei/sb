import '../models/match_record.dart';

class CsvExport {
  static String fromMatches(List<MatchRecord> matches) {
    final buffer = StringBuffer(
      'id,playedAt,teamAName,teamBName,scoreA,scoreB,winner,durationSeconds\n',
    );
    for (final m in matches) {
      buffer.writeln(
        '${m.id},${m.playedAt.toIso8601String()},${_esc(m.teamAName)},${_esc(m.teamBName)},${m.scoreA},${m.scoreB},${_esc(m.winner)},${m.durationSeconds}',
      );
    }
    return buffer.toString();
  }

  static String _esc(String value) {
    if (value.contains(',') || value.contains('"')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
