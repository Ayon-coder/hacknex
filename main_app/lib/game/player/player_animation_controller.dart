import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../config/game_assets.dart';
import '../managers/asset_manager.dart';
import 'player_animation_state.dart';

/// Facing directions for the player character.
enum PlayerFacing { up, down, left, right }

/// Reusable animation controller managing directional player sprite sheet animations
/// (Up -> walk_back/idle_back, Down -> walk_front/idle_front, Left -> walk_left, Right -> walk_right)
/// with 0° rotation guaranteed at all times.
class PlayerAnimationController {
  final Map<String, SpriteAnimationTicker> _animationTickers = {};

  /// Current active animation state (idle, walk, interact).
  PlayerAnimationState currentState = PlayerAnimationState.idle;

  /// Current facing direction (up, down, left, right).
  PlayerFacing currentFacing = PlayerFacing.down;

  /// Velocity threshold to trigger walking state.
  final double movementThreshold;

  PlayerAnimationController({
    this.movementThreshold = 5.0,
  });

  /// Loads directional player animations from game-assets pipeline.
  Future<void> load() async {
    final assetManager = GameAssetManager();

    // Helper to load and build sprite sequence animation
    Future<SpriteAnimationTicker?> buildTicker(List<String> framePaths, double stepTime) async {
      for (final path in framePaths) {
        if (!assetManager.images.containsKey(path)) {
          try {
            await assetManager.images.load(path);
          } catch (_) {}
        }
      }
      final anim = assetManager.buildSequenceAnimation(
        framePaths: framePaths,
        stepTime: stepTime,
      );
      return anim?.createTicker();
    }

    // 1. Idle Front (Down / Left / Right)
    final idleFrontTicker = await buildTicker([
      PlayerAssets.idleArcanistIdleFront01,
      PlayerAssets.idleArcanistIdleFront02,
      PlayerAssets.idleArcanistIdleFront03,
    ], 0.20);
    if (idleFrontTicker != null) _animationTickers['idle_front'] = idleFrontTicker;

    // 2. Idle Back (Up)
    final idleBackTicker = await buildTicker([
      PlayerAssets.idleArcanistIdleBack01,
      PlayerAssets.idleArcanistIdleBack02,
    ], 0.25);
    if (idleBackTicker != null) _animationTickers['idle_back'] = idleBackTicker;

    // 3. Walk Back (Up)
    final walkBackTicker = await buildTicker([
      PlayerAssets.walkArcanistWalkBack,
      PlayerAssets.idleArcanistIdleBack01,
      PlayerAssets.walkArcanistWalkBack,
      PlayerAssets.idleArcanistIdleBack02,
    ], 0.15);
    if (walkBackTicker != null) _animationTickers['walk_back'] = walkBackTicker;

    // 4. Walk Front (Down)
    final walkFrontTicker = await buildTicker([
      PlayerAssets.idleArcanistIdleFront01,
      PlayerAssets.idleArcanistIdleFront02,
      PlayerAssets.idleArcanistIdleFront03,
    ], 0.14);
    if (walkFrontTicker != null) _animationTickers['walk_front'] = walkFrontTicker;

    // 5. Walk Left (Left)
    final walkLeftTicker = await buildTicker([
      PlayerAssets.walkArcanistWalkLeft01,
      PlayerAssets.walkArcanistWalkLeft02,
    ], 0.14);
    if (walkLeftTicker != null) _animationTickers['walk_left'] = walkLeftTicker;

    // 6. Walk Right (Right)
    final walkRightTicker = await buildTicker([
      PlayerAssets.walkArcanistWalkRight01,
      PlayerAssets.walkArcanistWalkRight02,
    ], 0.14);
    if (walkRightTicker != null) _animationTickers['walk_right'] = walkRightTicker;
  }

  /// Automatically updates facing direction and active animation ticker based on movement velocity.
  void update({
    required Vector2 velocity,
    required double dt,
    double baseSpeed = 160.0,
  }) {
    final double speed = velocity.length;

    if (speed > movementThreshold) {
      currentState = PlayerAnimationState.walk;

      // Determine nearest cardinal direction for diagonal movement
      final double dx = velocity.x;
      final double dy = velocity.y;

      if (dy.abs() > dx.abs()) {
        currentFacing = dy < 0 ? PlayerFacing.up : PlayerFacing.down;
      } else {
        currentFacing = dx < 0 ? PlayerFacing.left : PlayerFacing.right;
      }
    } else if (currentState != PlayerAnimationState.interact) {
      currentState = PlayerAnimationState.idle;
    }

    final String activeKey = _getActiveAnimationKey();

    double speedFactor = 1.0;
    if (currentState == PlayerAnimationState.walk) {
      speedFactor = (speed / baseSpeed).clamp(0.5, 1.8);
    }

    _animationTickers[activeKey]?.update(dt * speedFactor);
  }

  String _getActiveAnimationKey() {
    if (currentState == PlayerAnimationState.walk) {
      switch (currentFacing) {
        case PlayerFacing.up:
          return 'walk_back';
        case PlayerFacing.down:
          return 'walk_front';
        case PlayerFacing.left:
          return 'walk_left';
        case PlayerFacing.right:
          return 'walk_right';
      }
    } else {
      return currentFacing == PlayerFacing.up ? 'idle_back' : 'idle_front';
    }
  }

  void triggerInteraction() {
    currentState = PlayerAnimationState.interact;
    Future.delayed(const Duration(milliseconds: 500), () {
      currentState = PlayerAnimationState.idle;
    });
  }

  Sprite? getCurrentSprite() {
    final String activeKey = _getActiveAnimationKey();
    final sprite = _animationTickers[activeKey]?.getSprite();
    if (sprite != null) return sprite;

    // Fallback to idle front
    return _animationTickers['idle_front']?.getSprite();
  }

  bool render(Canvas canvas, {required Vector2 size}) {
    final sprite = getCurrentSprite();
    if (sprite != null) {
      sprite.render(canvas, size: size);
      return true;
    }
    return false;
  }
}
