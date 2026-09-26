import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../config/game_constants.dart';

/// Pure logic controller handling player kinematics, vector calculations, velocity lerping,
/// and orientation angle interpolation.
class PlayerController {
  final Vector2 velocity = Vector2.zero();
  double currentAngle = 0.0;
  double _targetAngle = 0.0;
  final double speed;

  PlayerController({
    this.speed = GameConstants.playerSpeed,
  });

  /// Computes player position displacement and facing angle based on joystick input vector.
  void updateKinematics({
    required Vector2 currentPosition,
    required Vector2 playerSize,
    required JoystickComponent? joystick,
    required double dt,
  }) {
    final Vector2 targetVelocity = Vector2.zero();

    if (joystick != null && joystick.direction != JoystickDirection.idle) {
      final Vector2 delta = joystick.relativeDelta;
      targetVelocity.setFrom(delta * speed);
      _targetAngle = delta.screenAngle();

      // Smoothly rotate facing angle towards target joystick direction
      currentAngle = _lerpAngle(currentAngle, _targetAngle, dt * 14.0);
    }

    // Interpolate velocity for smooth acceleration and deceleration
    velocity.lerp(targetVelocity, (dt * 15.0).clamp(0.0, 1.0));

    // Update position translation
    currentPosition.add(velocity * dt);

    // Keep position clamped within world boundaries
    final double halfSizeX = playerSize.x / 2;
    final double halfSizeY = playerSize.y / 2;
    currentPosition.x = currentPosition.x.clamp(halfSizeX, GameConstants.worldWidth - halfSizeX);
    currentPosition.y = currentPosition.y.clamp(halfSizeY, GameConstants.worldHeight - halfSizeY);
  }

  /// Smoothly interpolates between two angles in radians avoiding wrap-around jumps.
  double _lerpAngle(double current, double target, double t) {
    final double clampedT = t.clamp(0.0, 1.0);
    double diff = (target - current) % (2 * math.pi);
    if (diff > math.pi) diff -= 2 * math.pi;
    if (diff < -math.pi) diff += 2 * math.pi;
    return current + diff * clampedT;
  }
}
