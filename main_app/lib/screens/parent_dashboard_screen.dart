import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/parent_dashboard_database.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_ui.dart';
import 'parent_dashboard_widgets.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key, required this.account});

  final ParentAccount account;

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  late Future<_DashboardLoad> _dashboardFuture;
  int? _childId;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadForChild();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _DashboardAppBar(account: widget.account),
      body: WorldBackdrop(child: FutureBuilder<_DashboardLoad>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _DashboardMessage(
              icon: Icons.cloud_off_rounded,
              title: 'We could not load the learning overview.',
              action: () => setState(() => _dashboardFuture = _loadForChild()),
              actionLabel: 'Try again',
            );
          }
          final data = snapshot.data!;
          if (data.children.isEmpty || data.selected == null) {
            return const _DashboardMessage(
              icon: Icons.family_restroom_rounded,
              title: 'No children are linked to this account yet.',
            );
          }
          return _DashboardView(
            children: data.children,
            selected: data.selected!,
            bundle: data.bundle!,
            onChildChanged: _selectChild,
          );
        },
      )),
    );
  }

  Future<_DashboardBundle> _loadDashboard(int childId) async {
    final db = ParentDashboardDatabase.instance;
    final results = await Future.wait([
      db.getSubjectPerformance(childId),
      db.getTopicPerformance(childId),
      db.getRecentActivity(childId),
      db.getPerformanceTrend(childId, days: 30),
    ]);
    return _DashboardBundle(
      subjects: results[0] as List<SubjectPerformance>,
      topics: results[1] as List<TopicPerformance>,
      activities: results[2] as List<RecentActivity>,
      trend: results[3] as List<TrendPoint>,
    );
  }

  Future<_DashboardLoad> _loadForChild([int? childId]) async {
    final children = await ParentDashboardDatabase.instance.getChildren(
      widget.account.id,
    );
    if (children.isEmpty) return const _DashboardLoad.empty();
    final selectedId = childId ?? _childId ?? children.first.id;
    final selected = children.firstWhere(
      (child) => child.id == selectedId,
      orElse: () => children.first,
    );
    return _DashboardLoad(
      children: children,
      selected: selected,
      bundle: await _loadDashboard(selected.id),
    );
  }

  void _selectChild(int childId) {
    if (childId == _childId) return;
    setState(() {
      _childId = childId;
      _dashboardFuture = _loadForChild(childId);
    });
  }
}

class _DashboardLoad {
  const _DashboardLoad({
    required this.children,
    required this.selected,
    required this.bundle,
  });
  const _DashboardLoad.empty()
      : children = const [],
        selected = null,
        bundle = null;

  final List<ChildSummary> children;
  final ChildSummary? selected;
  final _DashboardBundle? bundle;
}

class _DashboardMessage extends StatelessWidget {
  const _DashboardMessage({
    required this.icon,
    required this.title,
    this.action,
    this.actionLabel,
  });
  final IconData icon;
  final String title;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 42, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(title, textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
            if (action != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: action, child: Text(actionLabel ?? 'Retry')),
            ],
          ]),
        ),
      ),
    ),
  );
}

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar({required this.account});
  final ParentAccount account;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.white,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: Color(0xFFE4EBE7)),
    ),
    titleSpacing: 24,
    title: Text(
      'KnowledgeVerse',
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w900,
        fontSize: 18,
      ),
    ),
    actions: [
      IconButton(
        tooltip: 'Notifications',
        onPressed: () {},
        icon: const Icon(Icons.notifications_none_rounded),
      ),
      CircleAvatar(
        radius: 17,
        backgroundColor: AppColors.primaryContainer,
        child: Text(
          account.name.isEmpty ? 'P' : account.name[0].toUpperCase(),
          style: const TextStyle(color: AppColors.onPrimaryContainer),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        account.name,
        style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
      const SizedBox(width: 20),
    ],
  );
}

