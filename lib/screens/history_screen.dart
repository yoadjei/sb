import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../models/match_record.dart';
import '../providers/history_provider.dart';
import '../themes/colors.dart';
import '../utils/formatters.dart';
import '../widgets/stadium_scaffold.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    ref.listen(historyProvider, (previous, next) {
      final error = next.lastError;
      if (error == null || error == previous?.lastError) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: StadiumColors.rival,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    });

    final matches = history.filteredMatches;

    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Match History'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          if (matches.isNotEmpty)
            IconButton(
              tooltip: 'Export CSV',
              onPressed: () => _exportCsv(context),
              icon: const Icon(Icons.download_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(historyProvider.notifier).setSearchQuery(value),
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search teams…',
                hintStyle: GoogleFonts.spaceGrotesk(color: Colors.white38),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: matches.isEmpty
                ? _EmptyHistory(hasSearch: history.searchQuery.isNotEmpty)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final match = matches[index];
                      return _MatchTile(
                        match: match,
                        onShare: () => _shareMatch(match),
                        onDelete: () => _confirmDelete(match),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareMatch(MatchRecord match) async {
    HapticFeedback.lightImpact();
    try {
      await Share.share(Formatters.formatMatchSummary(match));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share failed: $error'),
          backgroundColor: StadiumColors.rival,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    HapticFeedback.lightImpact();
    try {
      final csv = ref.read(historyProvider.notifier).exportCsv();
      await Share.share(csv, subject: 'Match History CSV');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $error'),
          backgroundColor: StadiumColors.rival,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(MatchRecord match) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StadiumColors.navyMid,
        title: Text(
          'Delete Match?',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '${match.teamAName} vs ${match.teamBName} will be removed from history.',
          style: GoogleFonts.spaceGrotesk(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: StadiumColors.rival,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      await ref.read(historyProvider.notifier).delete(match.id);
    }
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.hasSearch});

  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off_rounded : Icons.history_rounded,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No matches found' : 'No match history yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try a different search term'
                  : 'End a match from the dashboard to record results',
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

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.match,
    required this.onShare,
    required this.onDelete,
  });

  final MatchRecord match;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final winner = Formatters.winnerLabel(match);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                Formatters.formatDateShort(match.playedAt),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
              const Spacer(),
              Text(
                Formatters.formatDuration(
                  Duration(seconds: match.durationSeconds),
                ),
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  color: StadiumColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${match.teamAName}  ${match.scoreA} – ${match.scoreB}  ${match.teamBName}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Winner: $winner',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: StadiumColors.accent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Share'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, size: 18, color: StadiumColors.rival),
                label: Text('Delete', style: TextStyle(color: StadiumColors.rival)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
