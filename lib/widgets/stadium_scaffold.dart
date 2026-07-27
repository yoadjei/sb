import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/stadium_style.dart';
import '../utils/app_brand.dart';
import 'arena_board_logo.dart';

/// Gradient-backed scaffold that follows light / dark theme.
class StadiumScaffold extends StatelessWidget {
  const StadiumScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final style = StadiumStyle.of(context);

    return Scaffold(
      extendBodyBehindAppBar: appBar != null,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: style.scaffoldGradient,
          ),
        ),
        child: SafeArea(
          child: body,
        ),
      ),
    );
  }
}

class StadiumAppBarTitle extends StatelessWidget {
  const StadiumAppBarTitle(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final style = StadiumStyle.of(context);
    return Text(
      label,
      style: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: 0.2,
        color: style.title,
      ),
    );
  }
}

/// Compact ArenaBoard mark for app bars.
class DssLogoMark extends StatelessWidget {
  const DssLogoMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ArenaBoardLogo(size: size, showGlow: false);
  }
}
