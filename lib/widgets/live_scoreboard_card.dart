import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/team.dart';
import '../themes/app_theme.dart';
import '../themes/colors.dart';
import '../themes/stadium_style.dart';

class LiveScoreboardCard extends StatelessWidget {
  const LiveScoreboardCard({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.timerLabel,
    this.matchActive = false,
    this.animationsEnabled = true,
  });

  final Team teamA;
  final Team teamB;
  final String timerLabel;
  final bool matchActive;
  final bool animationsEnabled;

  @override
  Widget build(BuildContext context) {
    final style = StadiumStyle.of(context);
    final scoreStyle =
        Theme.of(context).extension<ScoreDisplayTheme>()?.scoreStyle ??
            const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 48,
              fontWeight: FontWeight.w700,
            );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        final scoreGap = compact ? 12.0 : 48.0;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: style.card,
            gradient: style.isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      StadiumColors.navyMid.withValues(alpha: 0.95),
                      StadiumColors.navy,
                    ],
                  )
                : null,
            border: Border.all(color: style.cardBorder),
            boxShadow: [
              BoxShadow(
                color: StadiumColors.accent.withValues(alpha: style.isDark ? 0.08 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 20, 20, compact ? 14 : 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      matchActive ? Icons.circle : Icons.circle_outlined,
                      size: 10,
                      color: matchActive ? StadiumColors.accent : style.muted,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        matchActive ? 'LIVE MATCH' : 'SCOREBOARD',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: matchActive ? StadiumColors.accent : style.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: style.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timerLabel,
                      style: GoogleFonts.robotoMono(
                        fontSize: 13,
                        color: style.body,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _TeamColumn(
                        team: teamA,
                        align: CrossAxisAlignment.start,
                        style: style,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'VS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: compact ? 14 : 18,
                          fontWeight: FontWeight.w800,
                          color: style.muted.withValues(alpha: 0.6),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _TeamColumn(
                        team: teamB,
                        align: CrossAxisAlignment.end,
                        style: style,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _AnimatedScore(
                        score: teamA.score,
                        color: teamA.color,
                        style: scoreStyle,
                        align: TextAlign.start,
                        animationsEnabled: animationsEnabled,
                        compact: compact,
                      ),
                    ),
                    SizedBox(width: scoreGap),
                    Expanded(
                      child: _AnimatedScore(
                        score: teamB.score,
                        color: teamB.color,
                        style: scoreStyle,
                        align: TextAlign.end,
                        animationsEnabled: animationsEnabled,
                        compact: compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({
    required this.team,
    required this.align,
    required this.style,
  });

  final Team team;
  final CrossAxisAlignment align;
  final StadiumStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: team.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: team.color.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          team.name,
          textAlign: align == CrossAxisAlignment.end ? TextAlign.right : TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: style.title,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _AnimatedScore extends StatelessWidget {
  const _AnimatedScore({
    required this.score,
    required this.color,
    required this.style,
    required this.align,
    required this.animationsEnabled,
    this.compact = false,
  });

  final int score;
  final Color color;
  final TextStyle style;
  final TextAlign align;
  final bool animationsEnabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      '$score',
      textAlign: align,
      style: style.copyWith(
        color: color,
        fontSize: compact ? (style.fontSize ?? 48) * 0.85 : style.fontSize,
      ),
    );

    if (!animationsEnabled) {
      return text;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(score),
        child: text,
      ),
    );
  }
}
