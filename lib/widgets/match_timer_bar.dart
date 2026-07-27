import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/colors.dart';

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            color: Colors.white.withValues(alpha: 0.03),
          ),
          child: Row(
            children: [
              Icon(
                running ? Icons.pause_circle_outline : Icons.timer_outlined,
                color: running ? StadiumColors.accent : Colors.white54,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Match Timer',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.robotoMono(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: running ? StadiumColors.accent : Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white38,
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