class _DashboardBundle {
  const _DashboardBundle({
    required this.subjects,
    required this.topics,
    required this.activities,
    required this.trend,
  });
  final List<SubjectPerformance> subjects;
  final List<TopicPerformance> topics;
  final List<RecentActivity> activities;
  final List<TrendPoint> trend;
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.children,
    required this.selected,
    required this.bundle,
    required this.onChildChanged,
  });

  final List<ChildSummary> children;
  final ChildSummary selected;
  final _DashboardBundle bundle;
  final ValueChanged<int> onChildChanged;

  @override
  Widget build(BuildContext context) {
    final mastery = bundle.subjects.isEmpty
        ? 0.0
        : bundle.subjects
                  .map((subject) => subject.averageScore)
                  .reduce((a, b) => a + b) /
              bundle.subjects.length;
    final focus = bundle.topics.where((topic) => topic.score < 75).toList()
      ..sort((a, b) => a.score.compareTo(b.score));
    final attempted = bundle.topics.fold<int>(
      0,
      (sum, topic) => sum + topic.attempts,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 900;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: ListView(
              padding: EdgeInsets.fromLTRB(wide ? 42 : 18, 28, wide ? 42 : 18, 40),
              children: [
            _WelcomeHeader(
              parentName: widgetParentName(context),
              child: selected,
              children: children,
              onChildChanged: onChildChanged,
            ),
            const SizedBox(height: 25),
            _AnimatedWrap(
              delay: 0,
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: MasteryHero(
                            mastery: mastery,
                            subjects: bundle.subjects,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 6,
                          child: _OverviewGrid(
                            wide: wide,
                            mastery: mastery,
                            activities: bundle.activities.length,
                            attempted: attempted,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        MasteryHero(mastery: mastery, subjects: bundle.subjects),
                        const SizedBox(height: 14),
                        _OverviewGrid(
                          wide: wide,
                          mastery: mastery,
                          activities: bundle.activities.length,
                          attempted: attempted,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 28),
            _SectionHeading(
              title: 'Subject performance',
              subtitle: 'See how your child is progressing across subjects.',
            ),
            const SizedBox(height: 12),
            _AnimatedWrap(
              delay: 80,
              child: _SubjectSection(
                subjects: bundle.subjects,
                topics: bundle.topics,
              ),
            ),
            const SizedBox(height: 28),
            _SectionHeading(
              title: 'Areas to focus',
              subtitle: 'A few topics that could benefit from more practice.',
            ),
            const SizedBox(height: 12),
            _AnimatedWrap(
              delay: 160,
              child: _FocusSection(topics: focus.take(4).toList(), wide: wide),
            ),
            const SizedBox(height: 28),
            _AnimatedWrap(
              delay: 240,
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _TrendCard(points: bundle.trend)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActivityCard(activities: bundle.activities),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _TrendCard(points: bundle.trend),
                        const SizedBox(height: 16),
                        _ActivityCard(activities: bundle.activities),
                      ],
                    ),
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  String widgetParentName(BuildContext context) {
    final state = context
        .findAncestorStateOfType<_ParentDashboardScreenState>();
    return state?.widget.account.name ?? 'Parent';
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.parentName,
    required this.child,
    required this.children,
    required this.onChildChanged,
  });
  final String parentName;
  final ChildSummary child;
  final List<ChildSummary> children;
  final ValueChanged<int> onChildChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Good morning, $parentName 👋',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 27,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        "Here's how ${child.name} is progressing today.",
        style: GoogleFonts.manrope(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E9E4)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: child.id,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            items: children
                .map(
                  (item) => DropdownMenuItem(
                    value: item.id,
                    child: Text('${item.name} • ${item.grade}'),
                  ),
                )
                .toList(),
            onChanged: (id) {
              if (id != null) onChildChanged(id);
            },
          ),
        ),
      ),
    ],
  );
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({
    required this.wide,
    required this.mastery,
    required this.activities,
    required this.attempted,
  });
  final bool wide;
  final double mastery;
  final int activities;
  final int attempted;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _OverviewCard(
        label: 'Overall mastery',
        value: '${mastery.round()}%',
        detail: 'Live from subject performance',
        icon: Icons.insights_rounded,
        color: AppColors.primary,
      ),
      const _OverviewCard(
        label: 'Learning time',
        value: 'Tracked',
        detail: 'Across recent activities',
        icon: Icons.schedule_rounded,
        color: Color(0xFF6A8FC5),
      ),
      _OverviewCard(
        label: 'Activities',
        value: '$activities',
        detail: 'Completed sessions',
        icon: Icons.task_alt_rounded,
        color: Color(0xFFE09A52),
      ),
      _OverviewCard(
        label: 'Questions',
        value: '$attempted',
        detail: 'Attempts recorded',
        icon: Icons.help_outline_rounded,
        color: Color(0xFF9A82C5),
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const Spacer(),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(
            begin: 0,
            end: value.endsWith('%')
                ? double.tryParse(value.replaceAll('%', '')) ?? 0
                : 1,
          ),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (_, number, __) => Text(
            value.endsWith('%') ? '${number.round()}%' : value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          detail,
          style: GoogleFonts.manrope(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

class _SubjectSection extends StatelessWidget {
  const _SubjectSection({required this.subjects, required this.topics});
  final List<SubjectPerformance> subjects;
  final List<TopicPerformance> topics;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: subjects.asMap().entries.map((entry) {
        final subject = entry.value;
        final subjectTopics = topics
            .where((topic) => topic.subjectId == subject.subjectId)
            .toList();
        return Column(
          children: [
            InkWell(
              onTap: () => _showSubjectDetails(context, subject, subjectTopics),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Row(
                  children: [
                    _SubjectIcon(name: subject.name),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subject.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                '${subject.averageScore.round()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: subject.averageScore / 100,
                            ),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            builder: (_, value, __) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFE9EFEC),
                                color: _statusColor(subject.averageScore),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _status(subject.averageScore),
                            style: GoogleFonts.manrope(
                              color: _statusColor(subject.averageScore),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
            if (entry.key != subjects.length - 1)
              const Divider(height: 1, indent: 70, endIndent: 18),
          ],
        );
      }).toList(),
    ),
  );

  void _showSubjectDetails(
    BuildContext context,
    SubjectPerformance subject,
    List<TopicPerformance> topics,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF6F8F7),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${subject.averageScore.round()}% mastery',
                style: GoogleFonts.manrope(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              ...topics.map(
                (topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: Row(
                    children: [
                      Expanded(child: Text(topic.name)),
                      SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: topic.score / 100,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        '${topic.score.round()}%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusSection extends StatelessWidget {
  const _FocusSection({required this.topics, required this.wide});
  final List<TopicPerformance> topics;
  final bool wide;

  Widget _buildTopicCard(TopicPerformance topic) {
    final needed = math.max(0, 75 - topic.score).round();
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Focus Topic',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8A5416),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            topic.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${topic.score.round()}% mastery',
            style: GoogleFonts.manrope(fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            '+$needed pts to target',
            style: GoogleFonts.manrope(
              color: const Color(0xFFC17B3D),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return const _SurfaceCard(
        child: Text('Every tracked topic is at or above the 75% target.'),
      );
    }
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < topics.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: _buildTopicCard(topics[i])),
          ],
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTopicCard(topics[0])),
            if (topics.length > 1) ...[
              const SizedBox(width: 12),
              Expanded(child: _buildTopicCard(topics[1])),
            ],
          ],
        ),
        if (topics.length > 2) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTopicCard(topics[2])),
              if (topics.length > 3) ...[
                const SizedBox(width: 12),
                Expanded(child: _buildTopicCard(topics[3])),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _TrendCard extends StatefulWidget {
  const _TrendCard({required this.points});
  final List<TrendPoint> points;
  @override
  State<_TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<_TrendCard> {
  int _days = 30;
  @override
  Widget build(BuildContext context) {
    final points = widget.points.length > _days
        ? widget.points.sublist(widget.points.length - _days)
        : widget.points;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionHeading(
                  title: 'Learning progress',
                  subtitle: 'Mastery over time',
                ),
              ),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7d')),
                  ButtonSegment(value: 30, label: Text('30d')),
                ],
                selected: {_days},
                onSelectionChanged: (value) =>
                    setState(() => _days = value.first),
                showSelectedIcon: false,
                style: ButtonStyle(
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 150,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, progress, __) => CustomPaint(
                painter: _TrendPainter(points: points, progress: progress),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.points, required this.progress});
  final List<TrendPoint> points;
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final line = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    final path = Path();
    final area = Path();
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width / 2
          : i * size.width / (points.length - 1);
      final y =
          size.height - (points[i].score.clamp(0, 100) / 100) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        area.moveTo(x, size.height);
        area.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        area.lineTo(x, y);
      }
    }
    area.lineTo(size.width, size.height);
    area.close();
    canvas.drawPath(area, fill);
    final metric = path.computeMetrics().firstOrNull;
    if (metric != null) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), line);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.progress != progress;
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activities});
  final List<RecentActivity> activities;

  static IconData _activityIcon(String type) {
    switch (type) {
      case 'Quiz completed':
        return Icons.quiz_rounded;
      case 'Practice session':
        return Icons.edit_note_rounded;
      case 'Flashcard drill':
        return Icons.style_rounded;
      case 'Interactive lesson':
        return Icons.play_lesson_rounded;
      case 'Challenge mode':
        return Icons.emoji_events_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  static Color _scoreColor(double score) => score >= 80
      ? const Color(0xFF39845A)
      : score >= 60
          ? const Color(0xFF6688A5)
          : const Color(0xFFC17B3D);

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Recent activity',
          subtitle: 'Latest learning moments',
        ),
        const SizedBox(height: 9),
        ...activities
            .take(6)
            .map(
              (activity) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      _scoreColor(activity.score).withValues(alpha: 0.12),
                  child: Icon(
                    _activityIcon(activity.activityType),
                    size: 17,
                    color: _scoreColor(activity.score),
                  ),
                ),
                title: Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(activity.activityType),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _scoreColor(activity.score).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${activity.score.round()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: _scoreColor(activity.score),
                    ),
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}


