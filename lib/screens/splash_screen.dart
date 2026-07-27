import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../animations/fade_page_route.dart';
import '../themes/colors.dart';
import 'permissions_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _navTimer = Timer(const Duration(seconds: 2), _goToPermissions);
  }

  void _goToPermissions() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FadePageRoute(page: const PermissionsScreen()),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _StadiumGridPainter(
                    pulse: _pulseController,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + (_pulseController.value * 0.02),
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: 260,
                        height: 140,
                        child: CustomPaint(
                          painter: _ScoreboardGraphicPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'Digital Sports',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 4,
                        color: StadiumColors.accent.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scoreboard',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: StadiumColors.accent.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreboardGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(18),
    );

    final framePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          Colors.white.withValues(alpha: 0.04),
        ],
      ).createShader(frameRect.outerRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(frameRect, framePaint);

    final borderPaint = Paint()
      ..color = StadiumColors.accent.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(frameRect, borderPaint);

    final displayRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 16, size.width - 32, size.height - 32),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      displayRect,
      Paint()..color = const Color(0xFF061018),
    );

    _drawScore(canvas, 48, 52, '12', StadiumColors.accent);
    _drawScore(canvas, size.width - 48, 52, '09', StadiumColors.rival);

    final vsPaint = TextPainter(
      text: TextSpan(
        text: 'VS',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white38,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    vsPaint.paint(
      canvas,
      Offset(
        (size.width - vsPaint.width) / 2,
        40,
      ),
    );

    _drawTeamLabel(canvas, 48, 88, 'TEAM A');
    _drawTeamLabel(canvas, size.width - 48, 88, 'TEAM B');

    final ledPaint = Paint()..color = StadiumColors.accent.withValues(alpha: 0.7);
    for (var i = 0; i < 7; i++) {
      canvas.drawCircle(
        Offset(24 + (i * 34), size.height - 14),
        2.5,
        ledPaint..color = StadiumColors.accent.withValues(alpha: 0.35 + (i * 0.08)),
      );
    }
  }

  void _drawScore(Canvas canvas, double x, double y, String score, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: score,
        style: GoogleFonts.robotoMono(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y));
  }

  void _drawTeamLabel(Canvas canvas, double x, double y, String label) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.white38,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StadiumGridPainter extends CustomPainter {
  _StadiumGridPainter({required this.pulse});

  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = size.shortestSide * (0.55 + pulse.value * 0.04);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      ringPaint.color = StadiumColors.accent.withValues(alpha: 0.04 * i);
      canvas.drawCircle(center, radius * (i / 3), ringPaint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const spacing = 48.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          StadiumColors.accent.withValues(alpha: 0.06 + pulse.value * 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, glowPaint);

    final arcPaint = Paint()
      ..color = StadiumColors.accent.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.85),
      -math.pi / 4,
      math.pi / 2,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StadiumGridPainter oldDelegate) {
    return oldDelegate.pulse.value != pulse.value;
  }
}
