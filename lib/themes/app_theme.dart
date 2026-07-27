import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: StadiumColors.accent,
        brightness: Brightness.light,
        primary: StadiumColors.accent,
        secondary: StadiumColors.brand,
        surface: StadiumColors.surfaceLight,
        onSurface: StadiumColors.textDark,
      ),
      scaffoldBackgroundColor: StadiumColors.surfaceLight,
    );

    return base.copyWith(
      textTheme: _uiTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: StadiumColors.textDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: StadiumColors.textDark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: StadiumColors.accent,
          foregroundColor: StadiumColors.navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: _segmentedButtonStyle(
          unselectedForeground: StadiumColors.textMutedLight,
          unselectedBackground: StadiumColors.textDark.withValues(alpha: 0.05),
        ),
      ),
      extensions: const [
        ScoreDisplayTheme(
          scoreStyle: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: StadiumColors.accent,
        brightness: Brightness.dark,
        primary: StadiumColors.accent,
        secondary: StadiumColors.brand,
        surface: StadiumColors.navyMid,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: StadiumColors.navy,
    );

    return base.copyWith(
      textTheme: _uiTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: StadiumColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: StadiumColors.navyMid,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: StadiumColors.accent,
          foregroundColor: StadiumColors.navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: _segmentedButtonStyle(
          unselectedForeground: Colors.white70,
          unselectedBackground: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      extensions: const [
        ScoreDisplayTheme(
          scoreStyle: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static ButtonStyle _segmentedButtonStyle({
    required Color unselectedForeground,
    required Color unselectedBackground,
  }) {
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return StadiumColors.navy;
        }
        return unselectedForeground;
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return StadiumColors.accent;
        }
        return unselectedBackground;
      }),
    );
  }

  static TextTheme _uiTextTheme(TextTheme base) {
    return GoogleFonts.spaceGroteskTextTheme(base);
  }
}

@immutable
class ScoreDisplayTheme extends ThemeExtension<ScoreDisplayTheme> {
  const ScoreDisplayTheme({required this.scoreStyle});

  final TextStyle scoreStyle;

  @override
  ScoreDisplayTheme copyWith({TextStyle? scoreStyle}) {
    return ScoreDisplayTheme(scoreStyle: scoreStyle ?? this.scoreStyle);
  }

  @override
  ScoreDisplayTheme lerp(ThemeExtension<ScoreDisplayTheme>? other, double t) {
    if (other is! ScoreDisplayTheme) {
      return this;
    }
    return ScoreDisplayTheme(
      scoreStyle: TextStyle.lerp(scoreStyle, other.scoreStyle, t) ?? scoreStyle,
    );
  }
}
