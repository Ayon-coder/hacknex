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
import 'knowledge_profile_screen.dart';
import 'world_archipelago_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PixelArt Leaderboard – feels like opening the ranking scroll inside the
// island world from the Map / Archipelago screen.
// ─────────────────────────────────────────────────────────────────────────────

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, this.onBackToSubjectSelection});
  final VoidCallback? onBackToSubjectSelection;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  String _scope = 'Global';
  String _period = 'Weekly';
  late Future<_LeaderboardData> _data;
  late final AnimationController _particleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();
  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_LeaderboardData> _load() async {
    final profile = await PlayerProfile.load() ?? const PlayerProfile();
    final progress = await StudentProgress.load();
    final xp = BuildingManager().allBuildings.fold<int>(
          0,
          (sum, building) => sum + building.currentXp,
        );
    return _LeaderboardData(
      profile: profile,
      xp: xp,
      level: 1 + xp ~/ 500,
      quizzes: progress.quizzesCompleted,
    );
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    _glowCtrl.dispose();
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
          // ── Splash background ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay for readability
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

          // ── Animated pixel particles ──
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (context, _) => CustomPaint(
              painter: _PixelParticlePainter(
                progress: _particleCtrl.value,
                size: size,
              ),
              size: size,
            ),
          ),

          // ── Main content ──
          SafeArea(
            bottom: false,
            child: FutureBuilder<_LeaderboardData>(
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
                final currentUserName = data.profile.name.trim().isEmpty
                    ? 'You'
                    : data.profile.name;

                final entries = [
                  _RankEntry('Aarav Sharma', 1420, 15),
                  _RankEntry('Riya Patel', 1280, 14),
                  _RankEntry('Arjun Verma', 1150, 13),
                  _RankEntry(currentUserName, data.xp, data.level,
                      isCurrentUser: true),
                  _RankEntry('Neha Gupta', 960, 11),
                  _RankEntry('Rohan Das', 840, 10),
                  _RankEntry('Ananya Sen', 780, 9),
                  _RankEntry('Kabir Mehta', 690, 8),
                ]..sort((a, b) => b.xp.compareTo(a.xp));

                final ranked = entries
                    .asMap()
                    .entries
                    .map((entry) => entry.value.copyWith(rank: entry.key + 1))
                    .toList();

                final currentUserRankEntry = ranked.firstWhere(
                  (e) => e.isCurrentUser,
                  orElse: () => ranked.first,
                );

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Back button ──
                                _PixelBackButton(
                                  onTap: () {
                                    if (widget.onBackToSubjectSelection !=
                                        null) {
                                      Navigator.of(context).pop();
                                      widget.onBackToSubjectSelection!();
                                      return;
                                    }
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const WorldArchipelagoScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),

                                // ── Grass-textured heading ──
                                _GrassHeadingStrip(
                                  title: 'HALL OF CHAMPIONS',
                                  subtitle:
                                      'Compete across mathematical realms',
                                ),
                                const SizedBox(height: 14),

                                // ── Arena Header Card ──
                                _PixelArenaHeader(
                                  userRank: currentUserRankEntry.rank,
                                  userXp: currentUserRankEntry.xp,
                                  userLevel: currentUserRankEntry.level,
                                  glowAnim: _glowCtrl,
                                ),
                                const SizedBox(height: 16),

                                // ── Filter pills ──
                                _PixelFilters(
                                  scope: _scope,
                                  period: _period,
                                  onScope: (v) =>
                                      setState(() => _scope = v),
                                  onPeriod: (v) =>
                                      setState(() => _period = v),
                                ),
                                const SizedBox(height: 20),

                                // ── Podium ──
                                _PixelPodium(
                                  entries: ranked.take(3).toList(),
                                  glowAnim: _glowCtrl,
                                ),
                                const SizedBox(height: 20),

                                // ── Grass-textured sub-heading ──
                                _GrassHeadingStrip(
                                  title: 'LEAGUE STANDINGS',
                                  subtitle: '${ranked.length} Scholars',
                                  small: true,
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),

                        // ── Rank list 4+ ──
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            kNavBarReserve + 30,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final entry =
                                    ranked.skip(3).toList()[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8),
                                  child: _PixelRankTile(
                                    entry: entry,
                                    glowAnim: _glowCtrl,
                                  ),
                                );
                              },
                              childCount: ranked.length > 3
                                  ? ranked.length - 3
                                  : 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
//  DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════

class _LeaderboardData {
  const _LeaderboardData({
    required this.profile,
    required this.xp,
    required this.level,
    required this.quizzes,
  });
  final PlayerProfile profile;
  final int xp;
  final int level;
  final int quizzes;
}

class _RankEntry {
  const _RankEntry(
    this.name,
    this.xp,
    this.level, {
    this.rank = 0,
    this.isCurrentUser = false,
  });

  final String name;
  final int xp;
  final int level;
  final int rank;
  final bool isCurrentUser;

  _RankEntry copyWith({int? rank}) => _RankEntry(
        name,
        xp,
        level,
        rank: rank ?? this.rank,
        isCurrentUser: isCurrentUser,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL PARTICLE PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _PixelParticlePainter extends CustomPainter {
  final double progress;
  final Size size;
  _PixelParticlePainter({required this.progress, required this.size});

  static final _rng = math.Random(42);
  static final _particles = List.generate(
    35,
    (_) => Offset(_rng.nextDouble(), _rng.nextDouble()),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const pixelSize = 3.0;
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final drift = math.sin(progress * math.pi * 2 + i * 1.3) * 0.02;
      final alpha = 0.15 + 0.25 * math.sin(progress * math.pi * 2 * 1.5 + i);
      final isGold = i % 3 == 0;
      paint.color = (isGold ? const Color(0xFFFFD167) : const Color(0xFF7ACB74))
          .withValues(alpha: alpha.clamp(0.05, 0.5));
      canvas.drawRect(
        Rect.fromLTWH(
          (p.dx + drift) * size.width,
          (p.dy + progress * 0.15) % 1.0 * size.height,
          pixelSize,
          pixelSize,
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
              'BACK TO WORLD',
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
//  GRASS-TEXTURED HEADING STRIP
// ═══════════════════════════════════════════════════════════════════════════

class _GrassHeadingStrip extends StatelessWidget {
  const _GrassHeadingStrip({
    required this.title,
    required this.subtitle,
    this.small = false,
  });
  final String title;
  final String subtitle;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Grass tile strip background
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: small ? 38 : 50,
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
        // Overlay pixel border
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
        // Text content
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Small decorative bush icon
                Image.asset(
                  NatureAssets.bushesLeafyBush,
                  width: small ? 20 : 28,
                  height: small ? 20 : 28,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.eco_rounded,
                    color: const Color(0xFF7ACB74),
                    size: small ? 16 : 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.pressStart2p(
                    fontSize: small ? 8 : 10,
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
                    fontSize: small ? 6 : 7,
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

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL ARENA HEADER
// ═══════════════════════════════════════════════════════════════════════════

class _PixelArenaHeader extends StatelessWidget {
  const _PixelArenaHeader({
    required this.userRank,
    required this.userXp,
    required this.userLevel,
    required this.glowAnim,
  });

  final int userRank;
  final int userXp;
  final int userLevel;
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (context, child) {
        final glow = 0.15 + glowAnim.value * 0.15;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1F2D),
            border: Border.all(
              color: const Color(0xFF6B5A3E),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD167).withValues(alpha: glow),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with pixel icons
          Row(
            children: [
              Image.asset(
                UiAssets.iconsTrophyCupIcon,
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.emoji_events, color: Color(0xFFFFD167), size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'MATHEMATICS SKY ARENA',
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: const Color(0xFFFFD167),
                ),
              ),
              const Spacer(),
              Image.asset(
                UiAssets.iconsGoldenStarBadgeIcon,
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.star, color: Color(0xFFFFD167), size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User spotlight row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: const Color(0xFF6B5A3E).withValues(alpha: 0.6),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                // Pixel character avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFFD167),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: Image.asset(
                      PlayerAssets.idleArcanistIdleFront01TwoX,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1A3A5A),
                        child: const Icon(Icons.person, color: Color(0xFFFFD167), size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Rank badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD167),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        offset: const Offset(1, 1),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'RANK #$userRank',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7,
                      color: const Color(0xFF573900),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: RankBadge(xp: userXp, onDark: true)),
                Text(
                  '$userXp XP',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
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

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL FILTER TABS
// ═══════════════════════════════════════════════════════════════════════════

class _PixelFilters extends StatelessWidget {
  const _PixelFilters({
    required this.scope,
    required this.period,
    required this.onScope,
    required this.onPeriod,
  });

  final String scope;
  final String period;
  final ValueChanged<String> onScope;
  final ValueChanged<String> onPeriod;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final name in ['Global', 'Friends', 'School']) ...[
          _PixelTab(
            label: name.toUpperCase(),
            isSelected: scope == name,
            onTap: () => onScope(name),
          ),
          const SizedBox(width: 6),
        ],
        const Spacer(),
        for (final p in ['Weekly', 'All-Time']) ...[
          _PixelTab(
            label: p.toUpperCase(),
            isSelected: period == p,
            onTap: () => onPeriod(p),
          ),
          const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _PixelTab extends StatelessWidget {
  const _PixelTab({
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2A5A3A)
              : const Color(0xFF1A2744),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7ACB74)
                : const Color(0xFF3A4A5A),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(3),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7ACB74).withValues(alpha: 0.3),
                    blurRadius: 6,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(1, 1),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 6,
            color: isSelected
                ? const Color(0xFFF9E2AF)
                : const Color(0xFF8A9BB0),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL PODIUM
// ═══════════════════════════════════════════════════════════════════════════

class _PixelPodium extends StatelessWidget {
  const _PixelPodium({required this.entries, required this.glowAnim});
  final List<_RankEntry> entries;
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final rank1 = entries[0];
    final rank2 = entries.length > 1 ? entries[1] : null;
    final rank3 = entries.length > 2 ? entries[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        if (rank2 != null)
          Expanded(
            child: _PixelPodiumPedestal(
              entry: rank2,
              height: 155,
              label: '2ND',
              accentColor: const Color(0xFF8291A2),
              borderColor: const Color(0xFF6A7A8A),
              isChampion: false,
              glowAnim: glowAnim,
            ),
          ),
        const SizedBox(width: 8),
        // 1st place
        Expanded(
          child: _PixelPodiumPedestal(
            entry: rank1,
            height: 195,
            label: '1ST',
            accentColor: const Color(0xFFFFD167),
            borderColor: const Color(0xFFD4AF37),
            isChampion: true,
            glowAnim: glowAnim,
          ),
        ),
        const SizedBox(width: 8),
        // 3rd place
        if (rank3 != null)
          Expanded(
            child: _PixelPodiumPedestal(
              entry: rank3,
              height: 135,
              label: '3RD',
              accentColor: const Color(0xFFE09A52),
              borderColor: const Color(0xFFB87333),
              isChampion: false,
              glowAnim: glowAnim,
            ),
          ),
      ],
    );
  }
}

class _PixelPodiumPedestal extends StatelessWidget {
  const _PixelPodiumPedestal({
    required this.entry,
    required this.height,
    required this.label,
    required this.accentColor,
    required this.borderColor,
    required this.isChampion,
    required this.glowAnim,
  });

  final _RankEntry entry;
  final double height;
  final String label;
  final Color accentColor;
  final Color borderColor;
  final bool isChampion;
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => KnowledgeProfileScreen(
              dummyName: entry.name,
              dummyXp: entry.xp,
              dummyLevel: entry.level,
              dummyQuizzes: (entry.xp ~/ 100) + 2,
            ),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: glowAnim,
        builder: (context, child) {
          final glow = isChampion ? 0.15 + glowAnim.value * 0.2 : 0.0;
          return Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1F2D),
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                if (isChampion)
                  BoxShadow(
                    color: accentColor.withValues(alpha: glow),
                    blurRadius: 16,
                    spreadRadius: 2,
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
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Medal label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(1, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                label,
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: const Color(0xFF1A0A00),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Character sprite avatar
            Container(
              width: isChampion ? 48 : 38,
              height: isChampion ? 48 : 38,
              decoration: BoxDecoration(
                border: Border.all(color: accentColor, width: 2),
                borderRadius: BorderRadius.circular(2),
                color: const Color(0xFF1A2744),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1),
                child: Image.asset(
                  PlayerAssets.idleArcanistIdleFront01TwoX,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                      style: GoogleFonts.pressStart2p(
                        fontSize: isChampion ? 16 : 12,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Name
            Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.pressStart2p(
                fontSize: 6,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            // Rank emblem
            RankBadge(xp: entry.xp, compact: true, onDark: true),
            const SizedBox(height: 4),

            // XP
            Text(
              '${entry.xp} XP',
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 2),

            // Level
            Text(
              'LVL ${entry.level}',
              style: GoogleFonts.pressStart2p(
                fontSize: 6,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL RANK TILE (4th place onward)
// ═══════════════════════════════════════════════════════════════════════════

class _PixelRankTile extends StatelessWidget {
  const _PixelRankTile({required this.entry, required this.glowAnim});
  final _RankEntry entry;
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    final tier = RankProgression.forXp(entry.xp);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => KnowledgeProfileScreen(
              dummyName: entry.name,
              dummyXp: entry.xp,
              dummyLevel: entry.level,
              dummyQuizzes: (entry.xp ~/ 100) + 2,
            ),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: glowAnim,
        builder: (context, child) {
          final isMe = entry.isCurrentUser;
          final glow = isMe ? 0.2 + glowAnim.value * 0.2 : 0.0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? const Color(0xFF1A3A2A)
                  : const Color(0xFF0D1F2D),
              border: Border.all(
                color: isMe
                    ? const Color(0xFF7ACB74)
                    : const Color(0xFF2A3A4A),
                width: isMe ? 2 : 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                if (isMe)
                  BoxShadow(
                    color: const Color(0xFF7ACB74).withValues(alpha: glow),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          children: [
            // Rank number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2744),
                border: Border.all(
                  color: const Color(0xFF3A4A5A),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  '#${entry.rank}',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: const Color(0xFFF9E2AF),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Mini character sprite
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(
                  color: tier.color.withValues(alpha: 0.7),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(2),
                color: const Color(0xFF1A2744),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1),
                child: Image.asset(
                  PlayerAssets.idleArcanistIdleFront01,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: tier.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Name & progress bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (entry.isCurrentUser) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7ACB74),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'YOU',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 5,
                              color: const Color(0xFF003300),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Pixel progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: SizedBox(
                      width: 80,
                      child: LinearProgressIndicator(
                        value: RankProgression.progressFor(entry.xp),
                        minHeight: 4,
                        backgroundColor:
                            tier.color.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(tier.color),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            RankBadge(xp: entry.xp, compact: true, onDark: true),
            const SizedBox(width: 8),

            // XP value
            Text(
              '${entry.xp}',
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: const Color(0xFFFFD167),
              ),
            ),
            Text(
              ' XP',
              style: GoogleFonts.pressStart2p(
                fontSize: 6,
                color: const Color(0xFFFFD167).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
