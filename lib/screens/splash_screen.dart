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
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _enterController;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _navTimer = Timer(const Duration(milliseconds: 2400), _goToPermissions);
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
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(fade);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF071525),
              StadiumColors.navy,
              StadiumColors.navyMid,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _StadiumAtmospherePainter(pulse: _pulseController),
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: fade,
                  child: SlideTransition(
                    position: slide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1 + (_pulseController.value * 0.015),
                                child: child,
                              );
                            },
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    StadiumColors.brand,
                                    StadiumColors.brand.withValues(alpha: 0.75),
                                    StadiumColors.accent.withValues(alpha: 0.85),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: StadiumColors.brand
                                        .withValues(alpha: 0.35),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'DSS',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: StadiumColors.navy,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Digital Sports Scoreboard',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Control live scores, music, and match flow from one operator console.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              height: 1.45,
                              color: Colors.white.withValues(alpha: 0.68),
                            ),
                          ),
                          const SizedBox(height: 36),
                          SizedBox(
                            width: 220,
                            height: 110,
                            child: CustomPaint(
                              painter: _ScoreboardGraphicPainter(),
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: StadiumColors.brand.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
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

class _ScoreboardGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    canvas.drawRRect(
      frameRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.03),
          ],
        ).createShader(frameRect.outerRect),
    );

    canvas.drawRRect(
      frameRect,
      Paint()
        ..color = StadiumColors.brand.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final displayRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(14, 14, size.width - 28, size.height - 28),
      const Radius.circular(10),
    );
    canvas.drawRRect(displayRect, Paint()..color = const Color(0xFF061018));

    _drawScore(canvas, 44, 38, '12', StadiumColors.accent);
    _drawScore(canvas, size.width - 44, 38, '09', StadiumColors.rival);

    final vsPaint = TextPainter(
      text: TextSpan(
        text: 'VS',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white38,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    vsPaint.paint(
      canvas,
      Offset((size.width - vsPaint.width) / 2, 30),
    );

    _drawTeamLabel(canvas, 44, 72, 'HOME');
    _drawTeamLabel(canvas, size.width - 44, 72, 'AWAY');
  }

  void _drawScore(Canvas canvas, double x, double y, String score, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: score,
        style: GoogleFonts.robotoMono(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: color,
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
          letterSpacing: 1.1,
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

class _StadiumAtmospherePainter extends CustomPainter {
  _StadiumAtmospherePainter({required this.pulse});

  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final radius = size.shortestSide * (0.5 + pulse.value * 0.03);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          StadiumColors.brand.withValues(alpha: 0.10 + pulse.value * 0.04),
          StadiumColors.accent.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glow);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = StadiumColors.brand.withValues(alpha: 0.08);
    canvas.drawCircle(center, radius * 0.72, ring);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.9),
      -math.pi / 5,
      math.pi / 2.2,
      false,
      Paint()
        ..color = StadiumColors.accent.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _StadiumAtmospherePainter oldDelegate) {
    return oldDelegate.pulse.value != pulse.value;
  }
}
