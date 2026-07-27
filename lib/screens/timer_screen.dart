import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/timer_provider.dart';
import '../themes/colors.dart';
import '../themes/stadium_style.dart';
import '../utils/formatters.dart';
import '../widgets/stadium_scaffold.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  static const _defaultCountdown = Duration(minutes: 10);
  late final TextEditingController _countdownController;
  bool _countdownInitialized = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _countdownController = TextEditingController(text: '10:00');
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);

    if (!_countdownInitialized && timer.mode == TimerMode.countUp) {
      _countdownInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.setCountdown(_defaultCountdown);
      });
    }

    final style = StadiumStyle.of(context);

    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Match Timer'),
        backgroundColor: Colors.transparent,
        foregroundColor: style.title,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ModeSelector(
              mode: timer.mode,
              onCountUp: () {
                HapticFeedback.selectionClick();
                setState(() => _hasStarted = false);
                notifier.setMode(TimerMode.countUp);
              },
              onCountdown: () {
                HapticFeedback.selectionClick();
                setState(() => _hasStarted = false);
                final parsed = _parseCountdown(_countdownController.text);
                notifier.setCountdown(parsed ?? _defaultCountdown);
              },
            ),
            if (timer.mode == TimerMode.countdown) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _countdownController,
                enabled: !timer.running,
                style: GoogleFonts.robotoMono(
                  color: style.title,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Countdown target (mm:ss)',
                  labelStyle: GoogleFonts.spaceGrotesk(color: style.muted),
                  filled: true,
                  fillColor: style.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: style.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: style.cardBorder),
                  ),
                ),
                onSubmitted: (value) {
                  final parsed = _parseCountdown(value);
                  if (parsed != null) {
                    notifier.setCountdown(parsed);
                  }
                },
              ),
            ],
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: style.card,
                border: Border.all(
                  color: timer.running
                      ? StadiumColors.accent.withValues(alpha: 0.4)
                      : style.cardBorder,
                ),
                boxShadow: timer.running
                    ? [
                        BoxShadow(
                          color: StadiumColors.accent.withValues(alpha: 0.15),
                          blurRadius: 24,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                Formatters.formatDuration(timer.duration),
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  color: timer.mode == TimerMode.countdown &&
                          timer.duration.inSeconds <= 60 &&
                          timer.duration.inSeconds > 0
                      ? StadiumColors.rival
                      : StadiumColors.accent,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              timer.running
                  ? 'RUNNING'
                  : timer.duration == Duration.zero &&
                          timer.mode == TimerMode.countdown
                      ? 'TIME UP'
                      : 'READY',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: style.muted,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                if (timer.running)
                  _TimerAction(
                    label: 'Pause',
                    icon: Icons.pause_rounded,
                    color: style.body,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      notifier.pause();
                    },
                  )
                else if (_hasStarted)
                  _TimerAction(
                    label: 'Resume',
                    icon: Icons.play_arrow_rounded,
                    color: StadiumColors.accent,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      notifier.resume();
                    },
                  )
                else
                  _TimerAction(
                    label: 'Start',
                    icon: Icons.play_arrow_rounded,
                    color: StadiumColors.accent,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _hasStarted = true);
                      notifier.start();
                    },
                  ),
                _TimerAction(
                  label: 'Reset',
                  icon: Icons.restart_alt_rounded,
                  color: StadiumColors.rival,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _hasStarted = false);
                    notifier.reset();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Duration? _parseCountdown(String input) {
    final trimmed = input.trim();
    final parts = trimmed.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]);
      final seconds = int.tryParse(parts[1]);
      if (minutes != null &&
          seconds != null &&
          minutes >= 0 &&
          seconds >= 0 &&
          seconds < 60) {
        return Duration(minutes: minutes, seconds: seconds);
      }
    }
    return null;
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.mode,
    required this.onCountUp,
    required this.onCountdown,
  });

  final TimerMode mode;
  final VoidCallback onCountUp;
  final VoidCallback onCountdown;

  @override
  Widget build(BuildContext context) {
    final style = StadiumStyle.of(context);
    return SegmentedButton<TimerMode>(
      segments: const [
        ButtonSegment(
          value: TimerMode.countUp,
          label: Text('Count Up'),
          icon: Icon(Icons.trending_up_rounded, size: 18),
        ),
        ButtonSegment(
          value: TimerMode.countdown,
          label: Text('Countdown'),
          icon: Icon(Icons.hourglass_bottom_rounded, size: 18),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) {
        if (selection.first == TimerMode.countUp) {
          onCountUp();
        } else {
          onCountdown();
        }
      },
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return StadiumColors.navy;
          }
          return style.body;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return StadiumColors.accent;
          }
          return style.chipBackground;
        }),
      ),
    );
  }
}

class _TimerAction extends StatelessWidget {
  const _TimerAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
