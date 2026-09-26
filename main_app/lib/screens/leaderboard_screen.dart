import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/managers/building_manager.dart';
import '../models/player_profile.dart';
import '../services/student_progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_ui.dart';
import '../widgets/rank_badge.dart';
import 'knowledge_profile_screen.dart';
import 'world_archipelago_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, this.onBackToSubjectSelection});

  final VoidCallback? onBackToSubjectSelection;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _scope = 'Global';
  String _period = 'Weekly';
  late Future<_LeaderboardData> _data;

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: WorldBackdrop(
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<_LeaderboardData>(
            future: _data,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data!;
              final currentUserName = data.profile.name.trim().isEmpty
                  ? 'You'
                  : data.profile.name;

              final entries = [
                _RankEntry('Aarav Sharma', 1420, 15),
                _RankEntry('Riya Patel', 1280, 14),
                _RankEntry('Arjun Verma', 1150, 13),
                _RankEntry(currentUserName, data.xp, data.level, isCurrentUser: true),
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
                      // Header & Spotlight
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () {
                                    if (widget.onBackToSubjectSelection != null) {
                                      Navigator.of(context).pop();
                                      widget.onBackToSubjectSelection!();
                                      return;
                                    }
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (_) => const WorldArchipelagoScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  label: const Text('Subject Selection'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    textStyle: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Arena Header Card (Clean & Spacious)
                              _ArenaHeaderCard(
                                userRank: currentUserRankEntry.rank,
                                userXp: currentUserRankEntry.xp,
                                userLevel: currentUserRankEntry.level,
                              ),
                              const SizedBox(height: 18),

                              // Scope and Timeframe Filter Bar (Clean Text Pills)
                              _LeaderboardFilters(
                                scope: _scope,
                                period: _period,
                                onScope: (v) => setState(() => _scope = v),
                                onPeriod: (v) => setState(() => _period = v),
                              ),
                              const SizedBox(height: 24),

                              // Podium
                              _ChampionshipPodium(
                                entries: ranked.take(3).toList(),
                              ),
                              const SizedBox(height: 24),

                              // Leaderboard list heading (No extra icons)
                              Row(
                                children: [
                                  Text(
                                    'League Standings',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${ranked.length} Scholars',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),

                      // Rank 4+ List
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
                              final entry = ranked.skip(3).toList()[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _RankTile(entry: entry),
                              );
                            },
                            childCount: ranked.length > 3 ? ranked.length - 3 : 0,
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
      ),
    );
  }
}

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

class _ArenaHeaderCard extends StatelessWidget {
  const _ArenaHeaderCard({
    required this.userRank,
    required this.userXp,
    required this.userLevel,
  });

  final int userRank;
  final int userXp;
  final int userLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F3622),
            Color(0xFF1E5637),
            Color(0xFF14452C),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3622).withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hall of Champions',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Compete across mathematical realms to claim glory.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 18),

          // User Spotlight Pill (Clean, accurate stats)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD167),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'YOUR RANK #$userRank',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      color: const Color(0xFF573900),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: RankBadge(xp: userXp, onDark: true)),
                Text(
                  '$userXp XP',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFFD167),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
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

class _LeaderboardFilters extends StatelessWidget {
  const _LeaderboardFilters({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final name in ['Global', 'Friends', 'School']) ...[
                      _FilterTab(
                        label: name,
                        isSelected: scope == name,
                        onTap: () => onScope(name),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final p in ['Weekly', 'All-Time']) ...[
                    _FilterTab(
                      label: p,
                      isSelected: period == p,
                      onTap: () => onPeriod(p),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFD6E3DC),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.20),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChampionshipPodium extends StatelessWidget {
  const _ChampionshipPodium({required this.entries});
  final List<_RankEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final rank1 = entries[0];
    final rank2 = entries.length > 1 ? entries[1] : null;
    final rank3 = entries.length > 2 ? entries[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place (Silver)
        if (rank2 != null)
          Expanded(
            child: _PodiumPedestal(
              entry: rank2,
              pedestalHeight: 180,
              medalEmoji: '🥈',
              medalLabel: '2ND',
              accentGradient: const LinearGradient(
                colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
              ),
              borderColor: const Color(0xFFCBD5E1),
              ringColor: const Color(0xFF94A3B8),
            ),
          ),
        const SizedBox(width: 12),

        // 1st Place (Gold Champion)
        Expanded(
          child: _PodiumPedestal(
            entry: rank1,
            pedestalHeight: 220,
            medalEmoji: '👑',
            medalLabel: '1ST',
            accentGradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF7D6), Color(0xFFFFE082)],
            ),
            borderColor: const Color(0xFFFFD167),
            ringColor: const Color(0xFFE5A912),
            isChampion: true,
          ),
        ),
        const SizedBox(width: 12),

        // 3rd Place (Bronze)
        if (rank3 != null)
          Expanded(
            child: _PodiumPedestal(
              entry: rank3,
              pedestalHeight: 160,
              medalEmoji: '🥉',
              medalLabel: '3RD',
              accentGradient: const LinearGradient(
                colors: [Color(0xFFFFEDD5), Color(0xFFFED7AA)],
              ),
              borderColor: const Color(0xFFFDBA74),
              ringColor: const Color(0xFFEA580C),
            ),
          ),
      ],
    );
  }
}

class _PodiumPedestal extends StatelessWidget {
  const _PodiumPedestal({
    required this.entry,
    required this.pedestalHeight,
    required this.medalEmoji,
    required this.medalLabel,
    required this.accentGradient,
    required this.borderColor,
    required this.ringColor,
    this.isChampion = false,
  });

  final _RankEntry entry;
  final double pedestalHeight;
  final String medalEmoji;
  final String medalLabel;
  final Gradient accentGradient;
  final Color borderColor;
  final Color ringColor;
  final bool isChampion;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isChampion ? borderColor : const Color(0xFFE2EAE5),
          width: isChampion ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ringColor.withValues(alpha: isChampion ? 0.22 : 0.10),
            blurRadius: isChampion ? 20 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Medal Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: accentGradient,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(medalEmoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        medalLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Initial Avatar with Ring (Clean typography, no arbitrary icons)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringColor,
                      width: isChampion ? 2.5 : 1.8,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: isChampion ? 28 : 22,
                    backgroundColor: ringColor.withValues(alpha: 0.15),
                    child: Text(
                      entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                      style: GoogleFonts.plusJakartaSans(
                        color: ringColor,
                        fontWeight: FontWeight.w900,
                        fontSize: isChampion ? 22 : 17,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Name
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: isChampion ? 14 : 12.5,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),

                RankBadge(xp: entry.xp, compact: true),
                const SizedBox(height: 4),

                // XP Badge
                Text(
                  '${entry.xp} XP',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: isChampion ? 13 : 11.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),

                // Level
                Text(
                  'Level ${entry.level}',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({required this.entry});
  final _RankEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primaryContainer.withValues(alpha: 0.18)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: entry.isCurrentUser
              ? AppColors.primary
              : const Color(0xFFE2EAE5),
          width: entry.isCurrentUser ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Rank Number Badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '#${entry.rank}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Initial Avatar (Clean typography)
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                  child: Text(
                    entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Current User Tag
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (entry.isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'YOU',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 9.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                RankBadge(xp: entry.xp, compact: true),
                const SizedBox(width: 10),

                // XP Tag
                Text(
                  '${entry.xp} XP',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
