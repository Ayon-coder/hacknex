import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Interactive button component floating above a building when the player is nearby.
class InteractionButtonComponent extends PositionComponent with TapCallbacks {
  final String buildingName;
  final VoidCallback onPressed;
  bool isVisible = false;

  InteractionButtonComponent({
    required this.buildingName,
    required this.onPressed,
  }) : super(
          size: Vector2(110.0, 32.0),
          anchor: Anchor.center,
          priority: 20,
        );

  final Paint _btnBgPaint = Paint()
    ..color = const Color(0xFFF5E0DC)
    ..style = PaintingStyle.fill;

  final Paint _btnBorderPaint = Paint()
    ..color = const Color(0xFF1E1E2E)
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  @override
  void onTapDown(TapDownEvent event) {
    if (isVisible) {
      onPressed();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;
    super.render(canvas);

    final RRect rrect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(16.0),
    );

    // Draw pill-shaped button background and border
    canvas.drawRRect(rrect, _btnBgPaint);
    canvas.drawRRect(rrect, _btnBorderPaint);

    // Draw button text label
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: 'Enter $buildingName',
        style: const TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF181825),
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }
}
