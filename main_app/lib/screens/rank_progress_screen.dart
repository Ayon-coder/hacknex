import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/buildings/building_data.dart';
import '../game/managers/building_manager.dart';
import '../models/player_profile.dart';
import '../models/rank_progress.dart';
import '../services/student_progress_service.dart';
import '../theme/app_theme.dart';
import 'leaderboard_screen.dart';

class RankProgressScreen extends StatefulWidget {
  const RankProgressScreen({super.key, this.onBackToSubjectSelection});

  final VoidCallback? onBackToSubjectSelection;

  @override
  State<RankProgressScreen> createState() => _RankProgressScreenState();
}

class _RankProgressScreenState extends State<RankProgressScreen> {
  late Future<_RankData> _data;
  RankTier? _selectedTier;

  @override
  void initState() {
    super.initState();
    _data = _loadData();
  }

  Future<_RankData> _loadData() async {
    final profile = await PlayerProfile.load();
    final progress = await StudentProgress.load();
    final buildings = BuildingManager().allBuildings;
    final xp = buildings.fold<int>(0, (sum, building) => sum + building.currentXp);
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
    return AnimatedBuilder(
      animation: BuildingManager(),
      builder: (context, _) => FutureBuilder<_RankData>(
        future: _data,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) return const Center(child: CircularProgressIndicator());
          final refreshed = data.copyWith(
            xp: BuildingManager().allBuildings.fold<int>(0, (sum, b) => sum + b.currentXp),
            buildings: BuildingManager().allBuildings,
          );
          return _RankView(
            data: refreshed,
            selectedTier: _selectedTier,
            onTierTap: (tier) => setState(() => _selectedTier = tier),
            onBackToSubjectSelection: widget.onBackToSubjectSelection,
          );
        },
      ),
    );
  }
}

class _RankView extends StatelessWidget {
  const _RankView({required this.data, required this.selectedTier, required this.onTierTap, this.onBackToSubjectSelection});
  final _RankData data;
  final RankTier? selectedTier;
  final ValueChanged<RankTier> onTierTap;
  final VoidCallback? onBackToSubjectSelection;

  @override
  Widget build(BuildContext context) {
    final tier = RankProgression.forXp(data.xp);
    final next = RankProgression.nextForXp(data.xp);
    final percent = RankProgression.progressFor(data.xp);
    final remaining = next == null ? 0 : next.minXp - data.xp;
    return Container(
      color: const Color(0xFFF4F8F5),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('RANK & PROGRESS', style: _label()),
                      Text('Your learning legend', style: GoogleFonts.plusJakartaSans(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                    ])),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LeaderboardScreen(onBackToSubjectSelection: onBackToSubjectSelection))),
                      icon: const Icon(Icons.emoji_events_rounded),
                      tooltip: 'Open leaderboard',
                    ),
                  ]),
                  const SizedBox(height: 18),
                  _HeroCard(data: data, tier: tier, next: next, percent: percent, remaining: remaining),
                  const SizedBox(height: 24),
                  Text('RANK JOURNEY', style: _label()),
                  const SizedBox(height: 10),
                  _RankJourney(xp: data.xp, selectedTier: selectedTier, onTierTap: onTierTap),
                  if (selectedTier != null) ...[
                    const SizedBox(height: 10),
                    _TierDetail(tier: selectedTier!, isUnlocked: data.xp >= selectedTier!.minXp),
                  ],
                  const SizedBox(height: 24),
                  Text('YOUR NEXT MOVES', style: _label()),
                  const SizedBox(height: 10),
                  _ActionPlan(data: data, remaining: remaining, nextName: next?.name),
                  const SizedBox(height: 24),
                  Text('SUBJECT MASTERY', style: _label()),
                  const SizedBox(height: 10),
                  _SubjectProgress(buildings: data.buildings),
                  const SizedBox(height: 24),
                  Text('RECENT ACHIEVEMENTS', style: _label()),
                  const SizedBox(height: 10),
                  _Achievements(data: data),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.data, required this.tier, required this.next, required this.percent, required this.remaining});
  final _RankData data;
  final RankTier tier;
  final RankTier? next;
  final double percent;
  final int remaining;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [tier.color.withValues(alpha: .95), const Color(0xFF163C37)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [BoxShadow(color: tier.color.withValues(alpha: .28), blurRadius: 24, offset: const Offset(0, 10))],
    ),
    child: Row(children: [
      Hero(tag: 'rank-${tier.name}', child: _Emblem(tier: tier, size: 104, glow: true)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('CURRENT RANK', style: _label(color: Colors.white70)),
        Text(tier.name.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 3),
        Text('${data.xp} XP', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFFFFE6A6))),
        const SizedBox(height: 15),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: percent), duration: const Duration(milliseconds: 850), curve: Curves.easeOutCubic,
          builder: (context, value, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: value, minHeight: 10, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD166)))),
            const SizedBox(height: 7),
            Text(next == null ? 'Legendary rank achieved!' : '${(percent * 100).round()}% · $remaining XP to ${next!.name}', style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: .86), fontWeight: FontWeight.w700, fontSize: 12)),
          ]),
        ),
      ])),
    ]),
  );
}

