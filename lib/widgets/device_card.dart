import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/bt_device.dart';
import '../themes/colors.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.onConnect,
    this.isConnecting = false,
    this.isConnected = false,
  });

  final BtDevice device;
  final VoidCallback onConnect;
  final bool isConnecting;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final rssiLabel = device.rssi != null ? '${device.rssi} dBm' : '—';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isConnected
              ? [
                  StadiumColors.accent.withValues(alpha: 0.22),
                  StadiumColors.navyMid,
                ]
              : [
                  StadiumColors.navyMid.withValues(alpha: 0.95),
                  StadiumColors.navy,
                ],
        ),
        border: Border.all(
          color: isConnected
              ? StadiumColors.accent
              : Colors.white.withValues(alpha: 0.08),
          width: isConnected ? 1.5 : 1,
        ),
        boxShadow: [
          if (isConnected)
            BoxShadow(
              color: StadiumColors.accent.withValues(alpha: 0.25),
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isConnected
                    ? StadiumColors.accent.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isConnected ? Icons.check_circle_rounded : Icons.bluetooth_rounded,
                color: isConnected ? StadiumColors.accent : Colors.white70,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.address,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: Colors.white60,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 14,
                        color: _rssiColor(device.rssi),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rssiLabel,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isConnecting)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: StadiumColors.accent,
                ),
              )
            else if (isConnected)
              Icon(
                Icons.link_rounded,
                color: StadiumColors.accent,
                size: 28,
              )
            else
              FilledButton(
                onPressed: onConnect,
                style: FilledButton.styleFrom(
                  backgroundColor: StadiumColors.accent,
                  foregroundColor: StadiumColors.navy,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Connect',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _rssiColor(int? rssi) {
    if (rssi == null) return Colors.white38;
    if (rssi >= -60) return StadiumColors.accent;
    if (rssi >= -80) return Colors.amber;
    return StadiumColors.rival;
  }
}
