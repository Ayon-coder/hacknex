import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/theme_music_service.dart';
import '../theme/hogwarts_theme.dart';
import 'splash_screen.dart';

/// Cold open: a starlit night, a wax-sealed letter, and the theme rising.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _ambientController;
  late Animation<double> _progressAnimation;

  static const List<String> _loadingStatuses = [
    'Unsealing the letter...',
    'Consulting the Restricted Section...',
    'Brewing the Potions curriculum...',
    'Charming the moving staircases...',
    'Waking the portraits...',
    'The castle is ready for you.',
  ];

  static String _statusFor(double progress) {
    if (progress < 0.25) return _loadingStatuses[0];
    if (progress < 0.45) return _loadingStatuses[1];
    if (progress < 0.70) return _loadingStatuses[2];
    if (progress < 0.88) return _loadingStatuses[3];
    if (progress < 0.98) return _loadingStatuses[4];
    return _loadingStatuses[5];
  }

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    )..addListener(() => setState(() {}));

    // The score starts here and carries unbroken into the cinematic.
    ThemeMusicService.instance.start();

    _progressController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => const SplashScreen(),
            transitionsBuilder: (context, anim1, anim2, child) {
              return FadeTransition(opacity: anim1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final progress = _progressAnimation.value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: HogwartsColors.midnight,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Night sky
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    HogwartsColors.midnight,
                    HogwartsColors.deepNight,
                    HogwartsColors.duskBlue,
                  ],
                ),
              ),
            ),

            // Stars, drifting mist, and a distant castle silhouette
            AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _NightPainter(
                    drift: _ambientController.value,
                    reveal: progress,
                  ),
                  size: size,
                );
              },
            ),

            // Vignette
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.95,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.68),
                  ],
                ),
              ),
            ),

            // ─── Crest & Title ───────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _WaxSealCrest(shimmer: _ambientController)
                      .animate()
                      .scale(duration: 900.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 700.ms),

                  const SizedBox(height: 22),

                  Text(
                    'KNOWLEDGEVERSE',
                    style: HogwartsText.display(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6.0,
                      color: HogwartsColors.candle,
                      shadows: HogwartsText.glow(blur: 24, alpha: 0.5),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 900.ms).slideY(
                        begin: 0.25,
                      ),

                  const SizedBox(height: 12),

                  // Gold rule with a diamond, like a chapter heading
                  SizedBox(
                    width: 260,
                    child: Row(
                      children: [
                        const Expanded(child: _GoldRule(flip: false)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Transform.rotate(
                            angle: math.pi / 4,
                            child: Container(
                              width: 5,
                              height: 5,
                              color: HogwartsColors.gold,
                            ),
                          ),
                        ),
                        const Expanded(child: _GoldRule(flip: true)),
                      ],
                    ),
                  ).animate().fadeIn(delay: 550.ms),

                  const SizedBox(height: 10),

                  Text(
                    'A SCHOOL OF WITCHCRAFT AND LEARNING',
                    style: HogwartsText.display(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                      color: HogwartsColors.parchmentDim,
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),

            // ─── Bottom Loading ──────────────────────────────────────
            Positioned(
              bottom: 34,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: HogwartsColors.gold, size: 13),
                      const SizedBox(width: 8),
                      Text(
                        _statusFor(progress),
                        style: HogwartsText.scroll(
                          fontSize: 13,
                          color: HogwartsColors.parchment,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: HogwartsText.display(
                          fontSize: 12,
                          letterSpacing: 1.0,
                          color: HogwartsColors.candle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Candlelit progress bar in a gold frame
                  Container(
                    width: size.width * 0.55,
                    height: 14,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: HogwartsColors.gold.withValues(alpha: 0.55),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    HogwartsColors.deepGold,
                                    HogwartsColors.candle,
                                    HogwartsColors.candleCore,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: HogwartsColors.candle
                                        .withValues(alpha: 0.7),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldRule extends StatelessWidget {
  const _GoldRule({required this.flip});

  final bool flip;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: flip ? Alignment.centerLeft : Alignment.centerRight,
          end: flip ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            HogwartsColors.gold,
            HogwartsColors.gold.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// Wax-seal crest: a stamped disc quartered by house colours around an H.
class _WaxSealCrest extends StatelessWidget {
  const _WaxSealCrest({required this.shimmer});

  final Animation<double> shimmer;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (context, _) {
        // Slow breathing glow, as if lit by a nearby candle.
        final pulse = 0.72 + 0.28 * math.sin(shimmer.value * math.pi * 2);
        return Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: HogwartsColors.candle.withValues(alpha: 0.30 * pulse),
                blurRadius: 46,
                spreadRadius: 8,
              ),
            ],
          ),
          child: CustomPaint(painter: _CrestPainter(glow: pulse)),
        );
      },
    );
  }
}

class _CrestPainter extends CustomPainter {
  _CrestPainter({required this.glow});

  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Wax disc
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF6B1414),
    );
    canvas.drawCircle(
      center,
      radius - 3,
      Paint()..color = const Color(0xFF8B1A1A),
    );

    // Gold rim
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = HogwartsColors.gold.withValues(alpha: 0.85 * glow),
    );

    // Quartered shield in house colours
    const houses = [
      HogwartsColors.gryffindorRed,
      HogwartsColors.slytherinGreen,
      HogwartsColors.ravenclawBlue,
      HogwartsColors.hufflepuffYellow,
    ];
    final shieldRadius = radius * 0.60;
    for (var i = 0; i < 4; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: shieldRadius),
        -math.pi / 2 + i * math.pi / 2,
        math.pi / 2,
        true,
        Paint()..color = houses[i].withValues(alpha: 0.92),
      );
    }

    // Dividing cross
    final divider = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = HogwartsColors.gold.withValues(alpha: 0.7);
    canvas.drawLine(
      center.translate(-shieldRadius, 0),
      center.translate(shieldRadius, 0),
      divider,
    );
    canvas.drawLine(
      center.translate(0, -shieldRadius),
      center.translate(0, shieldRadius),
      divider,
    );
    canvas.drawCircle(
      center,
      shieldRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = HogwartsColors.gold.withValues(alpha: 0.9 * glow),
    );

    // Central boss over the quarters
    canvas.drawCircle(
      center,
      shieldRadius * 0.40,
      Paint()..color = const Color(0xFF2A0A0A),
    );
    canvas.drawCircle(
      center,
      shieldRadius * 0.40,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = HogwartsColors.gold.withValues(alpha: 0.85),
    );

    _drawH(canvas, center, shieldRadius * 0.26);
  }

  /// Serif "H" drawn as strokes — avoids pulling a text painter into paint().
  void _drawH(Canvas canvas, Offset center, double s) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.30
      ..strokeCap = StrokeCap.square
      ..color = HogwartsColors.candle.withValues(alpha: 0.95 * glow);

    canvas.drawLine(
      center.translate(-s * 0.62, -s),
      center.translate(-s * 0.62, s),
      paint,
    );
    canvas.drawLine(
      center.translate(s * 0.62, -s),
      center.translate(s * 0.62, s),
      paint,
    );
    canvas.drawLine(
      center.translate(-s * 0.62, 0),
      center.translate(s * 0.62, 0),
      paint,
    );
    // Serifs
    final serif = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.16
      ..color = HogwartsColors.candle.withValues(alpha: 0.95 * glow);
    for (final dy in [-s, s]) {
      canvas.drawLine(
        center.translate(-s * 0.92, dy),
        center.translate(-s * 0.32, dy),
        serif,
      );
      canvas.drawLine(
        center.translate(s * 0.32, dy),
        center.translate(s * 0.92, dy),
        serif,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CrestPainter old) => old.glow != glow;
}

