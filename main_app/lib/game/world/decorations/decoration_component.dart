import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../managers/asset_manager.dart';
import '../../managers/building_manager.dart';

/// Reusable decoration component representing environmental props (trees, rocks, bushes, flowers)
/// rendered using production sprite graphics, with level-gated progression visibility,
/// tree sway animation, and subtle ambient effects.
class DecorationComponent extends PositionComponent {
  final String assetPath;

  /// Required building level (1, 2, 3) to unlock & display this decoration.
  final int requiredLevel;

  /// Optional building ID this decoration belongs to.
  final String? buildingId;

  Sprite? _sprite;
  double _swayTime = 0.0;
  final bool _isTree;
  final math.Random _random = math.Random();

  DecorationComponent({
    required Vector2 position,
    required Vector2 size,
    required this.assetPath,
    this.requiredLevel = 1,
    this.buildingId,
  })  : _isTree = assetPath.contains('tree'),
        super(
          position: position,
          size: size,
          anchor: assetPath.contains('tree') ? Anchor.bottomCenter : Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprite = GameAssetManager().getSprite(assetPath);
    _swayTime = _random.nextDouble() * math.pi * 2;
  }

  /// Evaluates whether this decoration is unlocked based on building level.
  bool get isUnlocked {
    if (requiredLevel <= 1 || buildingId == null) return true;
    final b = BuildingManager().getBuilding(buildingId!);
    return (b?.level ?? 1) >= requiredLevel;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isTree) {
      _swayTime += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!isUnlocked || _sprite == null) return;

    if (_isTree) {
      canvas.save();
      final double swayAngle = math.sin(_swayTime * 1.8) * 0.035;
      canvas.translate(size.x / 2, size.y);
      canvas.rotate(swayAngle);
      canvas.translate(-size.x / 2, -size.y);

      _sprite!.render(canvas, size: size);
      canvas.restore();
    } else {
      _sprite!.render(canvas, size: size);
    }
  }
}
