import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/rank_progress.dart';

/// A compact, reusable display of the XP-derived progression tier.
class RankBadge extends StatelessWidget {
  const RankBadge({super.key, required this.xp, this.compact = false, this.onDark = false});

  final int xp;
  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final tier = RankProgression.forXp(xp);
    final height = compact ? 30.0 : 38.0;
    return Container(
      height: height,
      padding: EdgeInsets.only(left: 3, right: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: .13) : tier.color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: onDark ? Colors.white.withValues(alpha: .25) : tier.color.withValues(alpha: .35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ClipOval(child: Image.asset(tier.emblem, width: height - 6, height: height - 6, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.workspace_premium_rounded, size: height - 12, color: tier.color))),
        const SizedBox(width: 5),
        Text(tier.name.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: compact ? 9 : 10.5, fontWeight: FontWeight.w900, letterSpacing: .35, color: onDark ? Colors.white : tier.color)),
      ]),
    );
  }
}
