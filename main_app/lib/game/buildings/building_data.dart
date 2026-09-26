import 'package:flutter/material.dart';

/// Reusable Data Model representing building specifications, educational subject,
/// level progression, and available lesson parameters.
class BuildingData {
  /// Unique building identifier.
  final String id;

  /// Display name of the building.
  final String name;

  /// Icon visual representation.
  final IconData icon;

  /// Sprite image asset path (original high-quality building sprite).
  final String sprite;

  /// Current building level (Level 1, Level 2, Level 3).
  final int level;

  /// Educational subject area (e.g. Computer Science, Literature, Science).
  final String subject;

  /// Detailed building description.
  final String description;

  /// Whether building is unlocked for player interaction.
  final bool unlocked;

  /// Current accumulated experience points.
  final int currentXp;

  /// Experience points required to level up.
  final int xpRequired;

  /// Number of interactive lessons available inside building.
  final int lessonsAvailable;

  /// Primary theme color for UI badges and card borders.
  final Color themeColor;

  const BuildingData({
    required this.id,
    required this.name,
    required this.icon,
    required this.sprite,
    required this.level,
    required this.subject,
    required this.description,
    required this.unlocked,
    this.currentXp = 0,
    required this.xpRequired,
    required this.lessonsAvailable,
    this.themeColor = const Color(0xFF89B4FA),
  });

  /// Calculates XP progress ratio [0.0 to 1.0].
  double get progressRatio => (currentXp / xpRequired).clamp(0.0, 1.0);

  /// Whether building can be upgraded to next level.
  bool get canUpgrade => level < 3 && currentXp >= xpRequired;
}
