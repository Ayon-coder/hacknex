import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/buildings/building_data.dart';
import '../game/managers/building_manager.dart';
import '../models/player_profile.dart';
import '../services/student_progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hud_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<_DashboardData> _loadDashboard() async {
    final profile = await PlayerProfile.load() ?? const PlayerProfile();
    final progress = await StudentProgress.load();
    return _DashboardData(profile: profile, progress: progress);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.skyBlue, AppColors.surface],
            ),
          ),
        ),
        const Positioned(top: 0, left: 0, right: 0, child: HudBar()),
        Positioned(
          top: kHudBarHeight,
          left: 16,
          right: 16,
          bottom: kNavBarReserve,
          child: FutureBuilder<_DashboardData>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return _ErrorState(
                  onRetry: () {
                    setState(() => _dashboardFuture = _loadDashboard());
                  },
                );
              }
              return AnimatedBuilder(
                animation: BuildingManager(),
                builder: (context, _) => _DashboardContent(
                  data: snapshot.data!,
                  buildings: BuildingManager().allBuildings,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data, required this.buildings});

  final _DashboardData data;
  final List<BuildingData> buildings;

  @override
  Widget build(BuildContext context) {
    final activeSubjects = data.profile.subjects;
    final visibleBuildings = buildings.where((building) {
      if (!building.unlocked) return false;
      if (activeSubjects.isEmpty) return _isMathematics(building.subject);
      return activeSubjects.any(
        (subject) =>
            building.subject.toLowerCase().startsWith(subject.toLowerCase()),
      );
    }).toList();
    final mathematicsBuildings = visibleBuildings
        .where((building) => _isMathematics(building.subject))
        .toList();
    final mathematicsProgress = _SubjectProgressSummary.fromBuildings(
      mathematicsBuildings,
    );
    final totalXp = mathematicsProgress.currentXp;
    final maxXp = mathematicsProgress.maxXp;
    final level = 1 + (totalXp ~/ 500);
    final levelProgress = maxXp == 0
        ? 0.0
        : ((totalXp / maxXp).clamp(0.0, 1.0)).toDouble();
    final name = data.profile.name.trim().isEmpty
        ? 'Explorer'
        : data.profile.name.trim();
    final accuracy = (data.progress.accuracy * 100).round();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(name: name, profile: data.profile, level: level),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 38,
                child: _OverviewCard(
                  level: level,
                  totalXp: totalXp,
                  progress: levelProgress,
                  accuracy: accuracy,
                  completed: data.progress.quizzesCompleted,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 62,
                child: Column(
                  children: [
                    _StatsRow(progress: data.progress, totalXp: totalXp),
                    const SizedBox(height: 14),
                    _WeeklyActivity(progress: data.progress),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionTitle(
            title: 'Mathematics progress',
            subtitle: 'Overall progress across the Mathematics syllabus',
          ),
          const SizedBox(height: 10),
          if (mathematicsBuildings.isEmpty)
            _EmptyDistricts()
          else
            _SubjectProgressCard(progress: mathematicsProgress),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  bool _isMathematics(String subject) =>
      subject.toLowerCase().startsWith('mathematics');
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.profile,
    required this.level,
  });

  final String name;
  final PlayerProfile profile;
  final int level;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (profile.grade.isNotEmpty) profile.grade,
      if (profile.curriculum.isNotEmpty) profile.curriculum,
    ].join(' • ');
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryContainer,
          ),
          child: Icon(
            Icons.person_rounded,
            size: 32,
            color: AppColors.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, $name',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                details.isEmpty
                    ? 'Keep building your learning streak.'
                    : details,
                style: GoogleFonts.manrope(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _Pill(icon: Icons.auto_awesome_rounded, label: 'LEVEL $level'),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.level,
    required this.totalXp,
    required this.progress,
    required this.accuracy,
    required this.completed,
  });

  final int level;
  final int totalXp;
  final double progress;
  final int accuracy;
  final int completed;

  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LEARNING OVERVIEW', style: _eyebrow()),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$totalXp',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 4, left: 4),
              child: Text('total XP'),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Level $level progression',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const Divider(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _MiniMetric(value: '$accuracy%', label: 'Accuracy'),
            _MiniMetric(value: '$completed', label: 'Quizzes'),
          ],
        ),
      ],
    ),
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.progress, required this.totalXp});

  final StudentProgress progress;
  final int totalXp;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _StatCard(
          icon: Icons.local_fire_department_rounded,
          value: '${progress.streak}',
          label: 'Day streak',
          color: AppColors.secondaryContainer,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _StatCard(
          icon: Icons.quiz_rounded,
          value: '${progress.questionsAnswered}',
          label: 'Questions',
          color: AppColors.tertiaryContainer,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _StatCard(
          icon: Icons.stars_rounded,
          value: '$totalXp',
          label: 'Focus XP',
          color: AppColors.primaryContainer,
        ),
      ),
    ],
  );
}

