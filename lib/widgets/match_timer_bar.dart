import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/colors.dart';
import '../themes/stadium_style.dart';

class MatchTimerBar extends StatelessWidget {
  const MatchTimerBar({
    super.key,
    required this.label,
    required this.running,
    this.onTap,
  });

  final String label;
  final bool running;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = StadiumStyle.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: style.cardBorder),
            color: style.card,
          ),
          child: Row(
            children: [
              Icon(
                running ? Icons.pause_circle_outline : Icons.timer_outlined,
                color: running ? StadiumColors.accent : style.muted,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Match Timer',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: style.body,
                ),
              ),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.robotoMono(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: running ? StadiumColors.accent : style.title,
                  letterSpacing: 1.2,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: style.muted,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
