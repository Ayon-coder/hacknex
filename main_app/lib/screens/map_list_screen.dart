import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/game_assets.dart';
import '../game/buildings/building_data.dart';
import '../game/managers/building_manager.dart';
import '../theme/app_theme.dart';
import 'subject_dashboard_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pixel-Art Learn / Map List Screen
// Implements the adventure game / island world aesthetic matching
// WorldScreen, LeaderboardScreen, KnowledgeProfileScreen, and RankProgressScreen.
// ─────────────────────────────────────────────────────────────────────────────

class MapListScreen extends StatefulWidget {
  final VoidCallback? onBackToWorld;

  const MapListScreen({super.key, this.onBackToWorld});

  @override
  State<MapListScreen> createState() => _MapListScreenState();
}

class _MapListScreenState extends State<MapListScreen>
    with TickerProviderStateMixin {
  String _filter = 'All';
  AnimationController? _particleCtrl;
  AnimationController? _glowCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void reassemble() {
    super.reassemble();
    _initControllers();
  }

  void _initControllers() {
    _particleCtrl ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _glowCtrl ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _particleCtrl?.dispose();
    _glowCtrl?.dispose();
    super.dispose();
  }

  void _handleSubjectTap(BuildingData building) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectDashboardScreen(
          subjectName: building.name,
          themeColor: building.themeColor,
        ),
      ),
    );
  }

  List<BuildingData> _filteredBuildings(List<BuildingData> all) {
    if (_filter == 'Calculus') {
      return all
          .where((b) =>
              b.name.contains('Derivation') || b.name.contains('Integration'))
          .toList();
    }
    if (_filter == 'Foundation') {
      return all
          .where((b) =>
              b.name.contains('Algebra') ||
              b.name.contains('Geometry') ||
              b.name.contains('Arithmetic') ||
              b.name.contains('Trigonometry'))
          .toList();
    }
    if (_filter == 'Active') {
      return all.where((b) => b.unlocked && b.currentXp > 0).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    _initControllers();
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Splash background ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // ── Dark radial gradient overlay for game HUD feel ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.76),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating pixel particles ──
          AnimatedBuilder(
            animation: _particleCtrl!,
            builder: (context, _) => CustomPaint(
              painter: _PixelParticlePainter(
                progress: _particleCtrl!.value,
                size: size,
              ),
              size: size,
            ),
          ),

          // ── Main scrollable content ──
          SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: BuildingManager(),
              builder: (context, _) {
                final all = BuildingManager().allBuildings;
                final buildings = _filteredBuildings(all);
                final totalXp =
                    all.fold<int>(0, (sum, b) => sum + b.currentXp);
                final unlockedCount = all.where((b) => b.unlocked).length;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 850;
                    final horizontalPadding = isWide ? 36.0 : 18.0;

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: CustomScrollView(
                          slivers: [
                            // ── Header Section ──
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  16,
                                  horizontalPadding,
                                  14,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Back button & top navigation
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _PixelBackButton(
                                          label: 'BACK TO WORLD',
                                          onTap: () {
                                            if (widget.onBackToWorld != null) {
                                              widget.onBackToWorld!();
                                            } else {
                                              Navigator.of(context).maybePop();
                                            }
                                          },
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              UiAssets.iconsQuestScrollIcon,
                                              width: 20,
                                              height: 20,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.book_rounded,
                                                color: Color(0xFFFFD167),
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'CURRICULUM',
                                              style: GoogleFonts.pressStart2p(
                                                fontSize: 7.5,
                                                color: const Color(0xFFF9E2AF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // Screen Title Banner
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0D1F2D),
                                            border: Border.all(
                                              color: const Color(0xFF6B5A3E),
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Image.asset(
                                            UiAssets.iconsGoldenStarBadgeIcon,
                                            width: 26,
                                            height: 26,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                              Icons.auto_stories_rounded,
                                              color: Color(0xFFFFD167),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'MATHEMATICS REALMS',
                                                style: GoogleFonts.pressStart2p(
                                                  fontSize: 12,
                                                  color:
                                                      const Color(0xFFF9E2AF),
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black
                                                          .withValues(alpha: 0.8),
                                                      offset:
                                                          const Offset(2, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Explore the syllabus and master core concepts for every house',
                                                style: GoogleFonts.pressStart2p(
                                                  fontSize: 6.5,
                                                  color: Colors.white70,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // ── Realm Overview Banner ──
                                    _PixelRealmOverviewBanner(
                                      totalRealms: all.length,
                                      unlockedRealms: unlockedCount,
                                      totalXp: totalXp,
                                      glowAnim: _glowCtrl!,
                                    ),
                                    const SizedBox(height: 16),

                                    // ── Filter Pills / Tabs ──
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _PixelFilterTab(
                                            label: 'ALL HOUSES (${all.length})',
                                            isSelected: _filter == 'All',
                                            onTap: () => setState(
                                                () => _filter = 'All'),
                                          ),
                                          const SizedBox(width: 8),
                                          _PixelFilterTab(
                                            label: 'CALCULUS',
                                            isSelected: _filter == 'Calculus',
                                            onTap: () => setState(
                                                () => _filter = 'Calculus'),
                                          ),
                                          const SizedBox(width: 8),
                                          _PixelFilterTab(
                                            label: 'FOUNDATION',
                                            isSelected: _filter == 'Foundation',
                                            onTap: () => setState(
                                                () => _filter = 'Foundation'),
                                          ),
                                          const SizedBox(width: 8),
                                          _PixelFilterTab(
                                            label: 'IN PROGRESS',
                                            isSelected: _filter == 'Active',
                                            onTap: () => setState(
                                                () => _filter = 'Active'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // ── Grass Heading Strip ──
                                    _GrassHeadingStrip(
                                      title: 'CAMPUS HOUSES',
                                      subtitle: '${buildings.length} REALMS',
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            ),

                            // ── Districts Grid / List ──
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                0,
                                horizontalPadding,
                                kNavBarReserve + 16,
                              ),
                              sliver: isWide
                                  ? SliverGrid(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 18,
                                        mainAxisSpacing: 18,
                                        mainAxisExtent: 388,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) =>
                                            _PixelHouseSyllabusCard(
                                          building: buildings[index],
                                          onTap: () => _handleSubjectTap(
                                              buildings[index]),
                                        ),
                                        childCount: buildings.length,
                                      ),
                                    )
                                  : SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 18),
                                          child: _PixelHouseSyllabusCard(
                                            building: buildings[index],
                                            onTap: () => _handleSubjectTap(
                                                buildings[index]),
                                          ),
                                        ),
                                        childCount: buildings.length,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SYLLABUS DATA HELPER
// ═══════════════════════════════════════════════════════════════════════════

class _HouseSyllabusInfo {
  final String imagePath;
  final String syllabusTitle;
  final List<String> topics;

  const _HouseSyllabusInfo({
    required this.imagePath,
    required this.syllabusTitle,
    required this.topics,
  });
}

_HouseSyllabusInfo _getHouseSyllabus(String name) {
  final n = name.toLowerCase();
  if (n.contains('derivation')) {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_derivation.jpg',
      syllabusTitle: 'Differential Calculus & Derivatives',
      topics: [
        'Tangents & Slopes',
        'Instantaneous Rates',
        'Power & Chain Rule',
        'Optimization',
      ],
    );
  } else if (n.contains('integration')) {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_integration.jpg',
      syllabusTitle: 'Integral Calculus & Area',
      topics: [
        'Definite Integrals',
        'Area Under Curves',
        'Riemann Sums',
        'Antiderivatives',
      ],
    );
  } else if (n.contains('trigonometry')) {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_trigonometry.jpg',
      syllabusTitle: 'Trigonometry & Unit Circle',
      topics: [
        'Unit Circle (0-360°)',
        'Sin, Cos, Tan Ratios',
        'Radians & Degrees',
        'Wave Functions',
      ],
    );
  } else if (n.contains('algebra')) {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_algebra.jpg',
      syllabusTitle: 'Algebra & Equations',
      topics: [
        'Simple Equations',
        'Solving for x',
        'Quadratic Formula',
        'Parabola Curves',
      ],
    );
  } else if (n.contains('geometry')) {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_geometry.jpg',
      syllabusTitle: 'Geometry & Angles',
      topics: [
        'Lines & Transversals',
        'Triangles & Angles',
        'Circles & Area (πr²)',
        '3D Polygons',
      ],
    );
  } else {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_arithmetic.jpg',
      syllabusTitle: 'Arithmetic & Number Systems',
      topics: [
        'Integers & Number Line',
        'Fractions & Decimals',
        'PEMDAS Order',
        'Prime Numbers',
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL HOUSE SYLLABUS CARD
// ═══════════════════════════════════════════════════════════════════════════

class _PixelHouseSyllabusCard extends StatelessWidget {
  const _PixelHouseSyllabusCard({
    required this.building,
    required this.onTap,
  });

  final BuildingData building;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = building.progressRatio;
    final color = building.themeColor;
    final syllabus = _getHouseSyllabus(building.name);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F2D),
        border: Border.all(
          color: color,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 14,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Picture Banner with Pixel Border & Tags ──
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF6B5A3E),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Image.asset(
                      syllabus.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: color.withValues(alpha: 0.2),
                        child: Center(
                          child: Text(
                            building.name,
                            style: GoogleFonts.pressStart2p(
                              color: color,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Level Badge on picture
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1F2D),
                        border: Border.all(
                          color: color,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            offset: const Offset(1, 1),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        'LVL ${building.level}',
                        style: GoogleFonts.pressStart2p(
                          fontWeight: FontWeight.w900,
                          fontSize: 6.5,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  // Lock/Unlock badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: building.unlocked
                            ? const Color(0xFF2A5A3A)
                            : const Color(0xFF442020),
                        border: Border.all(
                          color: building.unlocked
                              ? const Color(0xFF7ACB74)
                              : const Color(0xFFE57373),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            building.unlocked
                                ? Icons.lock_open_rounded
                                : Icons.lock_rounded,
                            size: 10,
                            color: building.unlocked
                                ? const Color(0xFF86E2A5)
                                : const Color(0xFFFFCDD2),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            building.unlocked ? 'OPEN' : 'LOCKED',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 5.5,
                              color: building.unlocked
                                  ? const Color(0xFF86E2A5)
                                  : const Color(0xFFFFCDD2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Card Content Area ──
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // House Name + Subject
                    Row(
                      children: [
                        Icon(building.icon, size: 16, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            building.name.toUpperCase(),
                            style: GoogleFonts.pressStart2p(
                              fontSize: 9.5,
                              color: const Color(0xFFF9E2AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      syllabus.syllabusTitle,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 6.5,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    Text(
                      building.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 6,
                        height: 1.4,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Topic Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: syllabus.topics.map((topic) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: const Color(0xFF6B5A3E).withValues(alpha: 0.7),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            topic,
                            style: GoogleFonts.pressStart2p(
                              fontSize: 5.5,
                              color: const Color(0xFFF9E2AF),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Progress Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${building.currentXp} / ${building.xpRequired} XP',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}% MASTERED',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07121C),
                        border: Border.all(
                          color: const Color(0xFF6B5A3E),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress.clamp(0.02, 1.0),
                          child: Container(color: color),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Footer Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${building.lessonsAvailable} LESSONS',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: Colors.white54,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.18),
                            border: Border.all(
                              color: color,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                offset: const Offset(1, 1),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ENTER REALM',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 6.5,
                                  color: const Color(0xFFF9E2AF),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '▶',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 7,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL REALM OVERVIEW BANNER
// ═══════════════════════════════════════════════════════════════════════════

class _PixelRealmOverviewBanner extends StatelessWidget {
  const _PixelRealmOverviewBanner({
    required this.totalRealms,
    required this.unlockedRealms,
    required this.totalXp,
    required this.glowAnim,
  });

  final int totalRealms;
  final int unlockedRealms;
  final int totalXp;
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (context, child) {
        final glow = 0.12 + glowAnim.value * 0.14;
        return _PixelPanel(
          borderColor: const Color(0xFF3D6B4F),
          glowColor: const Color(0xFF7ACB74),
          glowAlpha: glow,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: child!,
        );
      },
      child: Row(
        children: [
          Expanded(
            child: _BannerMetric(
              label: 'REALMS OPEN',
              value: '$unlockedRealms / $totalRealms',
              accentColor: const Color(0xFF86E2A5),
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: const Color(0xFF6B5A3E).withValues(alpha: 0.7),
          ),
          Expanded(
            child: _BannerMetric(
              label: 'CAMPUS XP',
              value: '$totalXp XP',
              accentColor: const Color(0xFFFFD167),
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: const Color(0xFF6B5A3E).withValues(alpha: 0.7),
          ),
          Expanded(
            child: _BannerMetric(
              label: 'CURRICULUM',
              value: 'MATH',
              accentColor: const Color(0xFF9FD9FF),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerMetric extends StatelessWidget {
  const _BannerMetric({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.pressStart2p(
            color: accentColor,
            fontSize: 9.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            color: Colors.white60,
            fontSize: 5.5,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL FILTER TAB
// ═══════════════════════════════════════════════════════════════════════════

class _PixelFilterTab extends StatelessWidget {
  const _PixelFilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD167)
              : const Color(0xFF0D1F2D),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD167)
                : const Color(0xFF6B5A3E),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFFFD167).withValues(alpha: 0.35),
                blurRadius: 10,
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 6.5,
            color: isSelected
                ? const Color(0xFF4A3400)
                : const Color(0xFFF9E2AF),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SHARED PIXEL PRIMITIVES
// ═══════════════════════════════════════════════════════════════════════════

class _PixelPanel extends StatelessWidget {
  const _PixelPanel({
    required this.child,
    this.borderColor = const Color(0xFF6B5A3E),
    this.glowColor,
    this.glowAlpha = 0.0,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color borderColor;
  final Color? glowColor;
  final double glowAlpha;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F2D),
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          if (glowColor != null && glowAlpha > 0)
            BoxShadow(
              color: glowColor!.withValues(alpha: glowAlpha),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PixelBackButton extends StatelessWidget {
  const _PixelBackButton({required this.onTap, this.label = 'BACK'});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2744),
          border: Border.all(color: const Color(0xFF6B5A3E), width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back, color: Color(0xFFF9E2AF), size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: const Color(0xFFF9E2AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrassHeadingStrip extends StatelessWidget {
  const _GrassHeadingStrip({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.6),
                  Colors.white.withValues(alpha: 0.3),
                ],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                TileAssets.grassTileTwoX,
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeatX,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF2A5A3A),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF3D6B4F),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A3D2A).withValues(alpha: 0.6),
                  offset: const Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Image.asset(
                  NatureAssets.bushesLeafyBush,
                  width: 26,
                  height: 26,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF7ACB74),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: const Color(0xFFF9E2AF),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PixelParticlePainter extends CustomPainter {
  _PixelParticlePainter({required this.progress, required this.size});

  final double progress;
  final Size size;

  static final List<math.Point<double>> _basePoints = List.generate(
    28,
    (i) => math.Point(
      (i * 37.0 + 13.0) % 1000 / 1000,
      (i * 53.0 + 29.0) % 1000 / 1000,
    ),
  );

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final goldPaint = Paint()..color = const Color(0xFFFFD167).withValues(alpha: 0.35);
    final greenPaint = Paint()..color = const Color(0xFF7ACB74).withValues(alpha: 0.25);

    for (int i = 0; i < _basePoints.length; i++) {
      final base = _basePoints[i];
      final yOffset = (base.y - progress + 1.0) % 1.0;
      final xOffset = (base.x + math.sin((progress * 2 * math.pi) + i) * 0.03) % 1.0;

      final px = xOffset * canvasSize.width;
      final py = yOffset * canvasSize.height;

      final paint = i % 2 == 0 ? goldPaint : greenPaint;
      final pSize = (i % 3 == 0) ? 4.0 : 3.0;

      canvas.drawRect(
        Rect.fromLTWH(px, py, pSize, pSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelParticlePainter old) => true;
}
