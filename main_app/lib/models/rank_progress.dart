import 'package:flutter/material.dart';

import '../config/game_assets.dart';

/// Central, configurable definition of the KnowledgeVerse rank ladder.
class RankTier {
  const RankTier({
    required this.name,
    required this.minXp,
    required this.color,
    required this.emblem,
    required this.reward,
  });

  final String name;
  final int minXp;
  final Color color;
  final String emblem;
  final String reward;
}

abstract final class RankProgression {
  static const tiers = <RankTier>[
    RankTier(name: 'Bronze', minXp: 0, color: Color(0xFFB16A42), emblem: RankAssets.bronze, reward: 'Unlock the Discovery District'),
    RankTier(name: 'Silver', minXp: 1000, color: Color(0xFF8291A2), emblem: RankAssets.silver, reward: 'Unlock cooperative quests'),
    RankTier(name: 'Gold', minXp: 2500, color: Color(0xFFD6A821), emblem: RankAssets.gold, reward: 'Unlock the Innovation Foundry'),
    RankTier(name: 'Platinum', minXp: 5000, color: Color(0xFF5598A5), emblem: RankAssets.platinum, reward: 'Unlock advanced civilization upgrades'),
    RankTier(name: 'Diamond', minXp: 10000, color: Color(0xFF735FE8), emblem: RankAssets.diamond, reward: 'Unlock the Crystal Citadel'),
  ];

  static RankTier forXp(int xp) => tiers.lastWhere(
        (tier) => xp >= tier.minXp,
        orElse: () => tiers.first,
      );

  static RankTier? nextForXp(int xp) {
    final currentIndex = tiers.indexOf(forXp(xp));
    return currentIndex == tiers.length - 1 ? null : tiers[currentIndex + 1];
  }

  static double progressFor(int xp) {
    final current = forXp(xp);
    final next = nextForXp(xp);
    if (next == null) return 1;
    return ((xp - current.minXp) / (next.minXp - current.minXp)).clamp(0.0, 1.0);
  }
}
