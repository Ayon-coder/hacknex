import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/parent_dashboard_database.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_ui.dart';
import 'parent_dashboard_screen.dart';

class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final _emailController = TextEditingController(text: 'parent@learncraft.local');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscure = true;
  bool _loading = false;
  String _error = '';

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    final account = await ParentDashboardDatabase.instance.loginParent(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (account != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ParentDashboardScreen(account: account),
        ),
      );
    } else {
      setState(() {
        _loading = false;
        _error = 'Invalid email or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parent Portal',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: WorldBackdrop(child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.family_restroom, size: 36, color: Colors.indigo.shade600),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, Parent!',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to view your child\'s progress',
                  style: GoogleFonts.manrope(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF6F8FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF6F8FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                  width: 176,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Parent Dashboard — shows children, subject performance, recent activity
// ─────────────────────────────────────────────────────────────────────────────

class _ParentDashboard extends StatefulWidget {
  const _ParentDashboard({required this.parent});
  final ParentAccount parent;

  @override
  State<_ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<_ParentDashboard> {
  late Future<_DashboardData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_DashboardData> _load() async {
    final db = ParentDashboardDatabase.instance;
    final children = await db.getChildren(widget.parent.id);
    if (children.isEmpty) {
      return _DashboardData(
        children: [],
        subjects: [],
        activities: [],
        trends: [],
      );
    }
    final childId = children.first.id;
    final subjects = await db.getSubjectPerformance(childId);
    final activities = await db.getRecentActivity(childId);
    final trends = await db.getPerformanceTrend(childId, days: 7);
    return _DashboardData(
      children: children,
      subjects: subjects,
      activities: activities,
      trends: trends,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(
          'Parent Dashboard',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                widget.parent.name,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<_DashboardData>(
        future: _data,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          if (data.children.isEmpty) {
            return Center(
              child: Text(
                'No children linked to this account.',
                style: GoogleFonts.manrope(color: AppColors.textSecondary),
              ),
            );
          }
          final child = data.children.first;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Child Header Card
              _ChildHeaderCard(child: child),
              const SizedBox(height: 20),

              // Subject Performance Cards
              Text(
                'Subject Performance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (data.subjects.isEmpty)
                _EmptyCard(message: 'No subject data yet.')
              else
                ...data.subjects.map((s) => _SubjectCard(subject: s)),

              const SizedBox(height: 20),

              // Recent Activity
              Text(
                'Recent Activity',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (data.activities.isEmpty)
                _EmptyCard(message: 'No recent activity.')
              else
                ...data.activities.map((a) => _ActivityTile(activity: a)),

              const SizedBox(height: 20),

              // Performance Trend
              Text(
                'Performance Trend (7 days)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (data.trends.isEmpty)
                _EmptyCard(message: 'Not enough data for trends.')
              else
                _TrendCard(trends: data.trends),

              const SizedBox(height: 20),

              // Parental Controls
              Text(
                'Controls & Limits',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _ControlsCard(),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.children,
    required this.subjects,
    required this.activities,
    required this.trends,
  });
  final List<ChildSummary> children;
  final List<SubjectPerformance> subjects;
  final List<RecentActivity> activities;
  final List<TrendPoint> trends;
}

// ─── Child Header Card ───────────────────────────────────────────────────────

class _ChildHeaderCard extends StatelessWidget {
  const _ChildHeaderCard({required this.child});
  final ChildSummary child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.indigo.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.indigo.shade200,
            child: Text(
              child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.indigo.shade800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  child.grade,
                  style: GoogleFonts.manrope(
                    color: Colors.indigo.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.school_rounded, color: Colors.indigo.shade400, size: 36),
        ],
      ),
    );
  }
}

// ─── Subject Performance Card ────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});
  final SubjectPerformance subject;

  Color get _color {
    try {
      return Color(int.parse(subject.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final progress = subject.totalTopics > 0
        ? subject.completedTopics / subject.totalTopics
        : 0.0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${subject.completedTopics}/${subject.totalTopics} topics mastered',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${subject.averageScore.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Activity Tile ───────────────────────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});
  final RecentActivity activity;

  IconData get _icon {
    switch (activity.activityType) {
      case 'Quiz completed':
        return Icons.quiz_rounded;
      case 'Practice session':
        return Icons.edit_note_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = activity.score;
    final Color scoreTextColor = score >= 80
        ? Colors.green.shade700
        : score >= 60
            ? Colors.orange.shade800
            : Colors.red.shade700;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: Icon(_icon, color: Colors.indigo.shade600, size: 20),
        ),
        title: Text(
          activity.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          activity.activityType,
          style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: scoreTextColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(
              color: scoreTextColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Trend Card ──────────────────────────────────────────────────────────────

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trends});
  final List<TrendPoint> trends;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: trends.map((t) {
                final barHeight = (t.score / 100.0).clamp(0.05, 1.0) * 80;
                final dayLabel = '${t.date.month}/${t.date.day}';
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        t.score.toStringAsFixed(0),
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 24,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dayLabel,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
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
      ),
    );
  }
}

// ─── Controls Card ───────────────────────────────────────────────────────────

class _ControlsCard extends StatefulWidget {
  @override
  State<_ControlsCard> createState() => _ControlsCardState();
}

class _ControlsCardState extends State<_ControlsCard> {
  bool _timeLimit = true;
  bool _arena = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Daily Time Limit (2 hours)',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            value: _timeLimit,
            onChanged: (v) => setState(() => _timeLimit = v),
            activeThumbColor: Colors.indigo,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(
              'Allow Multiplayer Arena',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            value: _arena,
            onChanged: (v) => setState(() => _arena = v),
            activeThumbColor: Colors.indigo,
          ),
        ],
      ),
    );
  }
}

// ─── Empty State Card ────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            style: GoogleFonts.manrope(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
