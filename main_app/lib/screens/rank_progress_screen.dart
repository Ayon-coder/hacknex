import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/game_assets.dart';
import '../game/buildings/building_data.dart';
import '../game/managers/building_manager.dart';
import '../models/player_profile.dart';
import '../models/rank_progress.dart';
import '../services/student_progress_service.dart';
import '../theme/app_theme.dart';
import 'leaderboard_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pixel-Art Rank & Progress Screen
// Implements the adventure game / island world aesthetic matching
// LeaderboardScreen, KnowledgeProfileScreen, and WorldScreen.
// ─────────────────────────────────────────────────────────────────────────────

class RankProgressScreen extends StatefulWidget {
  const RankProgressScreen({super.key, this.onBackToSubjectSelection});

  final VoidCallback? onBackToSubjectSelection;

  @override
  State<RankProgressScreen> createState() => _RankProgressScreenState();
}

class _RankProgressScreenState extends State<RankProgressScreen>
    with TickerProviderStateMixin {
  late Future<_RankData> _data;
  RankTier? _selectedTier;
  AnimationController? _particleCtrl;
  AnimationController? _glowCtrl;

  @override
  void initState() {
    super.initState();
    _data = _loadData();
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

  Future<_RankData> _loadData() async {
    final profile = await PlayerProfile.load();
    final progress = await StudentProgress.load();
    final buildings = BuildingManager().allBuildings;
    final xp =
        buildings.fold<int>(0, (sum, building) => sum + building.currentXp);
    return _RankData(
      name: profile?.name.isNotEmpty == true ? profile!.name : 'Explorer',
      xp: xp,
      streak: progress.streak,
      quizzes: progress.quizzesCompleted,
      accuracy: progress.accuracy,
      buildings: buildings,
    );
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
              builder: (context, _) => FutureBuilder<_RankData>(
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
                  final currentBuildings = BuildingManager().allBuildings;
                  final refreshed = data.copyWith(
                    xp: currentBuildings.fold<int>(
                      0,
                      (sum, b) => sum + b.currentXp,
                    ),
                    buildings: currentBuildings,
                  );

                  final activeTier =
                      _selectedTier ?? RankProgression.forXp(refreshed.xp);

                  return _RankView(
                    data: refreshed,
                    selectedTier: activeTier,
                    glowAnim: _glowCtrl!,
                    onTierTap: (tier) => setState(() => _selectedTier = tier),
                    onBackToSubjectSelection: widget.onBackToSubjectSelection,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MAIN RANK VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _RankView extends StatelessWidget {
  const _RankView({
    required this.data,
    required this.selectedTier,
    required this.glowAnim,
    required this.onTierTap,
    this.onBackToSubjectSelection,
  });

  final _RankData data;
  final RankTier selectedTier;
  final Animation<double> glowAnim;
  final ValueChanged<RankTier> onTierTap;
  final VoidCallback? onBackToSubjectSelection;

  @override
  Widget build(BuildContext context) {
    final currentTier = RankProgression.forXp(data.xp);
    final nextTier = RankProgression.nextForXp(data.xp);
    final percent = RankProgression.progressFor(data.xp);
    final remaining = nextTier == null ? 0 : nextTier.minXp - data.xp;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 850;
        final horizontalPadding = isWide ? 36.0 : 18.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    kNavBarReserve + 16,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Navigation Header Row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (onBackToSubjectSelection != null)
                            _PixelBackButton(
                              label: 'BACK TO WORLD',
                              onTap: onBackToSubjectSelection!,
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  UiAssets.iconsQuestScrollIcon,
                                  width: 22,
                                  height: 22,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.map_rounded,
                                    color: Color(0xFFFFD167),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'KNOWLEDGE REALM',
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 8,
                                    color: const Color(0xFFF9E2AF),
                                  ),
                                ),
                              ],
                            ),
                          // Pixel Leaderboard Button
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LeaderboardScreen(
                                  onBackToSubjectSelection:
                                      onBackToSubjectSelection,
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B2F44),
                                border: Border.all(
                                  color: const Color(0xFFFFD167),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD167)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
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
                                  Image.asset(
                                    UiAssets.iconsTrophyCupIcon,
                                    width: 16,
                                    height: 16,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.emoji_events,
                                      color: Color(0xFFFFD167),
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ARENA',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 7.5,
                                      color: const Color(0xFFFFD167),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Screen Title Banner ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1F2D),
                              border: Border.all(
                                color: const Color(0xFF6B5A3E),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Image.asset(
                              UiAssets.iconsGoldenStarBadgeIcon,
                              width: 26,
                              height: 26,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.stars_rounded,
                                color: Color(0xFFFFD167),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RANK & ASCENSION',
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 12,
                                    color: const Color(0xFFF9E2AF),
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.8),
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Ascend the knowledge ranks to unlock island districts',
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

                      // ── 1. Hero Rank Card ──
                      _PixelHeroRankCard(
                        data: data,
                        tier: currentTier,
                        next: nextTier,
                        percent: percent,
                        remaining: remaining,
                        glowAnim: glowAnim,
                      ),
                      const SizedBox(height: 18),

                      // ── 2. Grass Heading: Tier Journey ──
                      const _GrassHeadingStrip(
                        title: 'ASCENSION LADDER',
                        subtitle: '5 TIERS',
                      ),
                      const SizedBox(height: 10),

                      // ── 3. Horizontal Tier Journey ──
                      _PixelRankJourney(
                        xp: data.xp,
                        selectedTier: selectedTier,
                        onTierTap: onTierTap,
                      ),
                      const SizedBox(height: 12),

                      // ── 4. Selected Tier Details ──
                      _PixelTierDetail(
                        tier: selectedTier,
                        isUnlocked: data.xp >= selectedTier.minXp,
                        isCurrent: selectedTier.name == currentTier.name,
                      ),
                      const SizedBox(height: 18),

                      // ── 5. Grass Heading: Quests & Next Moves ──
                      const _GrassHeadingStrip(
                        title: 'DAILY QUESTS',
                        subtitle: 'EARN BONUS XP',
                      ),
                      const SizedBox(height: 10),

                      // ── 6. Action Plan / Quests ──
                      _PixelActionPlan(
                        data: data,
                        remaining: remaining,
                        nextName: nextTier?.name,
                      ),
                      const SizedBox(height: 18),

                      // ── 7. Grass Heading: Subject Mastery ──
                      const _GrassHeadingStrip(
                        title: 'DISTRICT MASTERY',
                        subtitle: 'REALM HOUSES',
                      ),
                      const SizedBox(height: 10),

                      // ── 8. Subject Progress ──
                      _PixelSubjectProgress(buildings: data.buildings),
                      const SizedBox(height: 18),

                      // ── 9. Grass Heading: Achievements ──
                      const _GrassHeadingStrip(
                        title: 'TROPHIES & HONORS',
                        subtitle: 'MILESTONES',
                      ),
                      const SizedBox(height: 10),

                      // ── 10. Achievements ──
                      _PixelAchievements(data: data),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL HERO RANK CARD
// ═══════════════════════════════════════════════════════════════════════════

class _PixelHeroRankCard extends StatelessWidget {
  const _PixelHeroRankCard({
    required this.data,
    required this.tier,
    required this.next,
    required this.percent,
    required this.remaining,
    required this.glowAnim,
  });

  final _RankData data;
  final RankTier tier;
  final RankTier? next;
  final double percent;
  final int remaining;
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (context, child) {
        final glow = 0.15 + glowAnim.value * 0.18;
        return _PixelPanel(
          borderColor: tier.color,
          glowColor: tier.color,
          glowAlpha: glow,
          padding: const EdgeInsets.all(16),
          child: child!,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Emblem + Tier Name & Stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pixel-framed Emblem
              _PixelEmblemFrame(
                tier: tier,
                size: 88,
                glow: true,
              ),
              const SizedBox(width: 16),

              // Title & Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 12,
                          color: const Color(0xFF7ACB74),
                          margin: const EdgeInsets.only(right: 6),
                        ),
                        Text(
                          'CURRENT RANK',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7,
                            color: const Color(0xFF7ACB74),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tier.name.toUpperCase(),
                      style: GoogleFonts.pressStart2p(
                        fontSize: 14,
                        color: const Color(0xFFFFD167),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: const Color(0xFF6B5A3E),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        '${data.xp} TOTAL XP',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7.5,
                          color: const Color(0xFFF9E2AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                next == null
                    ? 'LEGENDARY RANK'
                    : '${(percent * 100).round()}% TO ${next!.name.toUpperCase()}',
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: const Color(0xFFF9E2AF),
                ),
              ),
              Text(
                next == null ? 'MAXED' : '$remaining XP LEFT',
                style: GoogleFonts.pressStart2p(
                  fontSize: 6.5,
                  color: const Color(0xFF7ACB74),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Pixel Progress Bar
          Container(
            height: 14,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF07121C),
              border: Border.all(
                color: const Color(0xFF6B5A3E),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percent),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value.clamp(0.02, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tier.color,
                          const Color(0xFFFFD167),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Mini Stats Grid
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: const Color(0xFF6B5A3E).withValues(alpha: 0.6),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MiniHeroStat(
                    emoji: '🔥',
                    label: 'STREAK',
                    value: '${data.streak} DAYS',
                    color: const Color(0xFFFF8E42),
                  ),
                ),
                Container(
                  width: 1,
                  height: 26,
                  color: const Color(0xFF6B5A3E).withValues(alpha: 0.6),
                ),
                Expanded(
                  child: _MiniHeroStat(
                    emoji: '⚔️',
                    label: 'QUIZZES',
                    value: '${data.quizzes}',
                    color: const Color(0xFF7ACB74),
                  ),
                ),
                Container(
                  width: 1,
                  height: 26,
                  color: const Color(0xFF6B5A3E).withValues(alpha: 0.6),
                ),
                Expanded(
                  child: _MiniHeroStat(
                    emoji: '🎯',
                    label: 'ACCURACY',
                    value: '${(data.accuracy * 100).round()}%',
                    color: const Color(0xFFFFD167),
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

class _MiniHeroStat extends StatelessWidget {
  const _MiniHeroStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 6,
                color: Colors.white60,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.pressStart2p(
            fontSize: 7.5,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL EMBLEM FRAME
// ═══════════════════════════════════════════════════════════════════════════

class _PixelEmblemFrame extends StatelessWidget {
  const _PixelEmblemFrame({
    required this.tier,
    required this.size,
    this.glow = false,
    this.muted = false,
  });

  final RankTier tier;
  final double size;
  final bool glow;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: muted ? 0.4 : 1.0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1722),
          border: Border.all(
            color: glow ? const Color(0xFFFFD167) : const Color(0xFF6B5A3E),
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            if (glow)
              BoxShadow(
                color: tier.color.withValues(alpha: 0.5),
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
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            tier.emblem,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.military_tech_rounded,
              color: tier.color,
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL RANK JOURNEY (HORIZONTAL LADDER)
// ═══════════════════════════════════════════════════════════════════════════

class _PixelRankJourney extends StatelessWidget {
  const _PixelRankJourney({
    required this.xp,
    required this.selectedTier,
    required this.onTierTap,
  });

  final int xp;
  final RankTier selectedTier;
  final ValueChanged<RankTier> onTierTap;

  @override
  Widget build(BuildContext context) {
    final currentTier = RankProgression.forXp(xp);

    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: RankProgression.tiers.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            child: Text(
              '▶',
              style: GoogleFonts.pressStart2p(
                fontSize: 9,
                color: const Color(0xFF6B5A3E),
              ),
            ),
          ),
        ),
        itemBuilder: (context, index) {
          final tier = RankProgression.tiers[index];
          final isCurrent = currentTier.name == tier.name;
          final isUnlocked = xp >= tier.minXp;
          final isSelected = selectedTier.name == tier.name;

          return GestureDetector(
            onTap: () => onTierTap(tier),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 104,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF192C3D)
                    : const Color(0xFF0D1F2D),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFD167)
                      : (isCurrent ? tier.color : const Color(0xFF6B5A3E)),
                  width: isSelected || isCurrent ? 2.5 : 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  if (isSelected || isCurrent)
                    BoxShadow(
                      color: tier.color.withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PixelEmblemFrame(
                    tier: tier,
                    size: 54,
                    glow: isCurrent || isSelected,
                    muted: !isUnlocked,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tier.name.toUpperCase(),
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7.5,
                      color: isUnlocked
                          ? const Color(0xFFF9E2AF)
                          : Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFFFD167)
                          : (isUnlocked
                              ? const Color(0xFF2A5A3A)
                              : Colors.white.withValues(alpha: 0.06)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      isCurrent
                          ? 'ACTIVE'
                          : (isUnlocked ? 'PASSED' : '${tier.minXp} XP'),
                      style: GoogleFonts.pressStart2p(
                        fontSize: 5.5,
                        color: isCurrent
                            ? const Color(0xFF4A3400)
                            : (isUnlocked
                                ? const Color(0xFF86E2A5)
                                : Colors.white54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL TIER DETAIL
// ═══════════════════════════════════════════════════════════════════════════

class _PixelTierDetail extends StatelessWidget {
  const _PixelTierDetail({
    required this.tier,
    required this.isUnlocked,
    required this.isCurrent,
  });

  final RankTier tier;
  final bool isUnlocked;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return _PixelPanel(
      borderColor: tier.color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isUnlocked ? '🔓' : '🔒',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${tier.name.toUpperCase()} TIER DETAILS',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: const Color(0xFFFFD167),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xFF2A5A3A)
                      : const Color(0xFF442020),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: isUnlocked
                        ? const Color(0xFF7ACB74)
                        : const Color(0xFFE57373),
                    width: 1,
                  ),
                ),
                child: Text(
                  isUnlocked ? 'UNLOCKED' : 'REQ: ${tier.minXp} XP',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 5.5,
                    color: isUnlocked
                        ? const Color(0xFF86E2A5)
                        : const Color(0xFFFFCDD2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: const Color(0xFF6B5A3E).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFFFFD167),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UNLOCKED REWARD:',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6,
                          color: const Color(0xFF7ACB74),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tier.reward,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6.5,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
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

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL ACTION PLAN / DAILY QUESTS
// ═══════════════════════════════════════════════════════════════════════════

class _PixelActionPlan extends StatelessWidget {
  const _PixelActionPlan({
    required this.data,
    required this.remaining,
    required this.nextName,
  });

  final _RankData data;
  final int remaining;
  final String? nextName;

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('🧩', 'Complete challenges', 50, data.quizzes < 3 ? 3 : 1),
      ('📚', 'Master a house lesson', 100, 1),
      ('🎯', 'Complete realm quests', 150, (remaining / 150).ceil().clamp(1, 3)),
      ('🔥', 'Maintain learning streak', 25, data.streak == 0 ? 3 : 1),
    ];

    return _PixelPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PixelSectionTitle(
            title: 'EXPEDITION QUESTS',
            trailing: '+XP GAINS',
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < actions.length; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color: const Color(0xFF6B5A3E).withValues(alpha: 0.6),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Text(actions[i].$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actions[i].$2,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7,
                            color: const Color(0xFFF9E2AF),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Complete ${actions[i].$4} more to earn XP',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 5.5,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A5A3A),
                      border: Border.all(
                        color: const Color(0xFF7ACB74),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '+${actions[i].$3 * actions[i].$4} XP',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 6.5,
                        color: const Color(0xFF86E2A5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (nextName != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF142436),
                border: Border.all(
                  color: const Color(0xFF3D6B4F),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.flag_rounded,
                    color: Color(0xFFFFD167),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$remaining XP to ascend to $nextName. Every lesson expands your civilization!',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 6,
                        color: Colors.white70,
                        height: 1.4,
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
//  PIXEL SUBJECT PROGRESS
// ═══════════════════════════════════════════════════════════════════════════

class _PixelSubjectProgress extends StatelessWidget {
  const _PixelSubjectProgress({required this.buildings});

  final List<BuildingData> buildings;

  @override
  Widget build(BuildContext context) {
    return _PixelPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PixelSectionTitle(
            title: 'CAMPUS REALM TIERS',
            trailing: 'MASTERY',
          ),
          const SizedBox(height: 12),
          for (final building in buildings) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        building.icon,
                        size: 16,
                        color: building.themeColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          building.name.replaceAll(' House', '').toUpperCase(),
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7.5,
                            color: const Color(0xFFF9E2AF),
                          ),
                        ),
                      ),
                      Text(
                        '${(building.progressRatio * 100).round()}%',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7.5,
                          color: building.themeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
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
                        widthFactor: building.progressRatio.clamp(0.02, 1.0),
                        child: Container(
                          color: building.themeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LVL ${building.level}',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 5.5,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        '${building.currentXp} / ${building.xpRequired} XP',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 5.5,
                          color: Colors.white54,
                        ),
                      ),
                    ],
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
//  PIXEL ACHIEVEMENTS
// ═══════════════════════════════════════════════════════════════════════════

class _PixelAchievements extends StatelessWidget {
  const _PixelAchievements({required this.data});

  final _RankData data;

  @override
  Widget build(BuildContext context) {
    final achievements = [
      ('🧠', 'Knowledge Explorer', 'Earn 1,000 XP', data.xp >= 1000),
      ('🔥', 'Streak Keeper', '${data.streak} day streak', data.streak >= 3),
      ('⚔️', 'Quest Conqueror', 'Complete 5 quizzes', data.quizzes >= 5),
      ('🏛️', 'Realm Scholar', 'Unlock 3 houses', data.buildings.where((b) => b.unlocked).length >= 3),
      ('🌟', 'High Honor', '80%+ accuracy', data.accuracy >= 0.8),
    ];

    return SizedBox(
      height: 136,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final a = achievements[index];
          final unlocked = a.$4;

          return Container(
            width: 140,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0xFF162A3B)
                  : const Color(0xFF0D1722),
              border: Border.all(
                color: unlocked
                    ? const Color(0xFFFFD167)
                    : const Color(0xFF6B5A3E),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                if (unlocked)
                  BoxShadow(
                    color: const Color(0xFFFFD167).withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(a.$1, style: const TextStyle(fontSize: 20)),
                    Icon(
                      unlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                      size: 14,
                      color: unlocked
                          ? const Color(0xFF7ACB74)
                          : Colors.white38,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  a.$2,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6.5,
                    color: unlocked
                        ? const Color(0xFFF9E2AF)
                        : Colors.white54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  unlocked ? 'UNLOCKED' : a.$3,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 5.5,
                    color: unlocked
                        ? const Color(0xFF7ACB74)
                        : Colors.white38,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
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

class _RankData {
  const _RankData({
    required this.name,
    required this.xp,
    required this.streak,
    required this.quizzes,
    required this.accuracy,
    required this.buildings,
  });

  final String name;
  final int xp;
  final int streak;
  final int quizzes;
  final double accuracy;
  final List<BuildingData> buildings;

  _RankData copyWith({int? xp, List<BuildingData>? buildings}) => _RankData(
        name: name,
        xp: xp ?? this.xp,
        streak: streak,
        quizzes: quizzes,
        accuracy: accuracy,
        buildings: buildings ?? this.buildings,
      );
}
