import 'package:flutter/material.dart';

/// Brand logo for ArenaBoard (asset generated mark).
class ArenaBoardLogo extends StatelessWidget {
  const ArenaBoardLogo({
    super.key,
    this.size = 88,
    this.showGlow = true,
  });

  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/images/arenaboard_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.22),
              color: const Color(0xFF0B1F33),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.scoreboard_rounded,
              size: size * 0.45,
              color: const Color(0xFFFFB020),
            ),
          );
        },
      ),
    );

    if (!showGlow) return image;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB020).withValues(alpha: 0.28),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: image,
    );
  }
}
