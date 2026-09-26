import 'package:flutter/material.dart';

/// Reference-style gear settings button — circular dark button.
class SettingsButtonWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const SettingsButtonWidget({super.key, this.onTap});

  @override
  State<SettingsButtonWidget> createState() => _SettingsButtonWidgetState();
}

class _SettingsButtonWidgetState extends State<SettingsButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _rotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _rotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _rotController.forward(from: 0);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedBuilder(
          animation: _rotController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotController.value * 1.5,
              child: child,
            );
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xEE122040),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6B8CAE), width: 2.0),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.settings, color: Color(0xFFCDD6F4), size: 22),
          ),
        ),
      ),
    );
  }
}
