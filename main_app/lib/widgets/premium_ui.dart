import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared, restrained game-world surfaces used by the app's Flutter screens.
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
              color: gradient == null ? Colors.white.withValues(alpha: .94) : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: .72)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
}

class PremiumPrimaryButton extends StatefulWidget {
  const PremiumPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  State<PremiumPrimaryButton> createState() => _PremiumPrimaryButtonState();
}

class _PremiumPrimaryButtonState extends State<PremiumPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
        onTapUp: widget.onPressed == null ? null : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? .97 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3C9A4C), AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 9),
                ],
                Text(widget.label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      );
}

class WorldBackdrop extends StatelessWidget {
  const WorldBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDDF4FF), Color(0xFFF7FAF6), Color(0xFFDDF0DE)],
          ),
        ),
        child: Stack(children: [
          // The subject-selection archipelago remains the visual anchor for
          // non-game screens too, at a restrained opacity for readability.
          Positioned.fill(
            child: Opacity(
              opacity: .14,
              child: Image.asset(
                'assets/images/splash_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFEAF8FF).withValues(alpha: .72),
                    const Color(0xFFF7FAF6).withValues(alpha: .88),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -110,
            right: -75,
            child: _Orb(color: AppColors.tertiaryContainer.withValues(alpha: .34), size: 270),
          ),
          Positioned(
            bottom: -130,
            left: -80,
            child: _Orb(color: AppColors.primaryContainer.withValues(alpha: .38), size: 300),
          ),
          // Stack otherwise gives non-positioned content loose constraints.
          // Dashboards and scroll views must receive the full available area.
          Positioned.fill(child: child),
        ]),
      );
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
