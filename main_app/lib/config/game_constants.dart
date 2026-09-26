import 'package:flutter/material.dart';

/// Game configuration and styling constants.
abstract final class GameConstants {
  // --- Player Constants ---
  /// Movement speed in pixels per second.
  static const double playerSpeed = 250.0;

  /// Player avatar dimensions (width/height).
  static const double playerSize = 48.0;

  /// Primary player color.
  static const Color playerColor = Color(0xFF00E676);

  /// Direction indicator marker color.
  static const Color playerDirectionColor = Color(0xFFFFFFFF);

  // --- Joystick Constants ---
  /// Outer background radius for virtual HUD joystick.
  static const double joystickRadius = 60.0;

  /// Inner movable knob radius for virtual HUD joystick.
  static const double joystickKnobRadius = 24.0;

  /// Margin distance from bottom-left corner.
  static const double joystickMargin = 40.0;

  // --- World & Grid Constants ---
  /// Grid cell size for visual motion tracking.
  static const double gridCellSize = 64.0;

  /// World background color.
  static const Color gridBgColor = Color(0xFF181825);

  /// Grid line color.
  static const Color gridLineColor = Color(0xFF313244);

  /// World map total width (One single handcrafted island canvas).
  static const double worldWidth = 1600.0;

  /// World map total height (One single handcrafted island canvas).
  static const double worldHeight = 1100.0;

  // --- Building / Obstacle Constants ---
  /// Default building / obstacle size.
  static const double obstacleSize = 56.0;

  /// Obstacle fill color.
  static const Color obstacleColor = Color(0xFFF38BA8);
}
