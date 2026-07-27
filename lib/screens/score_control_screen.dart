import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/score_provider.dart';
import '../providers/settings_provider.dart';
import '../themes/colors.dart';
import '../themes/stadium_style.dart';
import '../widgets/live_scoreboard_card.dart';
import '../widgets/score_control_panel.dart';
import '../widgets/stadium_scaffold.dart';

class ScoreControlScreen extends ConsumerStatefulWidget {
  const ScoreControlScreen({super.key});

  @override
  ConsumerState<ScoreControlScreen> createState() => _ScoreControlScreenState();
}

class _ScoreControlScreenState extends ConsumerState<ScoreControlScreen> {
  @override
  Widget build(BuildContext context) {
    final score = ref.watch(scoreProvider);
    final settings = ref.watch(settingsProvider);

    ref.listen(scoreProvider, (previous, next) {
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

    final style = StadiumStyle.of(context);

    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Score Control'),
        backgroundColor: Colors.transparent,
        foregroundColor: style.title,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 700;
          final maxContentWidth = wide ? 960.0 : 720.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LiveScoreboardCard(
                      teamA: score.teamA,
                      teamB: score.teamB,
                      timerLabel: 'n/a',
                      matchActive: score.matchActive,
                      animationsEnabled: settings.animationsEnabled,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ADJUST SCORES',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: StadiumStyle.of(context).muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _panelA(score, settings)),
                          const SizedBox(width: 16),
                          Expanded(child: _panelB(score, settings)),
                        ],
                      )
                    else ...[
                      _panelA(score, settings),
                      const SizedBox(height: 16),
                      _panelB(score, settings),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _panelA(score, settings) {
    return ScoreControlPanel(
      teamLabel: 'TEAM A',
      teamName: score.teamA.name,
      score: score.teamA.score,
      accentColor: score.teamA.color,
      animationsEnabled: settings.animationsEnabled,
      onIncrement: () => ref.read(scoreProvider.notifier).incrementA(),
      onDecrement: () => ref.read(scoreProvider.notifier).decrementA(),
    );
  }

  Widget _panelB(score, settings) {
    return ScoreControlPanel(
      teamLabel: 'TEAM B',
      teamName: score.teamB.name,
      score: score.teamB.score,
      accentColor: score.teamB.color,
      animationsEnabled: settings.animationsEnabled,
      onIncrement: () => ref.read(scoreProvider.notifier).incrementB(),
      onDecrement: () => ref.read(scoreProvider.notifier).decrementB(),
    );
  }
}
