import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../animations/fade_page_route.dart';
import '../models/app_settings.dart';
import '../providers/connection_provider.dart';
import '../providers/history_provider.dart';
import '../providers/score_provider.dart';
import '../providers/settings_provider.dart';
import '../themes/colors.dart';
import '../widgets/stadium_scaffold.dart';
import 'about_screen.dart';
import 'bluetooth_scan_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final connection = ref.watch(connectionProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Settings'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionHeader('Appearance'),
          _ThemeSelector(
            current: settings.theme,
            onChanged: (theme) => notifier.setTheme(theme),
          ),
          _SwitchTile(
            title: 'Score increment sound',
            subtitle: 'Play feedback on score changes',
            value: settings.scoreIncrementSound,
            onChanged: (value) =>
                notifier.update(settings.copyWith(scoreIncrementSound: value)),
          ),
          _SwitchTile(
            title: 'Animations',
            subtitle: 'Score pop and UI transitions',
            value: settings.animationsEnabled,
            onChanged: (value) =>
                notifier.update(settings.copyWith(animationsEnabled: value)),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Bluetooth'),
          _ActionTile(
            title: connection.isLive ? 'Disconnect' : 'Open Bluetooth Scan',
            subtitle: connection.isLive
                ? 'Connected to ${connection.deviceName ?? 'device'}'
                : 'Find and connect to scoreboard',
            icon: connection.isLive
                ? Icons.bluetooth_disabled_rounded
                : Icons.bluetooth_searching_rounded,
            onTap: () async {
              if (connection.isLive) {
                await ref.read(connectionProvider.notifier).disconnect();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Disconnected'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  FadePageRoute(page: const BluetoothScanScreen()),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          _SectionHeader('Music'),
          _SwitchTile(
            title: 'Background music',
            subtitle: 'Enable music controls',
            value: settings.enableBackgroundMusic,
            onChanged: (value) => notifier.update(
              settings.copyWith(enableBackgroundMusic: value),
            ),
          ),
          _SwitchTile(
            title: 'Auto play on match start',
            subtitle: 'Send PLAY when match starts',
            value: settings.autoPlayOnGameStart,
            onChanged: (value) => notifier.update(
              settings.copyWith(autoPlayOnGameStart: value),
            ),
          ),
          _SwitchTile(
            title: 'Stop music on match end',
            subtitle: 'Send PAUSE when match ends',
            value: settings.stopMusicOnGameEnd,
            onChanged: (value) => notifier.update(
              settings.copyWith(stopMusicOnGameEnd: value),
            ),
          ),
          _VolumeSlider(
            value: settings.defaultVolume,
            onChanged: (value) =>
                notifier.update(settings.copyWith(defaultVolume: value)),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Sound Effects'),
          _SwitchTile(
            title: 'Sound effects',
            subtitle: 'UI and action feedback sounds',
            value: settings.soundEffectsEnabled,
            onChanged: (value) => notifier.update(
              settings.copyWith(soundEffectsEnabled: value),
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('About'),
          _ActionTile(
            title: 'About Digital Sports Scoreboard',
            subtitle: 'Version ${AboutScreen.appVersion}',
            icon: Icons.info_outline_rounded,
            onTap: () {
              Navigator.of(context).push(
                FadePageRoute(page: const AboutScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          _DangerZone(
            onReset: () => _confirmResetAppData(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmResetAppData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StadiumColors.navyMid,
        title: Text(
          'Reset App Data?',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This clears all settings, match history, and resets scores to defaults. This cannot be undone.',
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

    if (confirmed != true) return;

    HapticFeedback.heavyImpact();
    try {
      await ref.read(settingsProvider.notifier).resetAppData();
      await ref.read(scoreProvider.notifier).resetMatch();
      ref.read(historyProvider.notifier).refresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('App data reset'),
          backgroundColor: StadiumColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset failed: $error'),
          backgroundColor: StadiumColors.rival,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: Colors.white54,
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.current,
    required this.onChanged,
  });

  final ThemePreference current;
  final ValueChanged<ThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SegmentedButton<ThemePreference>(
        segments: const [
          ButtonSegment(
            value: ThemePreference.light,
            label: Text('Light'),
            icon: Icon(Icons.light_mode_outlined, size: 18),
          ),
          ButtonSegment(
            value: ThemePreference.dark,
            label: Text('Dark'),
            icon: Icon(Icons.dark_mode_outlined, size: 18),
          ),
          ButtonSegment(
            value: ThemePreference.system,
            label: Text('Auto'),
            icon: Icon(Icons.brightness_auto_outlined, size: 18),
          ),
        ],
        selected: {current},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return StadiumColors.navy;
            }
            return Colors.white70;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return StadiumColors.accent;
            }
            return Colors.white.withValues(alpha: 0.06);
          }),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
        value: value,
        activeThumbColor: StadiumColors.accent,
        onChanged: onChanged,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: ListTile(
        leading: Icon(icon, color: StadiumColors.accent),
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Default volume',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            'DFPlayer volume level (0–30)',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value.clamp(0, 30).toDouble(),
                  min: 0,
                  max: 30,
                  divisions: 30,
                  activeColor: StadiumColors.accent,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
              Text(
                '$value',
                style: GoogleFonts.robotoMono(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: StadiumColors.rival.withValues(alpha: 0.08),
        border: Border.all(color: StadiumColors.rival.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Danger Zone',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700,
              color: StadiumColors.rival,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Permanently erase local app data',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Reset App Data'),
            style: OutlinedButton.styleFrom(
              foregroundColor: StadiumColors.rival,
              side: BorderSide(color: StadiumColors.rival.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
