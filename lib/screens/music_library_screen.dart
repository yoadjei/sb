import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/music_track.dart';
import '../providers/music_provider.dart';
import '../themes/colors.dart';
import '../widgets/stadium_scaffold.dart';

class MusicLibraryScreen extends ConsumerWidget {
  const MusicLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(musicProvider);

    ref.listen(musicProvider, (previous, next) {
      final error = next.lastError;
      if (error == null || error == previous?.lastError) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
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
        title: const StadiumAppBarTitle('Music Library'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: music.tracks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final track = music.tracks[index];
          final isCurrent = music.currentTitle == track.title && music.playing;
          return _TrackCard(
            track: track,
            isPlaying: isCurrent,
            onPlay: () async {
              HapticFeedback.lightImpact();
              await ref.read(musicProvider.notifier).playTrack(track.number);
            },
          );
        },
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.track,
    required this.isPlaying,
    required this.onPlay,
  });

  final MusicTrack track;
  final bool isPlaying;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPlaying
          ? StadiumColors.accent.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? StadiumColors.accent.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      StadiumColors.accent.withValues(alpha: 0.25),
                      StadiumColors.navyMid,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '${track.number}',
                    style: GoogleFonts.robotoMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: StadiumColors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track ${track.number}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isPlaying ? Icons.equalizer_rounded : Icons.play_circle_fill_rounded,
                color: isPlaying ? StadiumColors.accent : Colors.white54,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
