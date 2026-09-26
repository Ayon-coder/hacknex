import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../config/game_constants.dart';
import 'game_state_manager.dart';

/// Unified Hybrid Movement Controller governing Virtual Joystick manual control
/// and automatic A* path waypoint traversal smoothly with strict island boundary collision clamping.
class MovementController {
  final Vector2 velocity = Vector2.zero();
  double currentAngle = 0.0;
  double _targetAngle = 0.0;
  final double speed;

  /// Active A* calculated path waypoints.
  List<Vector2> targetPath = [];

  /// Current active index in [targetPath].
  int currentWaypointIndex = 0;

  /// Active target destination vector (null when not auto-navigating).
  Vector2? targetDestination;

  /// Distance threshold in pixels to consider waypoint reached.
  final double arrivalThreshold = 16.0;

  /// Distance threshold in pixels to consider final destination reached exactly.
  final double finalArrivalThreshold = 6.0;

  /// Distance radius in pixels over which character decelerates smoothly.
  final double brakingRadius = 110.0;

  MovementController({
    this.speed = GameConstants.playerSpeed,
  });

  /// Sets calculated A* path waypoints for automatic navigation.
  void setPath(List<Vector2> path) {
    if (path.isEmpty) {
      clearPath();
      return;
    }
    targetPath = List.from(path);
    currentWaypointIndex = 0;
    targetDestination = path.last.clone();
  }

  /// Sets direct target destination vector.
  void setTargetDestination(Vector2 destination) {
    targetPath = [destination.clone()];
    currentWaypointIndex = 0;
    targetDestination = destination.clone();
  }

  /// Cancels active path target navigation and notifies FSM.
  void clearPath() {
    targetPath.clear();
    currentWaypointIndex = 0;
    targetDestination = null;
    final currentState = GameStateManager().state;
    if (currentState == GamePlayState.autoWalking) {
      GameStateManager().toExploring();
    }
  }

  /// Cancels active tap target navigation.
  void clearTargetDestination() {
    clearPath();
  }

  /// Calculates player movement and rotation for Hybrid Movement (WASD Keyboard + Joystick + Auto Navigation).
  void updateKinematics({
    required Vector2 currentPosition,
    required Vector2 playerSize,
    required JoystickComponent? joystick,
    Vector2? keyboardDelta,
    required double dt,
  }) {
    final Vector2 targetVelocity = Vector2.zero();

    // Check if user is actively pressing keyboard movement keys (W, A, S, D, or Arrow Keys)
    final bool isKeyboardActive = keyboardDelta != null && !keyboardDelta.isZero();

    // Check if user is actively touching or dragging the virtual joystick
    final bool isJoystickActive = joystick != null &&
        joystick.direction != JoystickDirection.idle &&
        !joystick.relativeDelta.isZero();

    if (isKeyboardActive || isJoystickActive) {
      // RULE 1: Pressing WASD keyboard keys or touching joystick INSTANTLY cancels auto-navigation!
      if (targetPath.isNotEmpty || targetDestination != null) {
        clearPath();
      }

      // Priority to keyboard if active, otherwise joystick
      final Vector2 delta = isKeyboardActive ? keyboardDelta.normalized() : joystick!.relativeDelta;
      targetVelocity.setFrom(delta * speed);
      _targetAngle = delta.screenAngle();
      currentAngle = _lerpAngle(currentAngle, _targetAngle, dt * 14.0);
    } else if (targetPath.isNotEmpty) {
      // RULE 2: Automatic A* Path Waypoint Traversal
      final bool isFinalWaypoint = currentWaypointIndex >= targetPath.length - 1;
      final Vector2 currentWaypoint = targetPath[currentWaypointIndex];
      final Vector2 diff = currentWaypoint - currentPosition;
      final double distance = diff.length;

      final double checkThreshold = isFinalWaypoint ? finalArrivalThreshold : arrivalThreshold;

      if (distance <= checkThreshold) {
        if (!isFinalWaypoint) {
          // Advance to next waypoint along path
          currentWaypointIndex++;
        } else {
          // Reached final destination -> Snap to target position and stop smoothly
          currentPosition.setFrom(targetDestination ?? currentWaypoint);
          velocity.setZero();
          clearPath();
        }
      } else {
        // Calculate smooth arrival braking scalar when approaching final destination
        double speedScalar = 1.0;
        if (isFinalWaypoint) {
          speedScalar = (distance / brakingRadius).clamp(0.15, 1.0);
        }

        final Vector2 dir = diff.normalized();
        targetVelocity.setFrom(dir * (speed * speedScalar));
        _targetAngle = dir.screenAngle();
        currentAngle = _lerpAngle(currentAngle, _targetAngle, dt * 16.0);
      }
    }

    // Unified smooth velocity lerp preserving smooth animations
    velocity.lerp(targetVelocity, (dt * 16.0).clamp(0.0, 1.0));

    // Translate position
    currentPosition.add(velocity * dt);

    // CRITICAL COLLISION GUARD: Island World Boundary Clamping (Player may NEVER walk into the sky!)
    const double rx = 665.0;
    const double ry = 385.0;
    final double nx = (currentPosition.x - 800.0) / rx;
    final double ny = (currentPosition.y - 520.0) / ry;
    final double distSq = nx * nx + ny * ny;

    if (distSq > 1.0) {
      final double scale = 1.0 / math.sqrt(distSq);
      currentPosition.x = 800.0 + nx * scale * rx;
      currentPosition.y = 520.0 + ny * scale * ry;
    }
  }

  /// Smoothly interpolates between two angles in radians.
  double _lerpAngle(double current, double target, double t) {
    final double clampedT = t.clamp(0.0, 1.0);
    double diff = (target - current) % (2 * math.pi);
    if (diff > math.pi) diff -= 2 * math.pi;
    if (diff < -math.pi) diff += 2 * math.pi;
    return current + diff * clampedT;
  }
}