/// Starfield, drifting mist and the castle on the horizon.
class _NightPainter extends CustomPainter {
  _NightPainter({required this.drift, required this.reveal});

  final double drift;
  final double reveal;

  static final math.Random _rng = math.Random(981204);
  static final List<double> _x = List.generate(110, (_) => _rng.nextDouble());
  static final List<double> _y = List.generate(110, (_) => _rng.nextDouble());
  static final List<double> _mag = List.generate(110, (_) => _rng.nextDouble());

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stars
    final paint = Paint();
    for (var i = 0; i < _x.length; i++) {
      final twinkle =
          0.55 + 0.45 * math.sin(drift * math.pi * 2 * (1.2 + _mag[i]) + i);
      paint.color = Colors.white
          .withValues(alpha: (0.25 + _mag[i] * 0.6) * twinkle);
      canvas.drawCircle(
        Offset(_x[i] * w, _y[i] * h * 0.72),
        0.5 + _mag[i] * 1.4,
        paint,
      );
    }

    // Distant castle ridge — lights come up as loading completes.
    final ridgeY = h * 0.80;
    final silhouette = Paint()..color = HogwartsColors.stoneDark;
    final path = Path()..moveTo(0, h);

    // Rolling ground with a cluster of towers in the middle distance.
    path.lineTo(0, ridgeY + 18);
    for (var i = 0; i <= 40; i++) {
      final t = i / 40;
      final x = t * w;
      final hill = math.sin(t * 3.1 + 0.6) * 12 + math.sin(t * 8.3) * 5;
      path.lineTo(x, ridgeY + 14 - hill);
    }
    path
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, silhouette);

    // Towers
    const towers = [
      [0.40, 54.0, 15.0],
      [0.455, 84.0, 13.0],
      [0.51, 44.0, 17.0],
      [0.565, 68.0, 12.0],
      [0.62, 38.0, 15.0],
    ];
    for (var i = 0; i < towers.length; i++) {
      final cx = towers[i][0] * w;
      final th = towers[i][1];
      final tw = towers[i][2];
      final body = Rect.fromLTRB(cx - tw / 2, ridgeY - th, cx + tw / 2, ridgeY + 6);
      canvas.drawRect(body, silhouette);
      // Spire
      canvas.drawPath(
        Path()
          ..moveTo(body.left - 2, body.top)
          ..lineTo(cx, body.top - tw * 1.3)
          ..lineTo(body.right + 2, body.top)
          ..close(),
        silhouette,
      );

      // Windows warm up in step with the progress bar.
      final lit = ((reveal * 1.5) - i * 0.12).clamp(0.0, 1.0);
      if (lit <= 0) continue;
      final flicker = 0.8 + 0.2 * math.sin(drift * math.pi * 2 * 3 + i * 2.1);
      final rows = (th / 20).floor();
      for (var r = 0; r < rows; r++) {
        final rect = Rect.fromLTWH(cx - 2.4, ridgeY - 14 - r * 18, 4.8, 6);
        canvas.drawRect(
          rect,
          Paint()
            ..color =
                HogwartsColors.candle.withValues(alpha: 0.85 * lit * flicker),
        );
        canvas.drawRect(
          rect.inflate(3),
          Paint()
            ..color = HogwartsColors.emberOrange
                .withValues(alpha: 0.30 * lit * flicker)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
    }

    // Ground mist over the ridge
    final mist = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    for (var i = 0; i < 4; i++) {
      final speed = 0.22 + i * 0.14;
      final x = ((drift * speed + i * 0.3) % 1.3) * (w + 360) - 180;
      mist.color =
          HogwartsColors.moonHaze.withValues(alpha: 0.16 - i * 0.025);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, ridgeY + 10 + i * 9),
            width: 300 - i * 26,
            height: 30 - i * 3,
          ),
          const Radius.circular(999),
        ),
        mist,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NightPainter old) =>
      old.drift != drift || old.reveal != reveal;
}
