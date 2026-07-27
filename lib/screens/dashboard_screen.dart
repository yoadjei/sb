import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../animations/fade_page_route.dart';
import '../models/app_settings.dart';
import '../models/connection_status.dart';
import '../providers/connection_provider.dart';
import '../providers/history_provider.dart';
import '../providers/music_provider.dart';
import '../providers/score_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';
import '../themes/colors.dart';
import '../utils/commands.dart';
import '../widgets/connection_banner.dart';
import '../widgets/connection_lost_dialog.dart';
import '../widgets/hub_tile.dart';
import '../widgets/live_scoreboard_card.dart';
import '../widgets/match_timer_bar.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/quick_music_bar.dart';
import '../widgets/stadium_scaffold.dart';
import 'history_screen.dart';
import 'music_player_screen.dart';
import 'score_control_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'teams_screen.dart';
import 'timer_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _connectionDialogVisible = false;

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(connectionProvider);
    final score = ref.watch(scoreProvider);
    final music = ref.watch(musicProvider);
    final timer = ref.watch(timerProvider);
    final settings = ref.watch(settingsProvider);

    _listenForConnectionLoss();
    _listenForScoreErrors();

    return StadiumScaffold(
      appBar: _buildAppBar(context, connection),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final maxContentWidth = wide ? 1100.0 : 720.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _DashboardPrimaryColumn(
                              connection: connection,
                              score: score,
                              timer: timer,
                              settings: settings,
                              timerLabel: _formatDuration(timer.duration),
                              onStart: () => ref.read(scoreProvider.notifier).startMatch(),
                              onEnd: () {
                                ref.read(scoreProvider.notifier).endMatch().then((_) {
                                  ref.read(historyProvider.notifier).refresh();
                                });
                              },
                              onReset: () => _confirmReset(context),
                              onTestAudio: () => _sendTestAudio(context),
                              onOpenTimer: () => _openScreen(context, const TimerScreen()),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _DashboardSecondaryColumn(
                              music: music,
                              onPlayPause: () {
                                if (music.playing) {
                                  ref.read(musicProvider.notifier).pause();
                                } else {
                                  ref.read(musicProvider.notifier).play();
                                }
                              },
                              onNext: () => ref.read(musicProvider.notifier).next(),
                              onVolumeDown: () =>
                                  ref.read(musicProvider.notifier).volumeDown(),
                              onVolumeUp: () => ref.read(musicProvider.notifier).volumeUp(),
                              onOpenScreen: (screen) => _openScreen(context, screen),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ConnectionBanner(status: connection),
                          const SizedBox(height: 16),
                          LiveScoreboardCard(
                            teamA: score.teamA,
                            teamB: score.teamB,
                            timerLabel: _formatDuration(timer.duration),
                            matchActive: score.matchActive,
                            animationsEnabled: settings.animationsEnabled,
                          ),
                          const SizedBox(height: 12),
                          MatchTimerBar(
                            label: _formatDuration(timer.duration),
                            running: timer.running,
                            onTap: () => _openScreen(context, const TimerScreen()),
                          ),
                          const SizedBox(height: 20),
                          NowPlayingCard(
                            title: music.currentTitle,
                            playing: music.playing,
                            muted: music.muted,
                          ),
                          const SizedBox(height: 10),
                          QuickMusicBar(
                            playing: music.playing,
                            muted: music.muted,
                            volume: music.volume,
                            onPlayPause: () {
                              if (music.playing) {
                                ref.read(musicProvider.notifier).pause();
                              } else {
                                ref.read(musicProvider.notifier).play();
                              }
                            },
                            onNext: () => ref.read(musicProvider.notifier).next(),
                            onVolumeDown: () =>
                                ref.read(musicProvider.notifier).volumeDown(),
                            onVolumeUp: () => ref.read(musicProvider.notifier).volumeUp(),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Quick Actions',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _QuickActionsRow(
                            matchActive: score.matchActive,
                            onStart: () => ref.read(scoreProvider.notifier).startMatch(),
                            onEnd: () {
                              ref.read(scoreProvider.notifier).endMatch().then((_) {
                                ref.read(historyProvider.notifier).refresh();
                              });
                            },
                            onReset: () => _confirmReset(context),
                            onTestAudio: () => _sendTestAudio(context),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Control Hub',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ControlHubGrid(
                            onOpenScreen: (screen) => _openScreen(context, screen),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ConnectionStatus status) {
    final batteryLabel =
        status.batteryPercent != null ? '${status.batteryPercent}%' : '—';

    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            'DSS',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: 1.5,
              color: StadiumColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(child: _StatusChip(status: status)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Row(
            children: [
              Icon(
                Icons.battery_std_rounded,
                size: 18,
                color: Colors.white54,
              ),
              const SizedBox(width: 4),
              Text(
                batteryLabel,
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => _openScreen(context, const SettingsScreen()),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  void _listenForConnectionLoss() {
    ref.listen(connectionProvider, (previous, next) {
      final notifier = ref.read(connectionProvider.notifier);
      if (!notifier.connectionLost || _connectionDialogVisible) {
        return;
      }

      _connectionDialogVisible = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          _connectionDialogVisible = false;
          return;
        }

        await ConnectionLostDialog.show(
          context,
          onReconnect: () {
            notifier.connectionLost = false;
            ref.read(connectionProvider.notifier).reconnect();
          },
          onUseSimulation: () {
            notifier.connectionLost = false;
            ref.read(connectionProvider.notifier).enterSimulation();
          },
        );

        if (mounted) {
          _connectionDialogVisible = false;
        }
      });
    });
  }

  void _listenForScoreErrors() {
    ref.listen(scoreProvider, (previous, next) {
      final error = next.lastError;
      if (error == null || error == previous?.lastError) {
        return;
      }

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
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StadiumColors.navyMid,
        title: Text(
          'Reset Match?',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Scores and team names will return to defaults on the scoreboard.',
          style: GoogleFonts.spaceGrotesk(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: StadiumColors.rival,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();
      await ref.read(scoreProvider.notifier).resetMatch();
    }
  }

  Future<void> _sendTestAudio(BuildContext context) async {
    HapticFeedback.lightImpact();
    try {
      await ref.read(scoreboardConnectionProvider).send(ScoreboardCommands.audio);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: StadiumColors.rival,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(FadePageRoute(page: screen));
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final isSimulation = status.mode == ConnectionMode.simulation;
    final isConnected = status.mode == ConnectionMode.connected;
    final label = isSimulation
        ? 'Simulation'
        : isConnected
            ? 'BT'
            : 'Offline';
    final color = isSimulation || isConnected
        ? StadiumColors.accent
        : Colors.white38;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSimulation
                ? Icons.smart_toy_outlined
                : isConnected
                    ? Icons.bluetooth_rounded
                    : Icons.bluetooth_disabled_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPrimaryColumn extends StatelessWidget {
  const _DashboardPrimaryColumn({
    required this.connection,
    required this.score,
    required this.timer,
    required this.settings,
    required this.timerLabel,
    required this.onStart,
    required this.onEnd,
    required this.onReset,
    required this.onTestAudio,
    required this.onOpenTimer,
  });

  final ConnectionStatus connection;
  final ScoreState score;
  final TimerState timer;
  final AppSettings settings;
  final String timerLabel;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final VoidCallback onReset;
  final VoidCallback onTestAudio;
  final VoidCallback onOpenTimer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConnectionBanner(status: connection),
        const SizedBox(height: 16),
        LiveScoreboardCard(
          teamA: score.teamA,
          teamB: score.teamB,
          timerLabel: timerLabel,
          matchActive: score.matchActive,
          animationsEnabled: settings.animationsEnabled,
        ),
        const SizedBox(height: 12),
        MatchTimerBar(
          label: timerLabel,
          running: timer.running,
          onTap: onOpenTimer,
        ),
        const SizedBox(height: 24),
        Text(
          'Quick Actions',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 12),
        _QuickActionsRow(
          matchActive: score.matchActive,
          onStart: onStart,
          onEnd: onEnd,
          onReset: onReset,
          onTestAudio: onTestAudio,
        ),
      ],
    );
  }
}

class _DashboardSecondaryColumn extends StatelessWidget {
  const _DashboardSecondaryColumn({
    required this.music,
    required this.onPlayPause,
    required this.onNext,
    required this.onVolumeDown,
    required this.onVolumeUp,
    required this.onOpenScreen,
  });

  final MusicState music;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onVolumeDown;
  final VoidCallback onVolumeUp;
  final void Function(Widget screen) onOpenScreen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NowPlayingCard(
          title: music.currentTitle,
          playing: music.playing,
          muted: music.muted,
        ),
        const SizedBox(height: 10),
        QuickMusicBar(
          playing: music.playing,
          muted: music.muted,
          volume: music.volume,
          onPlayPause: onPlayPause,
          onNext: onNext,
          onVolumeDown: onVolumeDown,
          onVolumeUp: onVolumeUp,
        ),
        const SizedBox(height: 28),
        Text(
          'Control Hub',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 12),
        _ControlHubGrid(onOpenScreen: onOpenScreen),
      ],
    );
  }
}

class _ControlHubGrid extends StatelessWidget {
  const _ControlHubGrid({required this.onOpenScreen});

  final void Function(Widget screen) onOpenScreen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 400 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: [
            HubTile(
              icon: Icons.sports_score_rounded,
              label: 'Score',
              onTap: () => onOpenScreen(const ScoreControlScreen()),
            ),
            HubTile(
              icon: Icons.groups_rounded,
              label: 'Teams',
              accentColor: StadiumColors.rival,
              onTap: () => onOpenScreen(const TeamsScreen()),
            ),
            HubTile(
              icon: Icons.library_music_rounded,
              label: 'Music',
              onTap: () => onOpenScreen(const MusicPlayerScreen()),
            ),
            HubTile(
              icon: Icons.history_rounded,
              label: 'History',
              onTap: () => onOpenScreen(const HistoryScreen()),
            ),
            HubTile(
              icon: Icons.bar_chart_rounded,
              label: 'Stats',
              onTap: () => onOpenScreen(const StatisticsScreen()),
            ),
            HubTile(
              icon: Icons.timer_rounded,
              label: 'Timer',
              onTap: () => onOpenScreen(const TimerScreen()),
            ),
            HubTile(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: () => onOpenScreen(const SettingsScreen()),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.matchActive,
    required this.onStart,
    required this.onEnd,
    required this.onReset,
    required this.onTestAudio,
  });

  final bool matchActive;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final VoidCallback onReset;
  final VoidCallback onTestAudio;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionChip(
          label: 'Start Match',
          icon: Icons.play_arrow_rounded,
          color: StadiumColors.accent,
          onPressed: matchActive ? null : onStart,
        ),
        _ActionChip(
          label: 'End Match',
          icon: Icons.stop_rounded,
          color: StadiumColors.rival,
          onPressed: matchActive ? onEnd : null,
        ),
        _ActionChip(
          label: 'Reset',
          icon: Icons.restart_alt_rounded,
          color: Colors.white70,
          onPressed: onReset,
        ),
        _ActionChip(
          label: 'Test Audio',
          icon: Icons.volume_up_rounded,
          color: Colors.white70,
          onPressed: onTestAudio,
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return FilledButton.tonal(
      onPressed: enabled
          ? () {
              HapticFeedback.lightImpact();
              onPressed!();
            }
          : null,
      style: FilledButton.styleFrom(
        backgroundColor: enabled
            ? color.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.04),
        foregroundColor: enabled ? color : Colors.white30,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
