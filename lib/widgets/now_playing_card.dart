import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/colors.dart';
import '../themes/stadium_style.dart';

class NowPlayingCard extends StatelessWidget {
  const NowPlayingCard({
    super.key,
    required this.title,
    required this.playing,
    this.muted = false,
  });

  final String? title;
  final bool playing;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final style = StadiumStyle.of(context);
    final displayTitle = title?.trim().isNotEmpty == true ? title! : 'Nothing playing';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: style.card,
        border: Border.all(color: style.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: style.iconWell,
              gradient: style.isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        StadiumColors.accent.withValues(alpha: 0.25),
                        StadiumColors.navyMid,
                      ],
                    )
                  : null,
            ),
            child: Icon(
              playing ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
              color: playing ? StadiumColors.accent : style.muted,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOW PLAYING',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: style.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: style.title,
                  ),
                ),
              ],
            ),
          ),
          if (muted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: StadiumColors.rival.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'MUTED',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: StadiumColors.rival,
                  letterSpacing: 1,
                ),
              ),
            )
          else if (playing)
            Icon(
              Icons.equalizer_rounded,
              color: StadiumColors.accent.withValues(alpha: 0.8),
              size: 22,
            ),
        ],
      ),
    );
  }
}
