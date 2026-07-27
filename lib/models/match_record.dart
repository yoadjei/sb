class MatchRecord {
  final String id;
  final DateTime playedAt;
  final String teamAName;
  final String teamBName;
  final int scoreA;
  final int scoreB;
  final String winner;
  final int durationSeconds;

  const MatchRecord({
    required this.id,
    required this.playedAt,
    required this.teamAName,
    required this.teamBName,
    required this.scoreA,
    required this.scoreB,
    required this.winner,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'playedAt': playedAt.toIso8601String(),
        'teamAName': teamAName,
        'teamBName': teamBName,
        'scoreA': scoreA,
        'scoreB': scoreB,
        'winner': winner,
        'durationSeconds': durationSeconds,
      };

  factory MatchRecord.fromJson(Map<String, dynamic> json) {
    return MatchRecord(
      id: json['id'] as String,
      playedAt: DateTime.parse(json['playedAt'] as String),
      teamAName: json['teamAName'] as String,
      teamBName: json['teamBName'] as String,
      scoreA: json['scoreA'] as int,
      scoreB: json['scoreB'] as int,
      winner: json['winner'] as String,
      durationSeconds: json['durationSeconds'] as int,
    );
  }
}
