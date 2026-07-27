import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/connection_status.dart';
import '../providers/connection_provider.dart';
import '../themes/colors.dart';

/// Minimal dashboard shell — full hub UI is Task 10.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionProvider);

    return Scaffold(
      backgroundColor: StadiumColors.navy,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        ),
        backgroundColor: StadiumColors.navy,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status.mode == ConnectionMode.simulation
                    ? Icons.smart_toy_outlined
                    : Icons.bluetooth_connected_rounded,
                size: 56,
                color: StadiumColors.accent,
              ),
              const SizedBox(height: 20),
              Text(
                'Dashboard',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _statusLabel(status),
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(ConnectionStatus status) {
    switch (status.mode) {
      case ConnectionMode.simulation:
        return 'Simulation Mode — demo without hardware';
      case ConnectionMode.connected:
        final name = status.deviceName ?? 'Scoreboard';
        return 'Connected to $name';
      default:
        return 'Not connected';
    }
  }
}
