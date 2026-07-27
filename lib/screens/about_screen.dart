import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/colors.dart';
import '../widgets/stadium_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const appVersion = '1.0';

  @override
  Widget build(BuildContext context) {
    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('About'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    StadiumColors.accent.withValues(alpha: 0.35),
                    StadiumColors.navyMid,
                  ],
                ),
                border: Border.all(
                  color: StadiumColors.accent.withValues(alpha: 0.4),
                ),
              ),
              child: Center(
                child: Text(
                  'DSS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: StadiumColors.accent,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Digital Sports Scoreboard',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bluetooth operator console for ESP32 sports scoreboards',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: Colors.white54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _InfoRow(label: 'Developed by', value: ''),
            const SizedBox(height: 12),
            _InfoRow(label: 'University', value: ''),
            const SizedBox(height: 12),
            _InfoRow(label: 'Version', value: appVersion),
            const SizedBox(height: 32),
            Text(
              'Stadium Night Edition',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                color: StadiumColors.accent.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
          const Spacer(),
          Text(
            value.isEmpty ? '—' : value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
