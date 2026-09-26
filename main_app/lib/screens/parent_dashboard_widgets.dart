import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/parent_dashboard_database.dart';
import '../theme/app_theme.dart';

class MasteryHero extends StatelessWidget {
  const MasteryHero({super.key, required this.mastery, required this.subjects});
  final double mastery;
  final List<SubjectPerformance> subjects;

  @override
  Widget build(BuildContext context) {
    final strong = subjects.where((s) => s.averageScore >= 80).length;
    final developing = subjects.where((s) => s.averageScore >= 60 && s.averageScore < 80).length;
    final attention = subjects.where((s) => s.averageScore < 60).length;
    final total = math.max(1, subjects.length);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF164D32), Color(0xFF287744)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .22), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(children: [
        SizedBox(width: 120, height: 120, child: _MasteryRing(value: mastery / 100)),
        const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Learning snapshot', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 5),
          Text('A clear view of where support matters most.', style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: .78), fontSize: 12)),
          const SizedBox(height: 13),
          _Legend(label: 'Strong', count: strong, total: total, color: const Color(0xFF84E29A)),
          const SizedBox(height: 6),
          _Legend(label: 'Developing', count: developing, total: total, color: const Color(0xFF9FC5FF)),
          const SizedBox(height: 6),
          _Legend(label: 'Needs attention', count: attention, total: total, color: const Color(0xFFFFC477)),
        ])),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.count, required this.total, required this.color});
  final String label;
  final int count;
  final int total;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 7),
    Expanded(child: Text(label, style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: .9), fontSize: 11, fontWeight: FontWeight.w600))),
    Text('$count/$total', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
  ]);
}

class _MasteryRing extends StatelessWidget {
  const _MasteryRing({required this.value});
  final double value;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value.clamp(0, 1)),
    duration: const Duration(milliseconds: 900),
    curve: Curves.easeOutCubic,
    builder: (_, progress, __) => CustomPaint(
      painter: _MasteryRingPainter(progress),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${(progress * 100).round()}%', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
        Text('MASTERY', style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: .72), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ])),
    ),
  );
}

class _MasteryRingPainter extends CustomPainter {
  const _MasteryRingPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 9;
    final track = Paint()..color = Colors.white.withValues(alpha: .18)..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    final value = Paint()..color = const Color(0xFF9DE8A4)..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, math.pi * 2 * progress, false, value);
  }
  @override
  bool shouldRepaint(covariant _MasteryRingPainter old) => old.progress != progress;
}