class _SubjectIcon extends StatelessWidget {
  const _SubjectIcon({required this.name});
  final String name;

  IconData get _icon {
    final n = name.toLowerCase();
    if (n.contains('math')) return Icons.calculate_rounded;
    if (n.contains('science')) return Icons.science_rounded;
    if (n.contains('english')) return Icons.menu_book_rounded;
    if (n.contains('history')) return Icons.account_balance_rounded;
    if (n.contains('computer')) return Icons.terminal_rounded;
    return Icons.auto_stories_rounded;
  }

  Color get _tint {
    final n = name.toLowerCase();
    if (n.contains('math')) return const Color(0xFF4F46E5);
    if (n.contains('science')) return const Color(0xFF059669);
    if (n.contains('english')) return const Color(0xFFD97706);
    if (n.contains('history')) return const Color(0xFFDC2626);
    if (n.contains('computer')) return const Color(0xFF7C3AED);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_icon, color: _tint, size: 21),
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        subtitle,
        style: GoogleFonts.manrope(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    ],
  );
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0xFFE6EEEA)),
    ),
    child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
  );
}

class _AnimatedWrap extends StatelessWidget {
  const _AnimatedWrap({required this.child, required this.delay});
  final Widget child;
  final int delay;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 350 + delay),
    curve: Curves.easeOutCubic,
    builder: (_, value, __) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - value)),
        child: child,
      ),
    ),
  );
}

String _status(double score) => score >= 80
    ? 'Strong progress'
    : score >= 60
    ? 'Developing'
    : 'Needs practice';

Color _statusColor(double score) => score >= 80
    ? const Color(0xFF39845A)
    : score >= 60
    ? const Color(0xFF6688A5)
    : const Color(0xFFC17B3D);
