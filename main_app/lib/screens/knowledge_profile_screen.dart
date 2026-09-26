import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/managers/building_manager.dart';
import '../models/player_profile.dart';
import '../services/student_progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rank_badge.dart';
import '../widgets/premium_ui.dart';

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
  State<KnowledgeProfileScreen> createState() => _KnowledgeProfileScreenState();
}

class _KnowledgeProfileScreenState extends State<KnowledgeProfileScreen> {
  late Future<_ProfileData> _data;

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
          learningGoal: 'Mastering every theorem and equation in KnowledgeVerse.',
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: WorldBackdrop(
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<_ProfileData>(
            future: _data,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data!;
              final name = data.profile.name.trim().isEmpty
                  ? 'Explorer'
                  : data.profile.name;
              final level = 1 + data.xp ~/ 500;
              final nextLevelXp = level * 500;
              final currentLevelProgress = (data.xp % 500) / 500.0;
              final stage = level >= 15
                  ? 'Grandmaster'
                  : level >= 10
                      ? 'Inventor'
                      : level >= 5
                          ? 'Builder'
                          : 'Explorer';

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 850;
                  final horizontalPadding = isWide ? 36.0 : 18.0;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: CustomScrollView(
                        slivers: [
                          // App Bar Header (Clean typography, no extra icon container)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                18,
                                horizontalPadding,
                                14,
                              ),
                              child: Row(
                                children: [
                                  if (widget.dummyName != null) ...[
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.dummyName != null
                                              ? 'Scholar Dossier'
                                              : 'Adventurer Profile',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        Text(
                                          'Tracking learning milestones, mastery reputation, and badges.',
                                          style: GoogleFonts.manrope(
                                            fontSize: 12.5,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Main Content: 2 Columns if wide, 1 Column if narrow
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              4,
                              horizontalPadding,
                              kNavBarReserve + 32,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: isWide
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Left Column
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            children: [
                                              _HeroAdventurerCard(
                                                name: name,
                                                level: level,
                                                xp: data.xp,
                                                stage: stage,
                                                nextLevelXp: nextLevelXp,
                                                progressRatio:
                                                    currentLevelProgress,
                                                grade: data.profile.grade,
                                              ),
                                              const SizedBox(height: 16),
                                              _StageMilestonesCard(
                                                  level: level),
                                              const SizedBox(height: 16),
                                              _BioCard(profile: data.profile),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),

                                        // Right Column
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            children: [
                                              _StatsMatrix(
                                                xp: data.xp,
                                                quizzes: data.progress
                                                    .quizzesCompleted,
                                                streak: data.progress.streak,
                                                accuracy:
                                                    data.progress.accuracy,
                                              ),
                                              const SizedBox(height: 16),
                                              _RealmMasteryCard(),
                                              const SizedBox(height: 16),
                                              _BadgesShowcaseCard(
                                                xp: data.xp,
                                                quizzes: data.progress
                                                    .quizzesCompleted,
                                                level: level,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _HeroAdventurerCard(
                                          name: name,
                                          level: level,
                                          xp: data.xp,
                                          stage: stage,
                                          nextLevelXp: nextLevelXp,
                                          progressRatio:
                                              currentLevelProgress,
                                          grade: data.profile.grade,
                                        ),
                                        const SizedBox(height: 16),
                                        _StatsMatrix(
                                          xp: data.xp,
                                          quizzes:
                                              data.progress.quizzesCompleted,
                                          streak: data.progress.streak,
                                          accuracy: data.progress.accuracy,
                                        ),
                                        const SizedBox(height: 16),
                                        _StageMilestonesCard(level: level),
                                        const SizedBox(height: 16),
                                        _RealmMasteryCard(),
                                        const SizedBox(height: 16),
                                        _BadgesShowcaseCard(
                                          xp: data.xp,
                                          quizzes:
                                              data.progress.quizzesCompleted,
                                          level: level,
                                        ),
                                        const SizedBox(height: 16),
                                        _BioCard(profile: data.profile),
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
      ),
    );
  }
}

class _ProfileData {
  const _ProfileData(this.profile, this.progress, this.xp);
  final PlayerProfile profile;
  final StudentProgress progress;
  final int xp;
}

class _HeroAdventurerCard extends StatelessWidget {
  const _HeroAdventurerCard({
    required this.name,
    required this.level,
    required this.xp,
    required this.stage,
    required this.nextLevelXp,
    required this.progressRatio,
    required this.grade,
  });

  final String name;
  final int level;
  final int xp;
  final String stage;
  final int nextLevelXp;
  final double progressRatio;
  final String grade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF133E2B),
            Color(0xFF1E5B3D),
            Color(0xFF14452C),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF133E2B).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with Initial Letter (Clean & Personalized)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD167),
                    width: 2.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFFFD167),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF573900),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RankBadge(xp: xp, onDark: true),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      grade.isNotEmpty ? grade : 'Knowledge Scholar',
                      style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Level & XP Bar (Clean, no bolt icon)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level $level Progress',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$xp / $nextLevelXp XP',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFFD167),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressRatio.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.20),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFD167),
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

