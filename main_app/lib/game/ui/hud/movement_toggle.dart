import 'package:flutter/material.dart';
import '../../managers/game_state.dart';

/// Reference-style movement mode toggle — pill-shaped dark button with crosshair icon.
class MovementToggleWidget extends StatefulWidget {
  final MovementMode currentMode;
  final VoidCallback? onToggle;

  const MovementToggleWidget({
    super.key,
    required this.currentMode,
    this.onToggle,
  });

  @override
  State<MovementToggleWidget> createState() => _MovementToggleWidgetState();
}

class _MovementToggleWidgetState extends State<MovementToggleWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isJoystick = widget.currentMode == MovementMode.joystick;
    final String modeLabel = isJoystick ? 'Joystick Mode' : 'Tap Mode';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onToggle != null) {
          widget.onToggle!();
        } else {
          GameState().toggleMovementMode();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xEE122040),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF6B8CAE),
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isJoystick ? Icons.gamepad : Icons.touch_app,
                color: const Color(0xFF89B4FA),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                modeLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