class _RankJourney extends StatelessWidget {
  const _RankJourney({required this.xp, required this.selectedTier, required this.onTierTap});
  final int xp;
  final RankTier? selectedTier;
  final ValueChanged<RankTier> onTierTap;
  @override
  Widget build(BuildContext context) => SizedBox(height: 150, child: ListView.separated(
    scrollDirection: Axis.horizontal, itemCount: RankProgression.tiers.length,
    separatorBuilder: (_, __) => Container(width: 24, alignment: Alignment.center, child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.outlineVariant)),
    itemBuilder: (context, index) {
      final tier = RankProgression.tiers[index];
      final current = RankProgression.forXp(xp).name == tier.name;
      final unlocked = xp >= tier.minXp;
      return InkWell(
        onTap: () => onTierTap(tier), borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(duration: const Duration(milliseconds: 220), width: 96, padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: current ? tier.color.withValues(alpha: .14) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: current ? tier.color : const Color(0xFFE1E8E3), width: current ? 2 : 1), boxShadow: current ? [BoxShadow(color: tier.color.withValues(alpha: .25), blurRadius: 14)] : null),
          child: Column(children: [
            _Emblem(tier: tier, size: 65, glow: current, muted: !unlocked),
            const SizedBox(height: 3),
            Text(tier.name, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: unlocked ? AppColors.onSurface : AppColors.textSecondary)),
            Text(unlocked ? (current ? 'CURRENT' : 'UNLOCKED') : '${tier.minXp ~/ 1000}k XP', style: GoogleFonts.manrope(fontSize: 9, fontWeight: FontWeight.w700, color: current ? tier.color : AppColors.textSecondary)),
          ])),
      );
    },
  ));
}

class _TierDetail extends StatelessWidget {
  const _TierDetail({required this.tier, required this.isUnlocked});
  final RankTier tier; final bool isUnlocked;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: tier.color.withValues(alpha: .08), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded, color: tier.color), const SizedBox(width: 10), Expanded(child: Text('${tier.name} · ${tier.minXp}+ XP\n${tier.reward}', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface)))]));
}

class _ActionPlan extends StatelessWidget {
  const _ActionPlan({required this.data, required this.remaining, required this.nextName});
  final _RankData data; final int remaining; final String? nextName;
  @override
  Widget build(BuildContext context) {
    final actions = [
      ('🧩', 'Complete challenges', 50, data.quizzes < 3 ? 3 : 1),
      ('📚', 'Finish a lesson', 100, 1),
      ('🎯', 'Complete quests', 150, (remaining / 150).ceil().clamp(1, 3)),
      ('🔥', 'Keep your streak', 25, data.streak == 0 ? 3 : 1),
    ];
    return Container(padding: const EdgeInsets.all(8), decoration: _card(), child: Column(children: [
      for (final action in actions) ListTile(leading: Text(action.$1, style: const TextStyle(fontSize: 22)), title: Text(action.$2, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13)), subtitle: Text('Complete ${action.$4} more → +${action.$3 * action.$4} XP', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.primary)), trailing: const Icon(Icons.chevron_right_rounded)),
      if (nextName != null) Padding(padding: const EdgeInsets.fromLTRB(10, 4, 10, 10), child: Text('$remaining XP away from $nextName — every activity builds your civilization.', style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary))),
    ]));
  }
}

class _SubjectProgress extends StatelessWidget {
  const _SubjectProgress({required this.buildings}); final List<BuildingData> buildings;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: _card(), child: Column(children: buildings.map((building) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Row(children: [Icon(building.icon, size: 20, color: building.themeColor), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(building.name.replaceAll(' House', ''), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 5), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: building.progressRatio, minHeight: 7, color: building.themeColor, backgroundColor: building.themeColor.withValues(alpha: .14)))])), const SizedBox(width: 10), Text('${(building.progressRatio * 100).round()}%', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 11, color: building.themeColor))]))).toList()));
}

class _Achievements extends StatelessWidget {
  const _Achievements({required this.data}); final _RankData data;
  @override
  Widget build(BuildContext context) {
    final achievements = [('🧠', 'Knowledge Explorer', 'Earn 1,000 XP', data.xp >= 1000), ('🔥', 'Streak Keeper', '${data.streak} day learning streak', data.streak >= 3), ('⚔️', 'Quest Conqueror', 'Complete 5 quizzes', data.quizzes >= 5)];
    return SizedBox(height: 142, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: achievements.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (context, index) { final a = achievements[index]; return Container(width: 150, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: a.$4 ? const Color(0xFFFFF8E1) : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: a.$4 ? const Color(0xFFFFD166) : const Color(0xFFE1E8E3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.$1, style: const TextStyle(fontSize: 25)), const Spacer(), Text(a.$2, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(a.$4 ? 'Unlocked' : a.$3, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.manrope(fontSize: 10, color: a.$4 ? AppColors.secondary : AppColors.textSecondary))])); }));
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem({required this.tier, required this.size, this.glow = false, this.muted = false}); final RankTier tier; final double size; final bool glow; final bool muted;
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: muted ? .38 : 1,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: glow ? [BoxShadow(color: tier.color.withValues(alpha: .55), blurRadius: 18, spreadRadius: 2)] : null),
      child: ClipOval(child: Image.asset(tier.emblem, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.workspace_premium_rounded, color: tier.color, size: size * .6))),
    ),
  );
}

BoxDecoration _card() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE1E8E3)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .035), blurRadius: 12, offset: const Offset(0, 4))]);
TextStyle _label({Color color = AppColors.textSecondary}) => GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: color);

class _RankData {
  const _RankData({required this.name, required this.xp, required this.streak, required this.quizzes, required this.accuracy, required this.buildings});
  final String name; final int xp; final int streak; final int quizzes; final double accuracy; final List<BuildingData> buildings;
  _RankData copyWith({int? xp, List<BuildingData>? buildings}) => _RankData(name: name, xp: xp ?? this.xp, streak: streak, quizzes: quizzes, accuracy: accuracy, buildings: buildings ?? this.buildings);
}
