import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Abstract base class for non-player characters (NPCs).
/// Prepared extension point for future AI pathfinding, dialogue, and interaction behaviors.
abstract class NpcBase extends PositionComponent with CollisionCallbacks {
  final String npcId;
  final String displayName;

  NpcBase({
    required this.npcId,
    required this.displayName,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );
}
