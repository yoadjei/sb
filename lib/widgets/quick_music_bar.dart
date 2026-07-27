import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/colors.dart';

class QuickMusicBar extends StatelessWidget {
  const QuickMusicBar({
    super.key,
    required this.playing,
    required this.volume,
    required this.onPlayPause,
    required this.onNext,
    required this.onVolumeDown,
    required this.onVolumeUp,
    this.muted = false,
  });

  final bool playing;
  final bool muted;
  final int volume;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onVolumeDown;
  final VoidCallback onVolumeUp;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: StadiumColors.navy.withValues(alpha: 0.6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              _ControlButton(
                icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                label: playing ? 'Pause' : 'Play',
                showLabel: !compact,
                highlighted: true,
                onPressed: onPlayPause,
              ),
              const SizedBox(width: 8),
              _ControlButton(
                icon: Icons.skip_next_rounded,
                label: 'Next',
                showLabel: !compact,
                onPressed: onNext,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      muted ? Icons.volume_off_rounded : Icons.volume_down_rounded,
                      color: Colors.white54,
                      size: 18,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: SliderComponentShape.noOverlay,
                          activeTrackColor: StadiumColors.accent,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: StadiumColors.accent,
                        ),
                        child: Slider(
                          value: volume.clamp(0, 30).toDouble(),
                          min: 0,
                          max: 30,
                          onChanged: null,
                        ),
                      ),
                    ),
                    _IconTap(
                      icon: Icons.remove_rounded,
                      onPressed: onVolumeDown,
                    ),
                    Text(
                      '$volume',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    _IconTap(
                      icon: Icons.add_rounded,
                      onPressed: onVolumeUp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.highlighted = false,
    this.showLabel = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool highlighted;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted
          ? StadiumColors.accent.withValues(alpha: 0.18)
          : Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? 14 : 10,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: highlighted ? StadiumColors.accent : Colors.white70,
                size: 22,
              ),
              if (showLabel) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: highlighted ? StadiumColors.accent : Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
      icon: Icon(icon, color: Colors.white70, size: 18),
    );
  }
}
