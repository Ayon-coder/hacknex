import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_constants.dart';

/// Helper factory component providing styled virtual joystick input controls.
abstract final class VirtualJoystick {
  /// Constructs a JoystickComponent styled and positioned for fixed bottom-left HUD overlay.
  static JoystickComponent create() {
    final Paint knobPaint = Paint()
      ..color = const Color(0xCCF5E0DC)
      ..style = PaintingStyle.fill;

    final Paint knobBorderPaint = Paint()
      ..color = const Color(0xFFB4BEFE)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Paint backgroundPaint = Paint()
      ..color = const Color(0x44313244)
      ..style = PaintingStyle.fill;

    final Paint backgroundBorderPaint = Paint()
      ..color = const Color(0x88CDD6F4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    return JoystickComponent(
      knob: CircleComponent(
        radius: GameConstants.joystickKnobRadius,
        paint: knobPaint,
      )..add(
          CircleComponent(
            radius: GameConstants.joystickKnobRadius,
            paint: knobBorderPaint,
          ),
        ),
      background: CircleComponent(
        radius: GameConstants.joystickRadius,
        paint: backgroundPaint,
      )..add(
          CircleComponent(
            radius: GameConstants.joystickRadius,
            paint: backgroundBorderPaint,
          ),
        ),
      margin: const EdgeInsets.only(
        left: GameConstants.joystickMargin,
        bottom: GameConstants.joystickMargin,
      ),
    );
  }
}
