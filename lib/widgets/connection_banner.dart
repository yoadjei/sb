import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/connection_status.dart';
import '../themes/colors.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({
    super.key,
    required this.status,
  });

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = _resolve(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (status.batteryPercent != null)
            Text(
              '${status.batteryPercent}%',
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  (String, IconData, Color) _resolve(ConnectionStatus status) {
    switch (status.mode) {
      case ConnectionMode.connected:
        final name = status.deviceName ?? 'Scoreboard';
        return ('Connected · $name', Icons.bluetooth_connected_rounded, StadiumColors.accent);
      case ConnectionMode.simulation:
        return ('Simulation Mode — demo without hardware', Icons.smart_toy_outlined, StadiumColors.accent);
      case ConnectionMode.connecting:
        return ('Connecting…', Icons.bluetooth_searching_rounded, Colors.amber);
      case ConnectionMode.scanning:
        return ('Scanning for devices…', Icons.radar_rounded, Colors.amber);
      case ConnectionMode.disconnected:
        if (status.lastError != null) {
          return (status.lastError!, Icons.error_outline_rounded, StadiumColors.rival);
        }
        return ('Not connected', Icons.bluetooth_disabled_rounded, Colors.white54);
    }
  }
}
