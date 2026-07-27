import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/colors.dart';
import '../themes/stadium_style.dart';
import '../utils/app_brand.dart';
import '../widgets/arena_board_logo.dart';
import '../widgets/stadium_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final style = StadiumStyle.of(context);
    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('About'),
        backgroundColor: Colors.transparent,
        foregroundColor: style.title,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          children: [
            const ArenaBoardLogo(size: 104),
            const SizedBox(height: 24),
            Text(
              AppBrand.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: style.title,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppBrand.tagline,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: style.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _InfoRow(
              label: 'Developed by',
              value: AppBrand.developedBy,
              style: style,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Version',
              value: AppBrand.version,
              style: style,
            ),
            const SizedBox(height: 32),
            Text(
              'Stadium Night Edition',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: StadiumColors.brand.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final StadiumStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: style.card,
        border: Border.all(color: style.cardBorder),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: style.muted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: style.title,
            ),
          ),
        ],
      ),
    );
  }
}
