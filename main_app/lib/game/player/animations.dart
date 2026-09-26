import 'package:flame/sprite.dart';
import '../../config/asset_paths.dart';
import '../managers/asset_manager.dart';
import 'player_animation_state.dart';

export 'player_animation_state.dart';

/// Helper managing directional sprite animation tickers for player states (idle & walk in 4 directions: SE, SW, NE, NW).
class PlayerAnimations {
  final Map<String, SpriteAnimationTicker> _animationTickers = {};

  /// Loads animation tickers for all 4 directions (SE, SW, NE, NW) for idle & walk states.
  void load() {
    final assetManager = GameAssetManager();
    const directions = ['se', 'sw', 'ne', 'nw'];

    for (final dir in directions) {
      // 1. Build 6-frame Idle Animation
      final idleFrames = AssetPaths.wizardIdleFrames(dir);
      final idleAnim = assetManager.buildSequenceAnimation(
        framePaths: idleFrames,
        stepTime: 0.15,
      );
      if (idleAnim != null) {
        _animationTickers['idle_$dir'] = idleAnim.createTicker();
      }

      // 2. Build 8-frame Walk Animation
      final walkFrames = AssetPaths.wizardWalkFrames(dir);
      final walkAnim = assetManager.buildSequenceAnimation(
        framePaths: walkFrames,
        stepTime: 0.1,
      );
      if (walkAnim != null) {
        _animationTickers['walk_$dir'] = walkAnim.createTicker();
      }
    }
  }

  /// Ticks active animation frame.
  void update(PlayerAnimationState state, String direction, double dt) {
    final key = '${state.name}_$direction';
    _animationTickers[key]?.update(dt);
  }

  /// Gets current sprite frame for active state and direction.
  Sprite? getCurrentSprite(PlayerAnimationState state, String direction) {
    final key = '${state.name}_$direction';
    return _animationTickers[key]?.getSprite();
  }
}
