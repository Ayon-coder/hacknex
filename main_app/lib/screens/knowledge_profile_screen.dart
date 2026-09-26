import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/game_assets.dart';
import '../game/managers/building_manager.dart';
import '../models/player_profile.dart';
import '../models/rank_progress.dart';
import '../services/student_progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rank_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PixelArt Knowledge Profile – The player character's world/civilization page,
// rendered as an in-game scroll that belongs to the same pixel-art island
// archipelago world.
// ─────────────────────────────────────────────────────────────────────────────

class KnowledgeProfileScreen extends StatefulWidget {
  const KnowledgeProfileScreen({
    super.key,
    this.dummyName,
    this.dummyXp,
    this.dummyLevel,
    this.dummyQuizzes,
  });

  final String? dummyName;
  final int? dummyXp;
  final int? dummyLevel;
  final int? dummyQuizzes;

  @override
  State<KnowledgeProfileScreen> createState() =>
      _KnowledgeProfileScreenState();
}

class _KnowledgeProfileScreenState extends State<KnowledgeProfileScreen>
    with TickerProviderStateMixin {
  late Future<_ProfileData> _data;
  late final AnimationController _particleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();
  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);
  late final AnimationController _bobCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_ProfileData> _load() async {
    if (widget.dummyName != null) {
      return _ProfileData(
        PlayerProfile(
          name: widget.dummyName!,
          grade: 'Grade 7',
          curriculum: 'Mathematics Realm',
          learningGoal:
              'Mastering every theorem and equation in KnowledgeVerse.',
        ),
        StudentProgress(
          quizzesCompleted: widget.dummyQuizzes ?? 12,
          questionsAnswered: (widget.dummyQuizzes ?? 12) * 5,
          correctAnswers: ((widget.dummyQuizzes ?? 12) * 4.6).round(),
        ),
        widget.dummyXp ?? 1250,
      );
    }
    final profile = await PlayerProfile.load() ?? const PlayerProfile();
    final progress = await StudentProgress.load();
    final xp = BuildingManager().allBuildings.fold<int>(
          0,
          (sum, building) => sum + building.currentXp,
        );
    return _ProfileData(profile, progress, xp);
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    _glowCtrl.dispose();
    _bobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

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
          // Dark overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
          ),

          // ── Pixel particles ──
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (context, _) => CustomPaint(
              painter: _PixelParticlePainter(
                progress: _particleCtrl.value,
                size: screenSize,
              ),
              size: screenSize,
            ),
          ),

          // ── Main content ──
          SafeArea(
            bottom: false,
            child: FutureBuilder<_ProfileData>(
              future: _data,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFD167),
                    ),
                  );
                }
                final data = snapshot.data!;
                final name = data.profile.name.trim().isEmpty
                    ? 'Explorer'
                    : data.profile.name;
                final level = 1 + data.xp ~/ 500;
                final nextLevelXp = level * 500;
                final currentLevelProgress = (data.xp % 500) / 500.0;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 850;
                    final hPad = isWide ? 32.0 : 16.0;

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: CustomScrollView(
                          slivers: [
                            // ── Header ──
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    hPad, 12, hPad, 0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Back button
                                    if (widget.dummyName != null)
                                      _PixelBackButton(
                                        onTap: () =>
                                            Navigator.pop(context),
                                      ),
                                    const SizedBox(height: 10),

                                    // Grass heading
                                    _GrassHeadingStrip(
                                      title: 'ISLAND ADVENTURER',
                                      subtitle:
                                          'Character · Districts · Journey',
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ── Main body ──
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                hPad,
                                14,
                                hPad,
                                kNavBarReserve + 16,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: isWide
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Left column
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              children: [
                                                _PixelHeroCard(
                                                  name: name,
                                                  level: level,
                                                  xp: data.xp,
                                                  nextLevelXp: nextLevelXp,
                                                  progressRatio:
                                                      currentLevelProgress,
                                                  grade:
                                                      data.profile.grade,
                                                  glowAnim: _glowCtrl,
                                                  bobAnim: _bobCtrl,
                                                ),
                                                const SizedBox(height: 14),
                                                _PixelRankVoyageCard(
                                                  xp: data.xp,
                                                  streak: data
                                                      .progress.streak,
                                                  quizzes: data.progress
                                                      .quizzesCompleted,
                                                  glowAnim: _glowCtrl,
                                                ),
                                                const SizedBox(height: 14),
                                                _PixelStageMilestonesCard(
                                                  level: level,
                                                ),
                                                const SizedBox(height: 14),
                                                _PixelBioCard(
                                                  profile: data.profile,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Right column
                                          Expanded(
                                            flex: 6,
                                            child: Column(
                                              children: [
                                                _PixelStatsMatrix(
                                                  xp: data.xp,
                                                  quizzes: data.progress
                                                      .quizzesCompleted,
                                                  streak: data
                                                      .progress.streak,
                                                  accuracy: data
                                                      .progress.accuracy,
                                                ),
                                                const SizedBox(height: 14),
                                                _PixelRealmMasteryCard(),
                                                const SizedBox(height: 14),
                                                _PixelBadgesShowcaseCard(
                                                  xp: data.xp,
                                                  quizzes: data.progress
                                                      .quizzesCompleted,
                                                  level: level,
                                                ),
                                                const SizedBox(height: 14),
                                                _PixelUnlockedAreasCard(
                                                  xp: data.xp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          _PixelHeroCard(
                                            name: name,
                                            level: level,
                                            xp: data.xp,
                                            nextLevelXp: nextLevelXp,
                                            progressRatio:
                                                currentLevelProgress,
                                            grade: data.profile.grade,
                                            glowAnim: _glowCtrl,
                                            bobAnim: _bobCtrl,
                                          ),
                                          const SizedBox(height: 14),
                                          _PixelRankVoyageCard(
                                            xp: data.xp,
                                            streak:
                                                data.progress.streak,
                                            quizzes: data.progress
                                                .quizzesCompleted,
                                            glowAnim: _glowCtrl,
                                          ),
                                          const SizedBox(height: 14),
                                          _PixelStatsMatrix(
                                            xp: data.xp,
                                            quizzes: data.progress
                                                .quizzesCompleted,
                                            streak:
                                                data.progress.streak,
                                            accuracy:
                                                data.progress.accuracy,
                                          ),
                                          const SizedBox(height: 14),
                                          _PixelStageMilestonesCard(
                                            level: level,
                                          ),
                                          const SizedBox(height: 14),
                                          _PixelRealmMasteryCard(),
                                          const SizedBox(height: 14),
                                          _PixelBadgesShowcaseCard(
                                            xp: data.xp,
                                            quizzes: data.progress
                                                .quizzesCompleted,
                                            level: level,
                                          ),
                                          const SizedBox(height: 14),
                                          _PixelUnlockedAreasCard(
                                            xp: data.xp,
                                          ),
                                          const SizedBox(height: 14),
                                          _PixelBioCard(
                                            profile: data.profile,
                                          ),
                                        ],
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
//  DATA
// ═══════════════════════════════════════════════════════════════════════════

class _ProfileData {
  const _ProfileData(this.profile, this.progress, this.xp);
  final PlayerProfile profile;
  final StudentProgress progress;
  final int xp;
}

// ═══════════════════════════════════════════════════════════════════════════
//  SHARED PIXEL PRIMITIVES
// ═══════════════════════════════════════════════════════════════════════════

/// Pixel‐bordered dark panel used for all cards
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

/// Section heading inside a pixel panel
class _PixelSectionTitle extends StatelessWidget {
  const _PixelSectionTitle({required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          color: const Color(0xFF7ACB74),
          margin: const EdgeInsets.only(right: 8),
        ),
        Text(
          title,
          style: GoogleFonts.pressStart2p(
            fontSize: 7,
            color: const Color(0xFFF9E2AF),
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Text(
            trailing!,
            style: GoogleFonts.pressStart2p(
              fontSize: 6,
              color: const Color(0xFF7ACB74),
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL PARTICLE PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _PixelParticlePainter extends CustomPainter {
  final double progress;
  final Size size;
  _PixelParticlePainter({required this.progress, required this.size});

  static final _rng = math.Random(77);
  static final _particles = List.generate(
    40,
    (_) => Offset(_rng.nextDouble(), _rng.nextDouble()),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final drift = math.sin(progress * math.pi * 2 + i * 1.7) * 0.015;
      final alpha = 0.12 + 0.22 * math.sin(progress * math.pi * 2 * 1.3 + i);
      final isGold = i % 4 == 0;
      paint.color = (isGold
              ? const Color(0xFFFFD167)
              : const Color(0xFF94E2D5))
          .withValues(alpha: alpha.clamp(0.04, 0.45));
      canvas.drawRect(
        Rect.fromLTWH(
          (p.dx + drift) * size.width,
          (p.dy + progress * 0.1) % 1.0 * size.height,
          3,
          3,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelParticlePainter old) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL BACK BUTTON
// ═══════════════════════════════════════════════════════════════════════════

class _PixelBackButton extends StatelessWidget {
  const _PixelBackButton({required this.onTap});
  final VoidCallback onTap;

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
              'BACK',
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

// ═══════════════════════════════════════════════════════════════════════════
//  GRASS HEADING STRIP
// ═══════════════════════════════════════════════════════════════════════════

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
            height: 50,
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
                  width: 28,
                  height: 28,
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
                    fontSize: 6,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Decorative grass tufts hanging off the bottom edge
        Positioned(
          bottom: -8,
          left: 30,
          child: Image.asset(
            NatureAssets.flowersTinyGroundSprout,
            width: 16,
            height: 16,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Positioned(
          bottom: -6,
          right: 50,
          child: Image.asset(
            NatureAssets.flowersTinyFlowerCluster,
            width: 14,
            height: 14,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  HERO CHARACTER CARD
// ═══════════════════════════════════════════════════════════════════════════

class _PixelHeroCard extends StatelessWidget {
  const _PixelHeroCard({
    required this.name,
    required this.level,
    required this.xp,
    required this.nextLevelXp,
    required this.progressRatio,
    required this.grade,
    required this.glowAnim,
    required this.bobAnim,
  });

  final String name;
  final int level;
  final int xp;
  final int nextLevelXp;
  final double progressRatio;
  final String grade;
  final Animation<double> glowAnim;
  final Animation<double> bobAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([glowAnim, bobAnim]),
      builder: (context, child) {
        final glow = 0.15 + glowAnim.value * 0.15;
        return _PixelPanel(
          borderColor: const Color(0xFFD4AF37),
          glowColor: const Color(0xFFFFD167),
          glowAlpha: glow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Animated character sprite
                  Transform.translate(
                    offset:
                        Offset(0, math.sin(bobAnim.value * math.pi * 2) * 3),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFFD167),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(3),
                        color: const Color(0xFF1A2744),
                      ),
                      child: Stack(
                        children: [
                          // Grass platform under character
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(1),
                              child: Image.asset(
                                TileAssets.grassMound,
                                height: 16,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(height: 12, color: const Color(0xFF2A5A3A)),
                              ),
                            ),
                          ),
                          // Player sprite
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Image.asset(
                                PlayerAssets.idleArcanistIdleFront01TwoX,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : 'A',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 22,
                                      color: const Color(0xFFFFD167),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RankBadge(xp: xp, onDark: true),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          grade.isNotEmpty ? grade : 'Knowledge Scholar',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // XP progress bar
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: const Color(0xFF6B5A3E).withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LEVEL $level PROGRESS',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$xp / $nextLevelXp XP',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: const Color(0xFFFFD167),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Pixelated XP bar using stacked rectangles
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progressRatio),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(1),
                        child: LinearProgressIndicator(
                          value: value.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFFFD167),
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
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  RANK VOYAGE CARD
// ═══════════════════════════════════════════════════════════════════════════

class _PixelRankVoyageCard extends StatelessWidget {
  const _PixelRankVoyageCard({
    required this.xp,
    required this.streak,
    required this.quizzes,
    required this.glowAnim,
  });

  final int xp;
  final int streak;
  final int quizzes;
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    final current = RankProgression.forXp(xp);
    final next = RankProgression.nextForXp(xp);
    final progress = RankProgression.progressFor(xp);
    final remaining = next == null ? 0 : next.minXp - xp;
    final questCount = next == null ? 0 : (remaining / 150).ceil().clamp(1, 3);

    return AnimatedBuilder(
      animation: glowAnim,
      builder: (context, child) {
        final glow = 0.1 + glowAnim.value * 0.12;
        return _PixelPanel(
          borderColor: const Color(0xFF3D6B4F),
          glowColor: const Color(0xFF7ACB74),
          glowAlpha: glow,
          child: child!,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PixelSectionTitle(
            title: 'RANK VOYAGE',
            trailing: current.name.toUpperCase(),
          ),
          const SizedBox(height: 14),
          // Tier emblems row
          Row(
            children: RankProgression.tiers.map((tier) {
              final unlocked = xp >= tier.minXp;
              final isCurrent = tier.name == current.name;
              return Expanded(
                child: Column(
                  children: [
                    Opacity(
                      opacity: unlocked ? 1 : 0.3,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFFFFD167)
                                : const Color(0xFF3A4A5A),
                            width: isCurrent ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1),
                          child: Image.asset(
                            tier.emblem,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: tier.color.withValues(alpha: 0.3),
                              child: Icon(Icons.workspace_premium,
                                  size: 16, color: tier.color),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tier.name.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 5,
                        color: isCurrent
                            ? const Color(0xFFFFD167)
                            : Colors.white54,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // Progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFFFFD167)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            next == null
                ? 'DIAMOND CITADEL SECURED — HIGHEST TIER REACHED.'
                : '$remaining XP TO ${next.name.toUpperCase()} · UNLOCK ${next.reward.toUpperCase()}.',
            style: GoogleFonts.pressStart2p(
              fontSize: 5,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          if (next != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                  color: const Color(0xFF3A4A5A),
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  Image.asset(
                    UiAssets.iconsQuestScrollIcon,
                    width: 16,
                    height: 16,
                    errorBuilder: (_, __, ___) =>
                        const Text('🎯', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'COMPLETE $questCount QUEST${questCount == 1 ? '' : 'S'} → +${questCount * 150} XP',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  STATS MATRIX
// ═══════════════════════════════════════════════════════════════════════════

class _PixelStatsMatrix extends StatelessWidget {
  const _PixelStatsMatrix({
    required this.xp,
    required this.quizzes,
    required this.streak,
    required this.accuracy,
  });

  final int xp;
  final int quizzes;
  final int streak;
  final double accuracy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _PixelStatTile(
                icon: UiAssets.iconsGoldenSunOrbIcon,
                fallbackIcon: Icons.star_rounded,
                label: 'TOTAL XP',
                value: '$xp',
                accentColor: const Color(0xFFFFD167),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PixelStatTile(
                icon: UiAssets.iconsRedSpellbookIcon,
                fallbackIcon: Icons.quiz_rounded,
                label: 'QUIZZES',
                value: '$quizzes',
                accentColor: const Color(0xFF7ACB74),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PixelStatTile(
                icon: UiAssets.iconsCrossedSwordsIcon,
                fallbackIcon: Icons.local_fire_department_rounded,
                label: 'STREAK',
                value: streak > 0 ? '$streak DAYS' : '1 DAY',
                accentColor: const Color(0xFFFAB387),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PixelStatTile(
                icon: UiAssets.iconsShieldBadgeIcon,
                fallbackIcon: Icons.verified_rounded,
                label: 'ACCURACY',
                value: accuracy > 0 ? '${(accuracy * 100).round()}%' : '92%',
                accentColor: const Color(0xFF89B4FA),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PixelStatTile extends StatelessWidget {
  const _PixelStatTile({
    required this.icon,
    required this.fallbackIcon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String icon;
  final IconData fallbackIcon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return _PixelPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.pressStart2p(
                  fontSize: 5,
                  color: Colors.white54,
                ),
              ),
              Image.asset(
                icon,
                width: 16,
                height: 16,
                errorBuilder: (_, __, ___) =>
                    Icon(fallbackIcon, size: 14, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  STAGE MILESTONES
// ═══════════════════════════════════════════════════════════════════════════

class _PixelStageMilestonesCard extends StatelessWidget {
  const _PixelStageMilestonesCard({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    const stages = [
      {'name': 'STARTER', 'minLvl': 1, 'icon': '🌱'},
      {'name': 'EXPLORER', 'minLvl': 3, 'icon': '🗺️'},
      {'name': 'BUILDER', 'minLvl': 6, 'icon': '🏗️'},
      {'name': 'INVENTOR', 'minLvl': 10, 'icon': '⚙️'},
      {'name': 'MASTER', 'minLvl': 15, 'icon': '👑'},
    ];

    return _PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PixelSectionTitle(title: 'ADVENTURER JOURNEY'),
          const SizedBox(height: 14),
          Row(
            children: stages.asMap().entries.map((entry) {
              final item = entry.value;
              final isUnlocked = level >= (item['minLvl'] as int);
              final isCurrent = isUnlocked &&
                  (entry.key == stages.length - 1 ||
                      level < (stages[entry.key + 1]['minLvl'] as int));

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF2A5A3A)
                            : isUnlocked
                                ? const Color(0xFF1A3A2A)
                                : const Color(0xFF1A2744),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFFFD167)
                              : isUnlocked
                                  ? const Color(0xFF7ACB74)
                                  : const Color(0xFF3A4A5A),
                          width: isCurrent ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: Text(
                          item['icon'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUnlocked
                                ? null
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item['name'] as String,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 5,
                        color: isCurrent
                            ? const Color(0xFFFFD167)
                            : isUnlocked
                                ? Colors.white
                                : Colors.white38,
                      ),
                    ),
                    Text(
                      'LVL ${item['minLvl']}+',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 4,
                        color: Colors.white30,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  REALM MASTERY (District Progress)
// ═══════════════════════════════════════════════════════════════════════════

class _PixelRealmMasteryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buildings = BuildingManager().allBuildings;

    return _PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PixelSectionTitle(
            title: 'DISTRICT MASTERY',
            trailing: 'MATHEMATICS',
          ),
          const SizedBox(height: 14),
          ...buildings.take(4).map((b) {
            final progress = b.progressRatio;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          b.name.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6,
                          color: b.themeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: b.themeColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(b.themeColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BADGES SHOWCASE
// ═══════════════════════════════════════════════════════════════════════════

class _PixelBadgesShowcaseCard extends StatelessWidget {
  const _PixelBadgesShowcaseCard({
    required this.xp,
    required this.quizzes,
    required this.level,
  });

  final int xp;
  final int quizzes;
  final int level;

  @override
  Widget build(BuildContext context) {
    final badges = [
      {
        'title': 'TRAILBLAZER',
        'symbol': '★',
        'unlocked': level >= 3,
        'color': const Color(0xFF89B4FA),
        'icon': UiAssets.iconsGoldenStarBadgeIcon,
      },
      {
        'title': 'MATH WIZARD',
        'symbol': 'π',
        'unlocked': xp >= 200,
        'color': const Color(0xFF7ACB74),
        'icon': UiAssets.iconsSpellbookIcon,
      },
      {
        'title': 'QUIZ ACE',
        'symbol': '✓',
        'unlocked': quizzes >= 5,
        'color': const Color(0xFFFFD167),
        'icon': UiAssets.iconsTrophyCupIcon,
      },
      {
        'title': 'CENTURION',
        'symbol': 'C',
        'unlocked': xp >= 1000,
        'color': const Color(0xFFF38BA8),
        'icon': UiAssets.iconsShieldBadgeIcon,
      },
    ];

    return _PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PixelSectionTitle(title: 'TROPHIES & BADGES'),
          const SizedBox(height: 12),
          Row(
            children: badges.map((badge) {
              final isUnlocked = badge['unlocked'] as bool;
              final color = badge['color'] as Color;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? color.withValues(alpha: 0.08)
                        : const Color(0xFF1A2744),
                    border: Border.all(
                      color: isUnlocked
                          ? color.withValues(alpha: 0.5)
                          : const Color(0xFF3A4A5A),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? color.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: isUnlocked
                                ? color.withValues(alpha: 0.4)
                                : const Color(0xFF3A4A5A),
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: Image.asset(
                            badge['icon'] as String,
                            width: 18,
                            height: 18,
                            color: isUnlocked ? null : Colors.white24,
                            errorBuilder: (_, __, ___) => Text(
                              badge['symbol'] as String,
                              style: GoogleFonts.pressStart2p(
                                fontSize: 10,
                                color: isUnlocked ? color : Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badge['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 4.5,
                          color: isUnlocked ? Colors.white : Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUnlocked ? 'UNLOCKED' : 'LOCKED',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 4,
                          color: isUnlocked ? color : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  UNLOCKED AREAS (World Progress)
// ═══════════════════════════════════════════════════════════════════════════

class _PixelUnlockedAreasCard extends StatelessWidget {
  const _PixelUnlockedAreasCard({required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) {
    final areas = [
      {
        'name': 'MATH HOUSE SANCTUARY',
        'icon': TileAssets.grassTile,
        'fallback': Icons.calculate_rounded,
        'color': const Color(0xFF7ACB74),
        'unlocked': true,
      },
      {
        'name': 'DISCOVERY DISTRICT',
        'icon': TileAssets.cloverGrassTile,
        'fallback': Icons.explore_rounded,
        'color': const Color(0xFF89DCEB),
        'unlocked': xp >= 1000,
      },
      {
        'name': 'INNOVATION FOUNDRY',
        'icon': TileAssets.grassWithStonesTile,
        'fallback': Icons.science_rounded,
        'color': const Color(0xFFFFD167),
        'unlocked': xp >= 2500,
      },
      {
        'name': 'CRYSTAL CITADEL',
        'icon': TileAssets.grassPurpleCrystalGroundTile,
        'fallback': Icons.diamond_rounded,
        'color': const Color(0xFF735FE8),
        'unlocked': xp >= 10000,
      },
    ];

    return _PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PixelSectionTitle(title: 'UNLOCKED AREAS'),
          const SizedBox(height: 12),
          ...areas.map((area) {
            final unlocked = area['unlocked'] as bool;
            final color = area['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: unlocked
                      ? color.withValues(alpha: 0.06)
                      : const Color(0xFF1A2744),
                  border: Border.all(
                    color: unlocked
                        ? color.withValues(alpha: 0.4)
                        : const Color(0xFF3A4A5A),
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: unlocked
                              ? color.withValues(alpha: 0.5)
                              : const Color(0xFF3A4A5A),
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1),
                        child: Opacity(
                          opacity: unlocked ? 1 : 0.25,
                          child: Image.asset(
                            area['icon'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              area['fallback'] as IconData,
                              size: 16,
                              color: unlocked ? color : Colors.white30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        area['name'] as String,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6,
                          color: unlocked ? Colors.white : Colors.white38,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? color.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        border: Border.all(
                          color: unlocked
                              ? color.withValues(alpha: 0.4)
                              : const Color(0xFF3A4A5A),
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        unlocked ? 'UNLOCKED' : 'LOCKED',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 5,
                          color: unlocked ? color : Colors.white30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BIO / LEARNING PHILOSOPHY CARD
// ═══════════════════════════════════════════════════════════════════════════

class _PixelBioCard extends StatelessWidget {
  const _PixelBioCard({required this.profile});
  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    return _PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PixelSectionTitle(title: 'LEARNING PHILOSOPHY'),
          const SizedBox(height: 10),
          // Decorative parchment-like inner area
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2744).withValues(alpha: 0.6),
              border: Border.all(
                color: const Color(0xFF3A4A5A),
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  UiAssets.iconsQuestScrollIcon,
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.auto_stories,
                    color: Color(0xFFF9E2AF),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    profile.learningGoal.trim().isEmpty
                        ? 'Building intellectual mastery one realm at a time. Conquering challenges through curious exploration and persistence.'
                        : profile.learningGoal,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 5,
                      color: Colors.white60,
                      height: 1.8,
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
