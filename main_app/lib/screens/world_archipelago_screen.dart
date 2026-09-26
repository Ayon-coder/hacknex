import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/hogwarts_theme.dart';
import 'subject_loading_screen.dart';
import 'parent_login_screen.dart';

/// Subject Island Specification Model for the World Map Archipelago
class SubjectIslandData {
  final String id;
  final String name;
  final String academyTitle;
  final String subject;
  final IconData icon;
  final Color themeColor;
  final Color textColor;
  final Offset relativeOffset; // Coordinates on map canvas
  final String description;
  final List<String> highlights;

  const SubjectIslandData({
    required this.id,
    required this.name,
    required this.academyTitle,
    required this.subject,
    required this.icon,
    required this.themeColor,
    required this.textColor,
    required this.relativeOffset,
    required this.description,
    required this.highlights,
  });
}

/// World Map Screen featuring a magical floating archipelago.
/// Contains separate floating islands representing each subject,
/// animated waterfalls, glowing magical particles, and smooth camera zoom transitions.
class WorldArchipelagoScreen extends StatefulWidget {
  const WorldArchipelagoScreen({super.key});

  @override
  State<WorldArchipelagoScreen> createState() => _WorldArchipelagoScreenState();
}

class _WorldArchipelagoScreenState extends State<WorldArchipelagoScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bobController;
  late final AnimationController _particleController;

  Set<String> _unlockedSubjects = {'Mathematics'};
  SubjectIslandData? _selectedIsland;
  bool _isZooming = false;
  Offset _zoomCenter = Offset.zero;

  static const List<SubjectIslandData> islands = [
    SubjectIslandData(
      id: 'cs',
      name: 'Computer Science',
      academyTitle: 'Coding Tower Academy',
      subject: 'Programming',
      icon: Icons.computer_rounded,
      themeColor: Color(0xFF89B4FA),
      textColor: Color(0xFF181825),
      relativeOffset: Offset(0.18, 0.32), // Left forest area
      description:
          'Master programming logic, Dart syntax, algorithms, and software architecture.',
      highlights: ['Dart & Flutter', 'Algorithms', 'Data Structures'],
    ),
    SubjectIslandData(
      id: 'math',
      name: 'Mathematics',
      academyTitle: 'Math House Sanctuary',
      subject: 'Mathematics',
      icon: Icons.calculate_rounded,
      themeColor: Color(0xFF7ACB74),
      textColor: Color(0xFF005611),
      relativeOffset: Offset(0.50, 0.28), // Central castle
      description:
          'Conquer algebra, calculus, geometry, and numerical logic puzzles.',
      highlights: ['Calculus & Vectors', 'Geometry', 'Number Theory'],
    ),
    SubjectIslandData(
      id: 'astronomy',
      name: 'Physics & Space',
      academyTitle: 'Astronomy Tower',
      subject: 'Physics',
      icon: Icons.star_rounded,
      themeColor: Color(0xFF89DCEB),
      textColor: Color(0xFF00515a),
      relativeOffset: Offset(0.78, 0.25), // Mountain peaks
      description:
          'Explore astrophysics, mechanics, gravity, space science, and kinetic simulations.',
      highlights: ['Orbital Mechanics', 'Quantum Theory', 'Optics'],
    ),
    SubjectIslandData(
      id: 'chemistry',
      name: 'Chemistry',
      academyTitle: 'Potion & Alchemy Lab',
      subject: 'Chemistry',
      icon: Icons.science_rounded,
      themeColor: Color(0xFFA6E3A1),
      textColor: Color(0xFF1B6D22),
      relativeOffset: Offset(0.28, 0.55), // Green meadow
      description:
          'Conduct chemical reaction simulations, potion brewing, and periodic table experiments.',
      highlights: ['Potion Brewing', 'Organic Reactions', 'Atomic Structure'],
    ),
    SubjectIslandData(
      id: 'arena',
      name: 'PvP Duel Arena',
      academyTitle: 'Challengers Arena',
      subject: 'PvP Battles',
      icon: Icons.sports_mma_rounded,
      themeColor: Color(0xFFFAB387),
      textColor: Color(0xFF765900),
      relativeOffset: Offset(0.50, 0.50), // Central hub
      description:
          'Test your coding speed and problem-solving skills in real-time timed duels.',
      highlights: ['Timed Quizzes', 'Live Duels', 'Global Leaderboard'],
    ),
    SubjectIslandData(
      id: 'library',
      name: 'Library & Lore',
      academyTitle: 'The Grand Library',
      subject: 'Literature',
      icon: Icons.menu_book_rounded,
      themeColor: Color(0xFFF38BA8),
      textColor: Color(0xFF93000a),
      relativeOffset: Offset(0.75, 0.52), // River bend
      description:
          'Study computer science history, classical research literature, and ancient scrolls.',
      highlights: ['Historical Archives', 'CS Classics', 'Spell Books'],
    ),
    SubjectIslandData(
      id: 'biology',
      name: 'Biology & Life',
      academyTitle: 'Bio Conservatory',
      subject: 'Biology',
      icon: Icons.eco_rounded,
      themeColor: Color(0xFF94E2D5),
      textColor: Color(0xFF00515a),
      relativeOffset: Offset(0.35, 0.75), // Waterfall edge
      description:
          'Discover cellular genetics, ecosystem balance, and organic biological structures.',
      highlights: ['Cellular Biology', 'Genetics', 'Ecology'],
    ),
    SubjectIslandData(
      id: 'history',
      name: 'History & Civics',
      academyTitle: 'Royal Archives Hall',
      subject: 'History',
      icon: Icons.castle_rounded,
      themeColor: Color(0xFFFFD167),
      textColor: Color(0xFF765900),
      relativeOffset: Offset(0.65, 0.72), // South shore
      description:
          'Uncover the history of computing, ancient civilizations, and societal evolution.',
      highlights: ['Ancient History', 'History of Computing', 'Civic Design'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _loadUnlockedSubjects();
  }

  Future<void> _loadUnlockedSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('selectedSubjects');
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _unlockedSubjects = {'Mathematics'};
      });
    }
  }

  void _onIslandTap(SubjectIslandData island, Size mapSize) {
    if (_isZooming) return;
    if (island.subject != 'Mathematics') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This world is locked. Complete Mathematics first.'),
        ),
      );
      return;
    }

    final islandCenter = Offset(
      mapSize.width * island.relativeOffset.dx,
      mapSize.height * island.relativeOffset.dy,
    );

    setState(() {
      _selectedIsland = island;
      _isZooming = true;
      _zoomCenter = islandCenter;
    });

    // Brief zoom animation before transitioning into Subject Loading Screen
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => SubjectLoadingScreen(island: island),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isZooming = false;
            _selectedIsland = null;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _bobController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-bleed Splash Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_background.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // 2. Dark Vignette Overlay for UI contrast
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),

          // 3. Animated Sky Layer (Stars)
          AnimatedBuilder(
            animation: Listenable.merge([
              _particleController,
              _bobController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _ArchipelagoSkyPainter(
                  particleDrift: _particleController.value,
                  bobValue: _bobController.value,
                ),
                size: size,
              );
            },
          ),

          // 5. Zoom Matrix Transform Wrapper
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            transform: _isZooming
                ? (Matrix4.translationValues(
                    -_zoomCenter.dx * 0.8,
                    -_zoomCenter.dy * 0.8,
                    0.0,
                  )..scaleByDouble(1.8, 1.8, 1.0, 1.0))
                : Matrix4.identity(),
            child: Stack(
              children: [
                // Connecting magical light bridges between islands
                CustomPaint(
                  painter: _MagicalBridgesPainter(
                    islands: islands,
                    mapSize: size,
                    pulse: _bobController.value,
                  ),
                  size: size,
                ),

                // Floating Subject Islands
                ...islands.map((island) {
                  final isUnlocked = island.subject == 'Mathematics';
                  final isSelected = _selectedIsland?.id == island.id;

                  return Positioned(
                    left: size.width * island.relativeOffset.dx - 45,
                    top: size.height * island.relativeOffset.dy - 45,
                    child: _FloatingIslandWidget(
                      island: island,
                      isUnlocked: isUnlocked,
                      isSelected: isSelected,
                      bobAnimation: _bobController,
                      onTap: () => _onIslandTap(island, size),
                    ),
                  );
                }),
              ],
            ),
          ),

          // 6. Top Header HUD Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: HogwartsColors.gold.withValues(alpha: 0.6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: HogwartsColors.candle.withValues(alpha: 0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.public_rounded,
                            color: HogwartsColors.gold,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'KNOWLEDGEVERSE ARCHIPELAGO',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Color(0xFFFFD167),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_unlockedSubjects.length} / ${islands.length} Islands Unlocked',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Parent Portal Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ParentLoginScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.family_restroom,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Parent',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 7. Bottom Instructions Overlay
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: HogwartsColors.candle.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: HogwartsColors.candle,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select a Subject Island to Enter its Academy',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: HogwartsColors.parchment,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ),
        ],
      ),
    );
  }
}