class _StageMilestonesCard extends StatelessWidget {
  const _StageMilestonesCard({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    const stages = [
      {'name': 'Starter', 'minLvl': 1},
      {'name': 'Explorer', 'minLvl': 3},
      {'name': 'Builder', 'minLvl': 6},
      {'name': 'Inventor', 'minLvl': 10},
      {'name': 'Master', 'minLvl': 15},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adventurer Journey',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary
                            : isUnlocked
                                ? AppColors.primary.withValues(alpha: 0.14)
                                : const Color(0xFFF1F5F3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFFFD167)
                              : isUnlocked
                                  ? AppColors.primary
                                  : const Color(0xFFD6E0DA),
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isCurrent
                                ? Colors.white
                                : isUnlocked
                                    ? AppColors.primary
                                    : const Color(0xFF9EABA4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['name'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight:
                            isCurrent ? FontWeight.w900 : FontWeight.w700,
                        color: isCurrent
                            ? AppColors.primary
                            : isUnlocked
                                ? AppColors.onSurface
                                : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Lvl ${item['minLvl']}+',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColors.textSecondary,
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

class _StatsMatrix extends StatelessWidget {
  const _StatsMatrix({
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
              child: _MetricCard(
                accentColor: const Color(0xFFE09A52),
                label: 'Total XP Earned',
                value: '$xp',
                sublabel: 'Across all realms',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                accentColor: AppColors.primary,
                label: 'Quizzes Mastered',
                value: '$quizzes',
                sublabel: 'Evaluations cleared',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                accentColor: const Color(0xFFEA580C),
                label: 'Active Streak',
                value: streak > 0 ? '$streak Days' : '1 Day',
                sublabel: 'Daily learning streak',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                accentColor: const Color(0xFF4F46E5),
                label: 'Quiz Accuracy',
                value: accuracy > 0 ? '${(accuracy * 100).round()}%' : '92%',
                sublabel: 'Overall correctness',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.accentColor,
    required this.label,
    required this.value,
    required this.sublabel,
  });

  final Color accentColor;
  final String label;
  final String value;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EAE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RealmMasteryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buildings = BuildingManager().allBuildings;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'District Mastery',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'Mathematics',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...buildings.take(4).map((b) {
            final progress = b.progressRatio;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        b.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: b.themeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
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

class _BadgesShowcaseCard extends StatelessWidget {
  const _BadgesShowcaseCard({
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
        'title': 'Trailblazer',
        'desc': 'Level 3 reached',
        'symbol': '★',
        'unlocked': level >= 3,
        'color': const Color(0xFF4F46E5),
      },
      {
        'title': 'Math Wizard',
        'desc': 'Calculus explorer',
        'symbol': 'π',
        'unlocked': xp >= 200,
        'color': const Color(0xFF059669),
      },
      {
        'title': 'Quiz Ace',
        'desc': '5+ quizzes done',
        'symbol': '✓',
        'unlocked': quizzes >= 5,
        'color': const Color(0xFFD97706),
      },
      {
        'title': 'Centurion',
        'desc': 'Earned 1000+ XP',
        'symbol': 'C',
        'unlocked': xp >= 1000,
        'color': const Color(0xFFDC2626),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trophies & Badges',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: badges.map((badge) {
              final isUnlocked = badge['unlocked'] as bool;
              final color = badge['color'] as Color;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? color.withValues(alpha: 0.08)
                        : const Color(0xFFF6F8F7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked
                          ? color.withValues(alpha: 0.35)
                          : const Color(0xFFE2EAE5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? color.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badge['symbol'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isUnlocked ? color : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badge['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: isUnlocked ? AppColors.onSurface : Colors.grey,
                        ),
                      ),
                      Text(
                        isUnlocked ? 'Unlocked' : 'Locked',
                        style: GoogleFonts.manrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isUnlocked ? color : Colors.grey,
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

class _BioCard extends StatelessWidget {
  const _BioCard({required this.profile});
  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Philosophy',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.learningGoal.trim().isEmpty
                ? 'Building intellectual mastery one realm at a time. Conquering challenges through curious exploration and persistence.'
                : profile.learningGoal,
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.55,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
