import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../animations/fade_page_route.dart';
import '../models/bt_device.dart';
import '../models/connection_status.dart';
import '../providers/connection_provider.dart';
import '../themes/colors.dart';
import '../widgets/device_card.dart';
import 'dashboard_screen.dart';

class BluetoothScanScreen extends ConsumerStatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  ConsumerState<BluetoothScanScreen> createState() =>
      _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends ConsumerState<BluetoothScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _searchController;
  bool _bluetoothOff = false;
  bool _checkingBluetooth = true;
  String? _connectedAddress;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    await _refreshBluetoothState();
    if (!_bluetoothOff && mounted) {
      await _startScan();
    }
  }

  Future<void> _refreshBluetoothState() async {
    setState(() => _checkingBluetooth = true);
    try {
      final enabled =
          await ref.read(connectionProvider.notifier).isBluetoothEnabled();
      if (!mounted) return;
      setState(() {
        _bluetoothOff = !enabled;
        _checkingBluetooth = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bluetoothOff = true;
        _checkingBluetooth = false;
      });
    }
  }

  Future<void> _enableBluetooth() async {
    try {
      final enabled =
          await ref.read(connectionProvider.notifier).requestEnableBluetooth();
      if (!mounted) return;
      setState(() => _bluetoothOff = !enabled);
      if (enabled) {
        await _startScan();
      } else {
        _showSnack('Bluetooth is still off. Enable it in system settings.');
      }
    } catch (error) {
      _showSnack('Could not enable Bluetooth: $error');
    }
  }

  Future<void> _startScan() async {
    if (_bluetoothOff) return;
    await ref.read(connectionProvider.notifier).startScan();
    final error = ref.read(connectionProvider).lastError;
    if (error != null) {
      _showSnack(_friendlyScanError(error));
    }
  }

  Future<void> _connectDevice(BtDevice device) async {
    await ref.read(connectionProvider.notifier).connectDevice(device);
    if (!mounted) return;

    final status = ref.read(connectionProvider);
    if (status.mode == ConnectionMode.connected) {
      setState(() => _connectedAddress = device.address);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      await _goToDashboard();
    } else if (status.lastError != null) {
      _showSnack(_friendlyConnectError(status.lastError!));
    }
  }

  Future<void> _enterSimulation() async {
    await ref.read(connectionProvider.notifier).enterSimulation();
    if (!mounted) return;

    final status = ref.read(connectionProvider);
    if (status.mode == ConnectionMode.simulation) {
      await _goToDashboard();
    } else if (status.lastError != null) {
      _showSnack('Simulation failed: ${status.lastError}');
    }
  }

  Future<void> _goToDashboard() async {
    if (_navigating || !mounted) return;
    _navigating = true;
    await Navigator.of(context).pushReplacement(
      FadePageRoute(page: const DashboardScreen()),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.spaceGrotesk(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StadiumColors.navyMid,
        ),
      );
  }

  String _friendlyScanError(String error) {
    if (error.toLowerCase().contains('disabled')) {
      return 'Bluetooth is off. Turn it on and tap Rescan.';
    }
    return 'Scan failed. Check permissions and try again.';
  }

  String _friendlyConnectError(String error) {
    if (error.toLowerCase().contains('failed to connect')) {
      return 'Could not connect. Ensure the scoreboard is powered on and paired.';
    }
    return 'Connection failed. Tap Connect to retry.';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(connectionProvider);
    final isScanning = status.mode == ConnectionMode.scanning;
    final isConnecting = status.mode == ConnectionMode.connecting;
    final devices = status.discoveredDevices;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [StadiumColors.navy, StadiumColors.navyMid],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Scoreboard',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select your ESP32 module or try Simulation Mode without hardware.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: Colors.white60,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_checkingBluetooth)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: StadiumColors.accent),
                  ),
                )
              else if (_bluetoothOff)
                Expanded(child: _BluetoothOffState(onEnable: _enableBluetooth))
              else ...[
                _SearchAnimation(
                  controller: _searchController,
                  isActive: isScanning,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isScanning
                              ? 'Scanning for devices…'
                              : devices.isEmpty
                                  ? 'No devices found'
                                  : '${devices.length} device${devices.length == 1 ? '' : 's'} found',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: isScanning ? null : _startScan,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          'Rescan',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: StadiumColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: devices.isEmpty && !isScanning
                      ? _EmptyScanState(onRescan: _startScan)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          itemCount: devices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            final connectingThis = isConnecting &&
                                status.deviceAddress == device.address;
                            final connectedThis =
                                _connectedAddress == device.address;

                            return DeviceCard(
                              device: device,
                              isConnecting: connectingThis,
                              isConnected: connectedThis,
                              onConnect: connectingThis || connectedThis
                                  ? () {}
                                  : () => _connectDevice(device),
                            );
                          },
                        ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: OutlinedButton.icon(
                  onPressed: isConnecting ? null : _enterSimulation,
                  icon: const Icon(Icons.smart_toy_outlined),
                  label: Text(
                    'Enter Simulation Mode',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: StadiumColors.accent,
                    side: BorderSide(
                      color: StadiumColors.accent.withValues(alpha: 0.65),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchAnimation extends StatelessWidget {
  const _SearchAnimation({
    required this.controller,
    required this.isActive,
  });

  final AnimationController controller;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RadarPainter(
              progress: isActive ? controller.value : 0,
              isActive: isActive,
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StadiumColors.accent.withValues(alpha: 0.12),
                  border: Border.all(
                    color: StadiumColors.accent.withValues(alpha: 0.45),
                  ),
                ),
                child: Icon(
                  isActive ? Icons.radar_rounded : Icons.bluetooth_rounded,
                  color: StadiumColors.accent,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.progress, required this.isActive});

  final double progress;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.38;

    for (var i = 0; i < 3; i++) {
      final wave = (progress + i * 0.33) % 1.0;
      final radius = maxRadius * wave;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = StadiumColors.accent.withValues(alpha: (1 - wave) * 0.45);
      canvas.drawCircle(center, radius, paint);
    }

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          StadiumColors.accent.withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.08, 0.16],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawCircle(center, maxRadius, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}

class _EmptyScanState extends StatelessWidget {
  const _EmptyScanState({required this.onRescan});

  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_other_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              'No scoreboards nearby',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Power on your ESP32 module, ensure Bluetooth is paired in Android settings, and stand within range.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: Colors.white60,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRescan,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Rescan',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: StadiumColors.accent,
                foregroundColor: StadiumColors.navy,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BluetoothOffState extends StatelessWidget {
  const _BluetoothOffState({required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled_rounded,
              size: 52,
              color: StadiumColors.rival.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 16),
            Text(
              'Bluetooth is turned off',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable Bluetooth to scan for your scoreboard, or use Simulation Mode below.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: Colors.white60,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onEnable,
              icon: const Icon(Icons.bluetooth_rounded),
              label: Text(
                'Turn On Bluetooth',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: StadiumColors.accent,
                foregroundColor: StadiumColors.navy,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
