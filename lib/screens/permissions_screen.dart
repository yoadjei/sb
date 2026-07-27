import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../animations/fade_page_route.dart';
import '../themes/colors.dart';
import 'bluetooth_scan_screen.dart';

enum _PermissionPhase { idle, requesting, granted, denied, permanentlyDenied }

/// Classic Bluetooth permission flow is Android-only.
/// On web/desktop we skip grants and send users to Simulation Mode.
bool get _needsBluetoothPermissions {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  _PermissionPhase _phase = _PermissionPhase.idle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_needsBluetoothPermissions) {
        // Web/desktop preview: Classic BT permissions are unavailable.
        setState(() => _phase = _PermissionPhase.granted);
        return;
      }
      _checkExisting();
    });
  }

  Future<List<Permission>> _requiredPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ];
    }
    return [Permission.bluetooth, Permission.locationWhenInUse];
  }

  Future<bool> _hasRequiredPermissions() async {
    final permissions = await _requiredPermissions();
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _checkExisting() async {
    try {
      if (await _hasRequiredPermissions()) {
        if (!mounted) return;
        setState(() => _phase = _PermissionPhase.granted);
      }
    } catch (_) {
      // Ignore — user can request manually.
    }
  }

  Future<void> _requestPermissions() async {
    if (!_needsBluetoothPermissions) {
      _continue();
      return;
    }

    setState(() {
      _phase = _PermissionPhase.requesting;
      _errorMessage = null;
    });

    try {
      final permissions = await _requiredPermissions();
      final statuses = await permissions.request();

      final denied = <Permission>[];
      var permanentlyDenied = false;

      for (final entry in statuses.entries) {
        if (entry.value.isGranted) continue;
        denied.add(entry.key);
        if (entry.value.isPermanentlyDenied) {
          permanentlyDenied = true;
        }
      }

      if (denied.isEmpty) {
        if (!mounted) return;
        setState(() => _phase = _PermissionPhase.granted);
        return;
      }

      if (!mounted) return;
      setState(() {
        _phase = permanentlyDenied
            ? _PermissionPhase.permanentlyDenied
            : _PermissionPhase.denied;
        _errorMessage = permanentlyDenied
            ? 'Some permissions were permanently denied. Open Settings to allow Bluetooth and location, then tap Retry.'
            : 'Bluetooth and location access are required to find your scoreboard. Tap Retry to grant permissions.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _phase = _PermissionPhase.denied;
        _errorMessage =
            'Could not request permissions. Please try again or enable them in Settings.';
      });
    }
  }

  void _continue() {
    Navigator.of(context).pushReplacement(
      FadePageRoute(page: const BluetoothScanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopPreview = !_needsBluetoothPermissions;
    final isRequesting = _phase == _PermissionPhase.requesting;
    final canContinue = _phase == _PermissionPhase.granted || isDesktopPreview;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [StadiumColors.navy, StadiumColors.navyMid],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  isDesktopPreview
                      ? 'Preview Mode'
                      : 'Connect Your Scoreboard',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isDesktopPreview
                      ? 'Bluetooth Classic only works on an Android device. Continue to the scan screen and use Simulation Mode to explore the full app here.'
                      : 'We need a few permissions so the app can discover and control your ESP32 scoreboard over Bluetooth Classic.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),
                if (isDesktopPreview) ...[
                  _PermissionTile(
                    icon: Icons.science_outlined,
                    title: 'Simulation Mode',
                    subtitle:
                        'Demo scores, music, timer, and history without an ESP32. Perfect for browser and desktop previews.',
                  ),
                  const SizedBox(height: 14),
                  _PermissionTile(
                    icon: Icons.phone_android_rounded,
                    title: 'Real Bluetooth',
                    subtitle:
                        'Install the Android APK on a phone to connect to your HC-05 / ESP32 scoreboard.',
                  ),
                ] else ...[
                  _PermissionTile(
                    icon: Icons.bluetooth_searching_rounded,
                    title: 'Bluetooth',
                    subtitle:
                        'Scan for paired and nearby scoreboard modules (HC-05 / SPP).',
                  ),
                  const SizedBox(height: 14),
                  _PermissionTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    subtitle:
                        'Android requires location access for Bluetooth device discovery. We do not track your position.',
                  ),
                ],
                if (_errorMessage != null && !isDesktopPreview) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StadiumColors.rival.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: StadiumColors.rival.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: StadiumColors.rival.withValues(alpha: 0.9),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.92),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                if (_phase == _PermissionPhase.permanentlyDenied &&
                    !isDesktopPreview)
                  OutlinedButton.icon(
                    onPressed: openAppSettings,
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(
                      'Open Settings',
                      style:
                          GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side:
                          BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                if (_phase == _PermissionPhase.permanentlyDenied &&
                    !isDesktopPreview)
                  const SizedBox(height: 12),
                FilledButton(
                  onPressed: isRequesting
                      ? null
                      : canContinue
                          ? _continue
                          : _requestPermissions,
                  style: FilledButton.styleFrom(
                    backgroundColor: StadiumColors.accent,
                    foregroundColor: StadiumColors.navy,
                    disabledBackgroundColor:
                        StadiumColors.accent.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isRequesting
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: StadiumColors.navy.withValues(alpha: 0.8),
                          ),
                        )
                      : Text(
                          isDesktopPreview
                              ? 'Continue to Simulation'
                              : (canContinue
                                  ? 'Continue'
                                  : 'Grant Permissions'),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                if (!canContinue && !isDesktopPreview) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isRequesting ? null : _requestPermissions,
                    child: Text(
                      'Retry',
                      style: GoogleFonts.spaceGrotesk(
                        color: StadiumColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: StadiumColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: StadiumColors.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: Colors.white60,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
