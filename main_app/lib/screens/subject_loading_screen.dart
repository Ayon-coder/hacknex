import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/hogwarts_theme.dart';
import 'home_screen.dart';
import 'world_archipelago_screen.dart';

/// Dedicated Subject Loading Screen displayed when entering a subject academy.
/// Includes subject artwork, animated progress bar, magical particles, gameplay tips,
/// and smooth transition into the Flame 2D Academy scene.
class SubjectLoadingScreen extends StatefulWidget {
  final SubjectIslandData island;

  const SubjectLoadingScreen({
    super.key,
    required this.island,
  });

  @override
  State<SubjectLoadingScreen> createState() => _SubjectLoadingScreenState();
}

class _SubjectLoadingScreenState extends State<SubjectLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _particleController;
  late final Animation<double> _progressAnimation;

  static const List<String> _gameplayTips = [
    'Tip: Every lesson you master raises another stone tower in your academy.',
    'Tip: Use the virtual joystick or tap anywhere on connected roads to navigate.',
    'Tip: Upgrade your buildings to Level 3 to unlock golden magical circles.',
    'Tip: Earn Focus XP and Gems by completing daily interactive quests.',
    'Tip: Visit the Library Tower to read computer science and mathematical lore.',
    'Tip: Test your speed in the Duel Arena for timed code challenges.',
  ];

  late final String _currentTip;

  static const List<String> _loadingStatuses = [
    'Unsealing academy gates...',
    'Charming moving staircases...',
    'Preparing subject curriculum...',
    'Waking enchanted portraits...',
    'Raising stone towers...',
    'Your academy is ready.',
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
    _currentTip = _gameplayTips[math.Random().nextInt(_gameplayTips.length)];

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    )..addListener(() => setState(() {}));

    _startLoadingSequence();
  }

  Future<void> _startLoadingSequence() async {
    // Save selected subject as active subject in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeSubject', widget.island.subject);

    _progressController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => const HomeScreen(),
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
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final progress = _progressAnimation.value;

    return Scaffold(
      backgroundColor: HogwartsColors.midnight,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Theme-tinted Atmospheric Background Gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  HogwartsColors.midnight,
                  widget.island.themeColor.withValues(alpha: 0.25),
                  HogwartsColors.deepNight,
                ],
              ),
            ),
          ),

          // 2. Floating Magical Particles Painter
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                painter: _SubjectLoadingParticlesPainter(
                  drift: _particleController.value,
                  themeColor: widget.island.themeColor,
                ),
                size: size,
              );
            },
          ),

          // 3. Center Subject Badge & Artwork
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Subject Icon Crest
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: widget.island.themeColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.island.themeColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: widget.island.themeColor.withValues(alpha: 0.5),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.island.icon,
                    size: 48,
                    color: widget.island.themeColor,
                  ),
                ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),

                const SizedBox(height: 20),

                // Subject Academy Title
                Text(
                  widget.island.academyTitle.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: widget.island.themeColor,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                const SizedBox(height: 6),

                // Subtitle
                Text(
                  widget.island.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: HogwartsColors.parchmentDim,
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 24),

                // Subject Highlights Pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.island.highlights.map((h) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: widget.island.themeColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        h,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: widget.island.themeColor,
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 450.ms),
              ],
            ),
          ),

          // 4. Bottom Loading Bar & Gameplay Tip
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tip Box
                Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: HogwartsColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _currentTip,
                    textAlign: TextAlign.center,
                    style: HogwartsText.scroll(
                      fontSize: 12,
                      color: HogwartsColors.parchment,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 16),

                // Progress Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            widget.island.themeColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _statusFor(progress),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: widget.island.themeColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Progress Bar
                Container(
                  width: size.width * 0.6,
                  height: 12,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: widget.island.themeColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.island.themeColor,
                          boxShadow: [
                            BoxShadow(
                              color: widget.island.themeColor,
                              blurRadius: 10,
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
        ],
      ),
    );
  }
}

class _SubjectLoadingParticlesPainter extends CustomPainter {
  final double drift;
  final Color themeColor;

  _SubjectLoadingParticlesPainter({
    required this.drift,
    required this.themeColor,
  });

  static final math.Random _rng = math.Random(777);
  static final List<Offset> _pts = List.generate(
      45, (_) => Offset(_rng.nextDouble(), _rng.nextDouble()));

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final p = Paint();
    for (int i = 0; i < _pts.length; i++) {
      final pt = _pts[i];
      final y = ((pt.dy - drift * 0.2) % 1.0) * h;
      final alpha = 0.3 + 0.5 * math.sin(drift * math.pi * 2 * 3 + i);
      p.color = themeColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(pt.dx * w, y), 1.5 + (i % 3), p);
    }
  }

  @override
  bool shouldRepaint(covariant _SubjectLoadingParticlesPainter old) => true;
}
