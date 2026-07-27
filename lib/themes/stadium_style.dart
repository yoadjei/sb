import 'package:flutter/material.dart';

import 'colors.dart';

/// Theme-aware Stadium Night / Day surface tokens.
/// Use this instead of hardcoding navy + white so light mode works.
class StadiumStyle {
  const StadiumStyle({
    required this.isDark,
    required this.scaffoldGradient,
    required this.card,
    required this.cardBorder,
    required this.title,
    required this.body,
    required this.muted,
    required this.brand,
    required this.accent,
    required this.chipBackground,
    required this.iconWell,
  });

  final bool isDark;
  final List<Color> scaffoldGradient;
  final Color card;
  final Color cardBorder;
  final Color title;
  final Color body;
  final Color muted;
  final Color brand;
  final Color accent;
  final Color chipBackground;
  final Color iconWell;

  static StadiumStyle of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return StadiumStyle(
        isDark: true,
        scaffoldGradient: const [StadiumColors.navy, StadiumColors.navyMid],
        card: Colors.white.withValues(alpha: 0.06),
        cardBorder: Colors.white.withValues(alpha: 0.10),
        title: Colors.white,
        body: Colors.white.withValues(alpha: 0.92),
        muted: Colors.white.withValues(alpha: 0.55),
        brand: StadiumColors.brand,
        accent: StadiumColors.accent,
        chipBackground: Colors.white.withValues(alpha: 0.08),
        iconWell: StadiumColors.accent.withValues(alpha: 0.15),
      );
    }

    return StadiumStyle(
      isDark: false,
      scaffoldGradient: const [
        StadiumColors.surfaceLight,
        StadiumColors.surfaceLightMid,
      ],
      card: StadiumColors.cardLight,
      cardBorder: StadiumColors.textDark.withValues(alpha: 0.08),
      title: StadiumColors.textDark,
      body: StadiumColors.textDark.withValues(alpha: 0.88),
      muted: StadiumColors.textMutedLight,
      brand: StadiumColors.brand,
      accent: StadiumColors.accent,
      chipBackground: StadiumColors.textDark.withValues(alpha: 0.05),
      iconWell: StadiumColors.accent.withValues(alpha: 0.12),
    );
  }
}
