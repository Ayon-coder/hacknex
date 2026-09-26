import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/asset_paths.dart';
import '../../config/game_constants.dart';
import '../buildings/building_component.dart';
import '../managers/asset_manager.dart';
import '../managers/movement_controller.dart';
import 'player_animation_controller.dart';

/// Footstep dust particle emitted when the player is walking.
class _FootstepParticle {
  Vector2 position;
  Vector2 velocity;
  double alpha;
  double radius;
  double lifespan;

  _FootstepParticle({
    required this.position,
    required this.velocity,
    required this.alpha,
    required this.radius,
    required this.lifespan,
  });

  void update(double dt) {
    position.add(velocity * dt);
    alpha = (alpha - dt * 1.2).clamp(0.0, 1.0);
    radius += dt * 3.0;
    lifespan -= dt;
  }

  bool get isDead => lifespan <= 0 || alpha <= 0;
}

/// Player component with zero rotation (angle = 0° always), cardinal directional animations
/// (Up -> walk_back/idle_back, Down -> walk_front/idle_front, Left -> walk_left, Right -> walk_right),
/// smooth pathfinding/joystick kinematics, drop shadow, footstep particles, and idle breathing.
class Player extends PositionComponent with CollisionCallbacks {
  JoystickComponent? joystick;
  final MovementController controller;
  final PlayerAnimationController animationController = PlayerAnimationController();

  /// Active directional vector computed from WASD / Arrow keys.
  final Vector2 keyboardDelta = Vector2.zero();

  Sprite? _arcanistSprite; // Fallback single-frame sprite from game-assets

  double _idleTime = 0.0;
  double _footstepTimer = 0.0;
  final List<_FootstepParticle> _footstepParticles = [];
  final math.Random _random = math.Random();

  Player({
    required Vector2 position,
    this.joystick,
    double speed = GameConstants.playerSpeed,
  })  : controller = MovementController(speed: speed),
        super(
          position: position,
          size: Vector2.all(GameConstants.playerSize),
          anchor: Anchor.center,
        );

  /// Updates WASD keyboard movement state.
  void updateKeyboardKeys(Set<LogicalKeyboardKey> keysPressed) {
    keyboardDelta.setZero();

    // W or Up Arrow -> Move Up (negative Y in 2D canvas coordinates)
    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      keyboardDelta.y -= 1.0;
    }

