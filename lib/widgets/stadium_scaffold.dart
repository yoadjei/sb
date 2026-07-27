import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/colors.dart';

/// Gradient-backed scaffold helper for Stadium Night screens.
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
    return Scaffold(
      extendBodyBehindAppBar: appBar != null,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [StadiumColors.navy, StadiumColors.navyMid],
          ),
        ),
        child: SafeArea(
          child: body,
        ),
      ),
    );
  }
}

/// Lightweight app bar title used across hub and stub screens.
class StadiumAppBarTitle extends StatelessWidget {
  const StadiumAppBarTitle(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: 0.5,
      ),
    );
  }
}
