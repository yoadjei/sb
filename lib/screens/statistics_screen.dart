import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/match_record.dart';
import '../providers/history_provider.dart';
import '../themes/colors.dart';
import '../widgets/stadium_scaffold.dart';

class MatchStatistics {
  const MatchStatistics({
    required this.totalMatches,
    required this.highestScore,
    required this.averageScore,
    required this.winsByTeam,
  });

  final int totalMatches;
  final int highestScore;
  final double averageScore;
  final Map<String, int> winsByTeam;
}

MatchStatistics computeStatistics(List<MatchRecord> matches) {
  if (matches.isEmpty) {
    return const MatchStatistics(
      totalMatches: 0,
      highestScore: 0,
      averageScore: 0,
      winsByTeam: {},
    );
  }

  var highest = 0;
  var totalPoints = 0;
  var pointCount = 0;
  final wins = <String, int>{};

  for (final match in matches) {
    highest = [highest, match.scoreA, match.scoreB].reduce((a, b) => a > b ? a : b);
    totalPoints += match.scoreA + match.scoreB;
    pointCount += 2;

    if (match.winner == 'A') {
      wins[match.teamAName] = (wins[match.teamAName] ?? 0) + 1;
    } else if (match.winner == 'B') {
      wins[match.teamBName] = (wins[match.teamBName] ?? 0) + 1;
    } else if (match.winner == 'Draw') {
      wins['Draw'] = (wins['Draw'] ?? 0) + 1;
    }
  }

  return MatchStatistics(
    totalMatches: matches.length,
    highestScore: highest,
    averageScore: pointCount > 0 ? totalPoints / pointCount : 0,
    winsByTeam: wins,
  );
}

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final stats = computeStatistics(history.matches);

    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Statistics'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: history.matches.isEmpty
          ? _EmptyStatistics()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatCard(
                    label: 'Total Matches',
                    value: '${stats.totalMatches}',
                    icon: Icons.sports_score_rounded,
                    color: StadiumColors.accent,
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    label: 'Highest Score',
                    value: '${stats.highestScore}',
                    icon: Icons.emoji_events_rounded,
                    color: StadiumColors.rival,
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    label: 'Average Score',
                    value: stats.averageScore.toStringAsFixed(1),
                    icon: Icons.analytics_outlined,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'WINS BY TEAM',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...stats.winsByTeam.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _WinRow(name: entry.key, wins: entry.value),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _EmptyStatistics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'No statistics yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Play and end matches to build your stats',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.robotoMono(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WinRow extends StatelessWidget {
  const _WinRow({required this.name, required this.wins});

  final String name;
  final int wins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            '$wins',
            style: GoogleFonts.robotoMono(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: StadiumColors.accent,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            wins == 1 ? 'win' : 'wins',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
