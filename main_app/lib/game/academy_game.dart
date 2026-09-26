import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/game_constants.dart';
import 'managers/asset_manager.dart';
import 'managers/game_state.dart';
import 'player/input/virtual_joystick.dart';
import 'world/world_map.dart';

/// Primary game engine class extending [FlameGame].
/// Manages [WorldMap], HUD controls, smooth lerped camera tracking, camera easing toward selected buildings,
/// map boundary clamping, keyboard input (WASD/Arrows/Space/E), and zoom level persistence.
class AcademyGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents {
  late final WorldMap worldMap;
  late final JoystickComponent joystick;

  @override
  Color backgroundColor() => const Color(0xFF1565C0); // Sky blue background

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Preload game assets via GameAssetManager
    await GameAssetManager().preloadAssets();

    // 2. Construct HUD Virtual Joystick control
    joystick = VirtualJoystick.create();

    // 3. Instantiate WorldMap passing joystick input reference
    worldMap = WorldMap(joystick: joystick);

    // 4. Set active game world instance
    world = worldMap;

    // 5. Mount virtual joystick to camera viewport HUD layer (independent of viewfinder zoom)
    camera.viewport.add(joystick);

    // 6. Restore remembered zoom level
    camera.viewfinder.zoom = GameState().zoomLevel;

    // 7. Initial camera positioning at player spawn
    camera.viewfinder.position = worldMap.player.position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (worldMap.isMounted && worldMap.player.isMounted) {
      final double zoom = camera.viewfinder.zoom;
      final Vector2 viewportSize = camera.viewport.size;

      Vector2 targetCamPos = worldMap.player.position;

      // Ease camera slightly toward selected building when auto-navigating to building entrance
      if (worldMap.targetBuilding != null) {
        targetCamPos = (worldMap.player.position * 0.55) + (worldMap.targetBuilding!.position * 0.45);
      }

      // Smooth lerp camera tracking (small movement smoothing, cinematic easing)
      final Vector2 currentCamPos = camera.viewfinder.position;
      final double lerpFactor = (dt * 7.5).clamp(0.0, 1.0);
      final double lerpedX = currentCamPos.x + (targetCamPos.x - currentCamPos.x) * lerpFactor;
      final double lerpedY = currentCamPos.y + (targetCamPos.y - currentCamPos.y) * lerpFactor;

      // Clamp camera viewfinder position inside map boundaries considering zoom level & viewport size
      if (viewportSize.x > 0 && viewportSize.y > 0) {
        final double halfW = (viewportSize.x / 2) / zoom;
        final double halfH = (viewportSize.y / 2) / zoom;

        final double minX = halfW;
        final double maxX = math.max(halfW, GameConstants.worldWidth - halfW);
        final double minY = halfH;
        final double maxY = math.max(halfH, GameConstants.worldHeight - halfH);

        final double clampedX = lerpedX.clamp(minX, maxX);
        final double clampedY = lerpedY.clamp(minY, maxY);

        camera.viewfinder.position = Vector2(clampedX, clampedY);
      } else {
        camera.viewfinder.position = Vector2(lerpedX, lerpedY);
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (worldMap.isMounted && worldMap.player.isMounted) {
      // 1. Pass active keys to player kinematics for WASD / Arrow movement
      worldMap.player.updateKeyboardKeys(keysPressed);

      // 2. Action key (E, Space, or Enter) for interacting with nearby buildings
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.keyE ||
            event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.enter) {
          final bool interacted = worldMap.interactWithNearbyBuilding();
          if (interacted) {
            return KeyEventResult.handled;
          }
        }
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }
}

/// Backward compatibility typedef alias for [AcademyGame].
typedef HexaFallsGame = AcademyGame;
