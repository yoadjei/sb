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
        secondary: StadiumColors.rival,
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
        secondary: StadiumColors.rival,
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
