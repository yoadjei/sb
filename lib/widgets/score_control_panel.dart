import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/app_theme.dart';
import '../themes/colors.dart';

class ScoreControlPanel extends StatefulWidget {
  const ScoreControlPanel({
    super.key,
    required this.teamLabel,
    required this.teamName,
    required this.score,
    required this.accentColor,
    required this.onIncrement,
    required this.onDecrement,
    this.animationsEnabled = true,
  });

  final String teamLabel;
  final String teamName;
  final int score;
  final Color accentColor;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool animationsEnabled;

  @override
  State<ScoreControlPanel> createState() => _ScoreControlPanelState();
}

class _ScoreControlPanelState extends State<ScoreControlPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int? _lastScore;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.92,
      upperBound: 1.0,
    )..value = 1.0;
    _lastScore = widget.score;
  }

  @override
  void didUpdateWidget(ScoreControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationsEnabled &&
        widget.score != _lastScore &&
        widget.score != oldWidget.score) {
      _lastScore = widget.score;
      _pulseController.forward(from: 0.92);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scoreStyle =
        Theme.of(context).extension<ScoreDisplayTheme>()?.scoreStyle ??
            const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 48,
              fontWeight: FontWeight.w700,
            );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StadiumColors.navyMid.withValues(alpha: 0.95),
            StadiumColors.navy.withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.teamLabel,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.teamName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: widget.animationsEnabled
                ? _pulseController
                : const AlwaysStoppedAnimation(1.0),
            child: Text(
              '${widget.score}',
              style: scoreStyle.copyWith(
                fontSize: 72,
                color: widget.accentColor,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ScoreButton(
                  icon: Icons.remove_rounded,
                  label: '−',
                  color: widget.accentColor,
                  onPressed: widget.score > 0 ? widget.onDecrement : null,
                  filled: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ScoreButton(
                  icon: Icons.add_rounded,
                  label: '+',
                  color: widget.accentColor,
                  onPressed: widget.onIncrement,
                  filled: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreButton extends StatefulWidget {
  const _ScoreButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    required this.filled,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  State<_ScoreButton> createState() => _ScoreButtonState();
}

class _ScoreButtonState extends State<_ScoreButton> {
  double _scale = 1.0;

  Future<void> _handleTap() async {
    if (widget.onPressed == null) return;
    HapticFeedback.mediumImpact();
    setState(() => _scale = 0.88);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (mounted) setState(() => _scale = 1.0);
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _scale = 0.92) : null,
      onTapUp: enabled ? (_) => _handleTap() : null,
      onTapCancel: enabled ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: widget.filled
                ? widget.color.withValues(alpha: enabled ? 0.22 : 0.08)
                : Colors.white.withValues(alpha: enabled ? 0.06 : 0.03),
            border: Border.all(
              color: widget.color.withValues(alpha: enabled ? 0.5 : 0.15),
              width: widget.filled ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.robotoMono(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: enabled ? widget.color : Colors.white24,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
