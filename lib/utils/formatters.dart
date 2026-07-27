import 'package:intl/intl.dart';

import '../models/match_record.dart';

class Formatters {
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  static String formatDateShort(DateTime dateTime) {
    return DateFormat.MMMd().format(dateTime);
  }

  static String formatMatchSummary(MatchRecord record) {
    final winnerLabel = switch (record.winner) {
      'A' => record.teamAName,
      'B' => record.teamBName,
      'Draw' => 'Draw',
      _ => record.winner,
    };

    return '${record.teamAName} ${record.scoreA} to ${record.scoreB} ${record.teamBName}\n'
        'Winner: $winnerLabel\n'
        'Duration: ${formatDuration(Duration(seconds: record.durationSeconds))}\n'
        'Played: ${formatDate(record.playedAt)}';
  }

  static String winnerLabel(MatchRecord record) {
    return switch (record.winner) {
      'A' => record.teamAName,
      'B' => record.teamBName,
      'Draw' => 'Draw',
      _ => record.winner,
    };
  }
}