    // S or Down Arrow -> Move Down (positive Y)
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      keyboardDelta.y += 1.0;
    }

    // A or Left Arrow -> Move Left (negative X)
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      keyboardDelta.x -= 1.0;
    }

    // D or Right Arrow -> Move Right (positive X)
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      keyboardDelta.x += 1.0;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(CircleHitbox());
    await animationController.load();

    // Load arcanist sprite as fallback when animation frames are missing
    _arcanistSprite = GameAssetManager().getSprite(AssetPaths.playerArcanist);
  }

  @override
  void update(double dt) {
    super.update(dt);

    controller.updateKinematics(
      currentPosition: position,
      playerSize: size,
      joystick: joystick,
      keyboardDelta: keyboardDelta,
      dt: dt,
    );

    // CRITICAL REQUIREMENT: Disable all sprite rotation. Angle must always remain 0°.
    angle = 0.0;

    animationController.update(
      velocity: controller.velocity,
      dt: dt,
      baseSpeed: controller.speed,
    );

    final double currentSpeed = controller.velocity.length;

    if (currentSpeed > 15.0) {
      _idleTime = 0.0;
      _footstepTimer += dt;
      if (_footstepTimer >= 0.14) {
        _footstepTimer = 0.0;
        _footstepParticles.add(
          _FootstepParticle(
            position: Vector2(
              (size.x / 2) + ((_random.nextDouble() - 0.5) * 8.0),
              size.y - 4.0,
            ),
            velocity: Vector2(
              (_random.nextDouble() - 0.5) * 12.0,
              -10.0 - (_random.nextDouble() * 8.0),
            ),
            alpha: 0.6,
            radius: 2.0 + (_random.nextDouble() * 2.0),
            lifespan: 0.45,
          ),
        );
      }
    } else {
      _idleTime += dt;
      _footstepTimer = 0.0;
    }

    for (int i = _footstepParticles.length - 1; i >= 0; i--) {
      _footstepParticles[i].update(dt);
      if (_footstepParticles[i].isDead) {
        _footstepParticles.removeAt(i);
      }
    }
  }

  void triggerInteractionState() {
    animationController.triggerInteraction();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is BuildingComponent) {
      _resolveBuildingCollision(other);
    }
  }

  void _resolveBuildingCollision(BuildingComponent building) {
    controller.clearTargetDestination();

    final double playerRadius = size.x / 2;
    final double bMinX = building.position.x - building.size.x / 2;
    final double bMaxX = building.position.x + building.size.x / 2;
    final double bMinY = building.position.y - building.size.y / 2;
    final double bMaxY = building.position.y + building.size.y / 2;

    final double closestX = position.x.clamp(bMinX, bMaxX);
    final double closestY = position.y.clamp(bMinY, bMaxY);
    final double diffX = position.x - closestX;
    final double diffY = position.y - closestY;
    final double distanceSq = diffX * diffX + diffY * diffY;

    if (distanceSq < playerRadius * playerRadius) {
      final double distance = math.sqrt(distanceSq);
      if (distance > 0.0001) {
        final double normalX = diffX / distance;
        final double normalY = diffY / distance;
        final double penetration = playerRadius - distance;
        position.x += normalX * penetration;
        position.y += normalY * penetration;
      } else {
        final double distLeft = (position.x - bMinX).abs();
        final double distRight = (bMaxX - position.x).abs();
        final double distTop = (position.y - bMinY).abs();
        final double distBottom = (bMaxY - position.y).abs();
        final double minDist = math.min(math.min(distLeft, distRight), math.min(distTop, distBottom));
        if (minDist == distLeft) { position.x = bMinX - playerRadius; }
        else if (minDist == distRight) { position.x = bMaxX + playerRadius; }
        else if (minDist == distTop) { position.y = bMinY - playerRadius; }
        else { position.y = bMaxY + playerRadius; }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double center = size.x / 2;

    // 1. Soft circular drop shadow attached beneath player feet
    final double speed = controller.velocity.length;
    final double shadowPulse = speed > 15.0 ? math.sin(_idleTime * 12.0) * 0.06 : 0.0;
    final double shadowWidth = (size.x * 0.72) * (1.0 + shadowPulse);
    final double shadowHeight = 9.0 * (1.0 - shadowPulse * 0.5);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center, size.y - 1.0),
        width: shadowWidth,
        height: shadowHeight,
      ),
      Paint()
        ..color = const Color(0x50000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );

    // 2. Footstep dust particles
    for (final p in _footstepParticles) {
      canvas.drawCircle(
        Offset(p.position.x, p.position.y),
        p.radius,
        Paint()..color = const Color(0x88D9E0EE).withValues(alpha: p.alpha),
      );
    }

    // 3. Idle breathing scale transform
    canvas.save();
    if (controller.velocity.length <= 15.0) {
      final double breathY = math.sin(_idleTime * 3.5) * 0.035;
      final double breathX = -breathY * 0.5;
      canvas.translate(center, size.y / 2);
      canvas.scale(1.0 + breathX, 1.0 + breathY);
      canvas.translate(-center, -size.y / 2);
    }

    // 4. Directional sprite animation (0° rotation always)
    final bool animRendered = animationController.render(canvas, size: size);
    if (!animRendered && _arcanistSprite != null) {
      _arcanistSprite!.render(canvas, size: size);
    }

    canvas.restore();
  }
}

typedef PlayerComponent = Player;
