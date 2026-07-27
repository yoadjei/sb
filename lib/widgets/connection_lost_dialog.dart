import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/colors.dart';

class ConnectionLostDialog extends StatelessWidget {
  const ConnectionLostDialog({
    super.key,
    required this.onReconnect,
    required this.onUseSimulation,
  });

  final VoidCallback onReconnect;
  final VoidCallback onUseSimulation;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onReconnect,
    required VoidCallback onUseSimulation,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConnectionLostDialog(
        onReconnect: onReconnect,
        onUseSimulation: onUseSimulation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StadiumColors.navyMid,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Icon(
        Icons.bluetooth_disabled_rounded,
        color: StadiumColors.rival,
        size: 36,
      ),
      title: Text(
        'Connection Lost',
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      content: Text(
        'The scoreboard link was interrupted. Reconnect to your device or continue in Simulation Mode.',
        style: GoogleFonts.spaceGrotesk(
          color: Colors.white70,
          height: 1.45,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onUseSimulation();
          },
          child: Text(
            'Use Simulation',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onReconnect();
          },
          style: FilledButton.styleFrom(
            backgroundColor: StadiumColors.accent,
            foregroundColor: StadiumColors.navy,
          ),
          child: Text(
            'Reconnect',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
