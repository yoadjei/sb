import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/score_provider.dart';
import '../themes/colors.dart';
import '../widgets/stadium_scaffold.dart';

class TeamsScreen extends ConsumerStatefulWidget {
  const TeamsScreen({super.key});

  @override
  ConsumerState<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends ConsumerState<TeamsScreen> {
  late final TextEditingController _nameAController;
  late final TextEditingController _nameBController;
  late Color _colorA;
  late Color _colorB;

  @override
  void initState() {
    super.initState();
    final score = ref.read(scoreProvider);
    _nameAController = TextEditingController(text: score.teamA.name);
    _nameBController = TextEditingController(text: score.teamB.name);
    _colorA = score.teamA.color;
    _colorB = score.teamB.color;
  }

  @override
  void dispose() {
    _nameAController.dispose();
    _nameBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(scoreProvider, (previous, next) {
      final error = next.lastError;
      if (error == null || error == previous?.lastError) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: StadiumColors.rival,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    });

    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Teams'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TeamEditorCard(
              label: 'TEAM A',
              nameController: _nameAController,
              color: _colorA,
              accentFallback: StadiumColors.accent,
              onColorChanged: (color) => setState(() => _colorA = color),
              onSave: () => _saveTeam(isA: true),
            ),
            const SizedBox(height: 20),
            _TeamEditorCard(
              label: 'TEAM B',
              nameController: _nameBController,
              color: _colorB,
              accentFallback: StadiumColors.rival,
              onColorChanged: (color) => setState(() => _colorB = color),
              onSave: () => _saveTeam(isA: false),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTeam({required bool isA}) async {
    final name = (isA ? _nameAController : _nameBController).text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${isA ? 'Team A' : 'Team B'} name cannot be empty'),
          backgroundColor: StadiumColors.rival,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final notifier = ref.read(scoreProvider.notifier);
    if (isA) {
      notifier.setColorA(_colorA);
      await notifier.setNameA(name);
    } else {
      notifier.setColorB(_colorB);
      await notifier.setNameB(name);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isA ? 'Team A' : 'Team B'} saved'),
        backgroundColor: StadiumColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TeamEditorCard extends StatelessWidget {
  const _TeamEditorCard({
    required this.label,
    required this.nameController,
    required this.color,
    required this.accentFallback,
    required this.onColorChanged,
    required this.onSave,
  });

  final String label;
  final TextEditingController nameController;
  final Color color;
  final Color accentFallback;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final accent = color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.35),
                    StadiumColors.navyMid,
                  ],
                ),
                border: Border.all(color: accent.withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, color: accent, size: 32),
                  const SizedBox(height: 4),
                  Text(
                    'LOGO',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: 'Team name',
              labelStyle: GoogleFonts.spaceGrotesk(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'TEAM COLOR',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          BlockPicker(
            pickerColor: color,
            onColorChanged: onColorChanged,
            availableColors: const [
              StadiumColors.accent,
              StadiumColors.rival,
              Color(0xFF5B8DEF),
              Color(0xFFF4D03F),
              Color(0xFF9B59B6),
              Color(0xFFEC7063),
              Color(0xFF48C9B0),
              Color(0xFFFFFFFF),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Team'),
            style: FilledButton.styleFrom(
              backgroundColor: accentFallback,
              foregroundColor: StadiumColors.navy,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
