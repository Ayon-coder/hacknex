import 'package:flutter/material.dart';

/// Bundled background artwork with a gradient stand-in.
///
/// The art is a local asset rather than a remote URL — the hosted URLs this
/// used to point at were ephemeral and left the screen blank once they expired.
/// The gradient remains as the guaranteed visual if the asset is ever missing.
class AppBackgroundImage extends StatelessWidget {
  const AppBackgroundImage({
    super.key,
    required this.assetPath,
    required this.fallbackColors,
    this.fallbackChild,
    this.tint,
    this.tintBlendMode = BlendMode.lighten,
    this.fit = BoxFit.cover,
  });

  final String assetPath;
  final List<Color> fallbackColors;

  /// Painted on top of the fallback gradient — e.g. a stand-in island shape.
  final Widget? fallbackChild;
  final Color? tint;
  final BlendMode tintBlendMode;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: fit,
      color: tint,
      colorBlendMode: tint == null ? null : tintBlendMode,
      errorBuilder: (context, error, stackTrace) =>
          _Fallback(colors: fallbackColors, child: fallbackChild),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.colors, this.child});

  final List<Color> colors;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}
