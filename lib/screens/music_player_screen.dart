import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../animations/fade_page_route.dart';
import '../models/connection_status.dart';
import '../providers/connection_provider.dart';
import '../providers/music_provider.dart';
import '../themes/colors.dart';
import '../themes/stadium_style.dart';
import '../widgets/stadium_scaffold.dart';
import 'music_library_screen.dart';

class MusicPlayerScreen extends ConsumerStatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final music = ref.watch(musicProvider);
    final connection = ref.watch(connectionProvider);

    ref.listen(musicProvider, (previous, next) {
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

    final title = music.currentTitle?.trim().isNotEmpty == true
        ? music.currentTitle!
        : 'Nothing playing';

    final style = StadiumStyle.of(context);

    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Music Player'),
        backgroundColor: Colors.transparent,
        foregroundColor: style.title,
        actions: [
          IconButton(
            tooltip: 'Library',
            onPressed: () {
              Navigator.of(context).push(
                FadePageRoute(page: const MusicLibraryScreen()),
              );
            },
            icon: const Icon(Icons.queue_music_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            _BtStatusChip(status: connection),
            const SizedBox(height: 28),
            _ArtworkPlaceholder(playing: music.playing),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: style.title,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              music.playing ? 'NOW PLAYING' : 'PAUSED',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                color: music.playing ? StadiumColors.accent : style.muted,
              ),
            ),
            const SizedBox(height: 32),
            _VolumeSection(
              volume: music.volume,
              muted: music.muted,
              style: style,
              onVolumeDown: () => ref.read(musicProvider.notifier).volumeDown(),
              onVolumeUp: () => ref.read(musicProvider.notifier).volumeUp(),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ModeToggle(
                  icon: Icons.shuffle_rounded,
                  active: music.shuffle,
                  style: style,
                  onTap: () => ref.read(musicProvider.notifier).toggleShuffle(),
                ),
                const SizedBox(width: 12),
                _TransportButton(
                  icon: Icons.skip_previous_rounded,
                  size: 48,
                  style: style,
                  onTap: () => ref.read(musicProvider.notifier).previous(),
                ),
                const SizedBox(width: 16),
                _PlayPauseButton(
                  playing: music.playing,
                  onTap: () {
                    final notifier = ref.read(musicProvider.notifier);
                    if (music.playing) {
                      notifier.pause();
                    } else {
                      notifier.play();
                    }
                  },
                ),
                const SizedBox(width: 16),
                _TransportButton(
                  icon: Icons.skip_next_rounded,
                  size: 48,
                  style: style,
                  onTap: () => ref.read(musicProvider.notifier).next(),
                ),
                const SizedBox(width: 12),
                _ModeToggle(
                  icon: Icons.repeat_rounded,
                  active: music.repeat,
                  style: style,
                  onTap: () => ref.read(musicProvider.notifier).toggleRepeat(),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _TransportButton(
              icon: music.muted ? Icons.volume_off_rounded : Icons.volume_mute_rounded,
              label: music.muted ? 'Unmute' : 'Mute',
              size: 40,
              style: style,
              onTap: () {
                final notifier = ref.read(musicProvider.notifier);
                if (music.muted) {
                  notifier.unmute();
                } else {
                  notifier.mute();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BtStatusChip extends StatelessWidget {
  const _BtStatusChip({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final style = StadiumStyle.of(context);
    final isSimulation = status.mode == ConnectionMode.simulation;
    final isConnected = status.mode == ConnectionMode.connected;
    final label = isSimulation
        ? 'Simulation Mode'
        : isConnected
            ? 'Bluetooth Connected'
            : 'Offline: commands may fail';
    final color = isSimulation || isConnected
        ? StadiumColors.accent
        : style.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSimulation
                ? Icons.smart_toy_outlined
                : isConnected
                    ? Icons.bluetooth_connected_rounded
                    : Icons.bluetooth_disabled_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder({required this.playing});

  final bool playing;

  @override
  Widget build(BuildContext context) {
    final style = StadiumStyle.of(context);
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: style.iconWell,
        gradient: style.isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  StadiumColors.accent.withValues(alpha: playing ? 0.35 : 0.15),
                  StadiumColors.navyMid,
                  StadiumColors.navy,
                ],
              )
            : null,
        border: Border.all(
          color: playing
              ? StadiumColors.accent.withValues(alpha: 0.5)
              : style.cardBorder,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: StadiumColors.accent.withValues(alpha: playing ? 0.2 : 0.05),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(
        playing ? Icons.graphic_eq_rounded : Icons.album_rounded,
        size: 80,
        color: playing ? StadiumColors.accent : style.muted,
      ),
    );
  }
}

class _VolumeSection extends StatelessWidget {
  const _VolumeSection({
    required this.volume,
    required this.muted,
    required this.style,
    required this.onVolumeDown,
    required this.onVolumeUp,
  });

  final int volume;
  final bool muted;
  final StadiumStyle style;
  final VoidCallback onVolumeDown;
  final VoidCallback onVolumeUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: style.muted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: volume / 30,
                  minHeight: 6,
                  backgroundColor: style.chipBackground,
                  color: muted ? style.muted : StadiumColors.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$volume',
              style: GoogleFonts.robotoMono(
                fontSize: 14,
                color: style.body,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onVolumeDown();
              },
              icon: Icon(Icons.remove_circle_outline, color: style.body),
            ),
            Text(
              'VOLUME',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: style.muted,
              ),
            ),
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onVolumeUp();
              },
              icon: Icon(Icons.add_circle_outline, color: style.body),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.playing, required this.onTap});

  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StadiumColors.accent,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: StadiumColors.accent.withValues(alpha: 0.4),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: SizedBox(
          width: 72,
          height: 72,
          child: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: StadiumColors.navy,
            size: 36,
          ),
        ),
      ),
    );
  }
}

class _TransportButton extends StatelessWidget {
  const _TransportButton({
    required this.icon,
    required this.onTap,
    required this.style,
    this.size = 44,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final StadiumStyle style;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: style.chipBackground,
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: style.title, size: size * 0.55),
        ),
      ),
    );

    if (label == null) return button;

    return Column(
      children: [
        button,
        const SizedBox(height: 6),
        Text(
          label!,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: style.muted,
          ),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.icon,
    required this.active,
    required this.style,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final StadiumStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? StadiumColors.accent.withValues(alpha: 0.2)
          : style.chipBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: active ? StadiumColors.accent : style.muted,
            size: 22,
          ),
        ),
      ),
    );
  }
}