class _WeeklyActivity extends StatelessWidget {
  const _WeeklyActivity({required this.progress});

  final StudentProgress progress;

  @override
  Widget build(BuildContext context) {
    final values = progress.lastSevenDays;
    final days = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      return ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];
    });
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('WEEKLY ACTIVITY', style: _eyebrow()),
              Text(
                progress.questionsAnswered == 0
                    ? 'Start your first quiz'
                    : 'Last 7 days',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                7,
                (index) => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 18,
                      height: 12 + values[index] * 44,
                      decoration: BoxDecoration(
                        color: values[index] == 0
                            ? AppColors.surfaceContainerHigh
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      days[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectProgressCard extends StatelessWidget {
  const _SubjectProgressCard({required this.progress});

  final _SubjectProgressSummary progress;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(11),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: progress.color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.calculate_rounded,
              color: progress.color,
              size: 21,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mathematics · Overall syllabus',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.progressRatio,
                    minHeight: 7,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(progress.color),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${progress.currentXp} / ${progress.maxXp} XP across all Mathematics rooms',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'L${progress.level}',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectProgressSummary {
  const _SubjectProgressSummary({
    required this.currentXp,
    required this.maxXp,
    required this.level,
    required this.color,
  });

  final int currentXp;
  final int maxXp;
  final int level;
  final Color color;

  double get progressRatio =>
      maxXp == 0 ? 0 : (currentXp / maxXp).clamp(0.0, 1.0).toDouble();

  factory _SubjectProgressSummary.fromBuildings(List<BuildingData> buildings) {
    return _SubjectProgressSummary(
      currentXp: buildings.fold<int>(
        0,
        (sum, building) => sum + building.currentXp,
      ),
      maxXp: buildings.fold<int>(
        0,
        (sum, building) => sum + building.xpRequired,
      ),
      level: buildings.isEmpty
          ? 1
          : buildings.fold<int>(
              0,
              (highest, building) =>
                  building.level > highest ? building.level : highest,
            ),
      color: buildings.isEmpty ? AppColors.primary : buildings.first.themeColor,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => _Card(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(14)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.outlineVariant),
    ),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        subtitle,
        style: GoogleFonts.manrope(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
    ],
  );
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w900,
          fontSize: 17,
        ),
      ),
      Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
    ],
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.primaryContainer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.onPrimaryContainer),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.onPrimaryContainer,
          ),
        ),
      ],
    ),
  );
}

class _EmptyDistricts extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _Card(
    child: Row(
      children: [
        const Icon(Icons.explore_rounded, color: AppColors.primary, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'No active districts yet. Select a subject to personalise your dashboard.',
            style: GoogleFonts.manrope(color: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: _Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 30),
          const SizedBox(height: 8),
          const Text('Unable to load your dashboard.'),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

TextStyle _eyebrow() => GoogleFonts.plusJakartaSans(
  fontSize: 10,
  fontWeight: FontWeight.w800,
  letterSpacing: 0.8,
  color: AppColors.onSurfaceVariant,
);

class _DashboardData {
  const _DashboardData({required this.profile, required this.progress});

  final PlayerProfile profile;
  final StudentProgress progress;
}