/// 3D Glossy Sphere Level Node — compact floating orb for the world map
class _FloatingIslandWidget extends StatelessWidget {
  final SubjectIslandData island;
  final bool isUnlocked;
  final bool isSelected;
  final Animation<double> bobAnimation;
  final VoidCallback onTap;

  const _FloatingIslandWidget({
    required this.island,
    required this.isUnlocked,
    required this.isSelected,
    required this.bobAnimation,
    required this.onTap,
  });

  static const double _sphereSize = 62.0;

  @override
  Widget build(BuildContext context) {
    final baseColor = isUnlocked ? island.themeColor : const Color(0xFF555566);
    final darkColor = Color.lerp(baseColor, Colors.black, 0.55)!;
    final lightColor = Color.lerp(baseColor, Colors.white, 0.35)!;

    return AnimatedBuilder(
      animation: bobAnimation,
      builder: (context, child) {
        final bobOffset = math.sin(bobAnimation.value * math.pi * 2) * 4.0;
        return Transform.translate(offset: Offset(0, bobOffset), child: child);
      },
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 3D Sphere
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow / selection aura
                  Container(
                    width: _sphereSize + 20,
                    height: _sphereSize + 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withValues(
                            alpha: isSelected ? 0.7 : (isUnlocked ? 0.35 : 0.15),
                          ),
                          blurRadius: isSelected ? 28 : 14,
                          spreadRadius: isSelected ? 6 : 2,
                        ),
                      ],
                    ),
                  ),

                  // Drop shadow beneath sphere
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: _sphereSize * 0.7,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Main 3D Sphere body
                  Container(
                    width: _sphereSize,
                    height: _sphereSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Base color gradient (bottom-lit to top-dark for 3D depth)
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.4),
                        radius: 0.85,
                        colors: [
                          lightColor,
                          baseColor,
                          darkColor,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.7)
                            : baseColor.withValues(alpha: 0.5),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                    ),
                  ),

                  // Specular highlight (top-left shine)
                  Positioned(
                    top: 8,
                    left: 18,
                    child: Container(
                      width: 22,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.65),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Rim light (subtle bottom-right edge)
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: Container(
                      width: 16,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Icon inside the sphere
                  Icon(
                    isUnlocked ? island.icon : Icons.lock_rounded,
                    color: isUnlocked
                        ? island.textColor.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.7),
                    size: isUnlocked ? 26 : 22,
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Subject name label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isUnlocked
                        ? baseColor.withValues(alpha: 0.7)
                        : Colors.grey.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  island.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 8,
                    letterSpacing: 0.4,
                    color: isUnlocked ? Colors.white : Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Painter rendering starfield and sky atmosphere
class _ArchipelagoSkyPainter extends CustomPainter {
  final double particleDrift;
  final double bobValue;

  _ArchipelagoSkyPainter({
    required this.particleDrift,
    required this.bobValue,
  });

  static final math.Random _rng = math.Random(12345);
  static final List<Offset> _stars = List.generate(
    70,
    (_) => Offset(_rng.nextDouble(), _rng.nextDouble() * 0.7),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Stars
    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < _stars.length; i++) {
      final s = _stars[i];
      final twinkle = 0.4 + 0.6 * math.sin(particleDrift * math.pi * 2 * 2 + i);
      starPaint.color = Colors.white.withValues(alpha: 0.3 * twinkle);
      canvas.drawCircle(Offset(s.dx * w, s.dy * h), 1.2, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArchipelagoSkyPainter old) => true;
}

/// Custom Painter rendering magical light bridges connecting subject islands
class _MagicalBridgesPainter extends CustomPainter {
  final List<SubjectIslandData> islands;
  final Size mapSize;
  final double pulse;

  _MagicalBridgesPainter({
    required this.islands,
    required this.mapSize,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Find center hub (Arena)
    final hub = islands.firstWhere((i) => i.id == 'arena');
    final hubPos = Offset(
      mapSize.width * hub.relativeOffset.dx,
      mapSize.height * hub.relativeOffset.dy,
    );

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    for (final target in islands) {
      if (target.id == 'arena') continue;
      final targetPos = Offset(
        mapSize.width * target.relativeOffset.dx,
        mapSize.height * target.relativeOffset.dy,
      );

      final alpha = 0.25 + 0.15 * math.sin(pulse * math.pi * 2);
      linePaint.color = target.themeColor.withValues(alpha: alpha);

      final path = Path()
        ..moveTo(hubPos.dx, hubPos.dy)
        ..quadraticBezierTo(
          (hubPos.dx + targetPos.dx) / 2,
          (hubPos.dy + targetPos.dy) / 2 - 30,
          targetPos.dx,
          targetPos.dy,
        );

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MagicalBridgesPainter old) => true;
}
