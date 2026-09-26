import 'package:flame/components.dart';

/// Data model representing level configuration parameters, spawn coordinates, and layout data.
class LevelConfig {
  final int levelNumber;
  final String levelName;
  final Vector2 playerSpawnPoint;
  final List<Vector2> buildingPositions;

  const LevelConfig({
    required this.levelNumber,
    required this.levelName,
    required this.playerSpawnPoint,
    this.buildingPositions = const [],
  });
}
