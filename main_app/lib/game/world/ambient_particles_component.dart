import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_assets.dart';
import '../../config/game_constants.dart';
import '../managers/asset_manager.dart';

class _AmbientParticle {
  double x, y;
  double radius;
  double alpha;
  double speedX, speedY;
  Color color;
  bool isLeaf;
  bool isSmoke;
  bool isFirefly;

  _AmbientParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.alpha,
    required this.speedX,
    required this.speedY,
    required this.color,
    this.isLeaf = false,
    this.isSmoke = false,
    this.isFirefly = false,
  });

  void update(double dt) {
    x += speedX * dt;
    y += speedY * dt;
    if (isSmoke) {
      alpha -= dt * 0.4;
      radius += dt * 8.0;
    } else if (isFirefly) {
      alpha = (alpha + (math.sin(x * 0.1) * 0.05)).clamp(0.2, 0.95);
    }
  }

  bool get isDead => alpha <= 0;
}

/// AAA Ambient Life Particles Component:
/// - Floating magic sparkles near Fountain (800, 520)
/// - Fireflies around trees
/// - Soft blue magic particles near Coding Tower (1140, 760)
/// - Purple magic particles near Astronomy Tower (1160, 300)
/// - Gentle smoke particles near Potion Lab (460, 760)
/// - Leaves drifting across island
class AmbientParticlesComponent extends Component {
  final List<_AmbientParticle> _particles = [];
  final List<_AmbientParticle> _smokeParticles = [];
  final math.Random _random = math.Random(123);

  Sprite? _smokeSprite;
  double _time = 0.0;

  @override
  int get priority => 50;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      _smokeSprite = GameAssetManager().getSprite(EffectAssets.smokePuff);
    } catch (_) {}

    // 1. Magic Sparkles & Hotspots
    final hotspots = [
      const _Hotspot(Offset(800, 520), Color(0xFF89DCEB)), // Fountain cyan
      const _Hotspot(Offset(1140, 760), Color(0xFF89B4FA)), // Coding Tower blue
      const _Hotspot(Offset(1160, 300), Color(0xFFCBA6F7)), // Astronomy Tower purple
      const _Hotspot(Offset(800, 240), Color(0xFFF9E2AF)), // Grand Hall gold
    ];

    for (final spot in hotspots) {
      for (int i = 0; i < 8; i++) {
        _particles.add(
          _AmbientParticle(
            x: spot.center.dx + (_random.nextDouble() - 0.5) * 140.0,
            y: spot.center.dy + (_random.nextDouble() - 0.5) * 100.0,
            radius: 1.8 + _random.nextDouble() * 2.5,
            alpha: 0.4 + _random.nextDouble() * 0.5,
            speedX: (_random.nextDouble() - 0.5) * 16.0,
            speedY: -14.0 - (_random.nextDouble() * 20.0),
            color: spot.color,
          ),
        );
      }
    }

    // 2. Fireflies around tree groves
    for (int i = 0; i < 18; i++) {
      _particles.add(
        _AmbientParticle(
          x: _random.nextDouble() * GameConstants.worldWidth,
          y: _random.nextDouble() * GameConstants.worldHeight,
          radius: 2.2 + _random.nextDouble() * 1.5,
          alpha: 0.6,
          speedX: (_random.nextDouble() - 0.5) * 12.0,
          speedY: (_random.nextDouble() - 0.5) * 12.0,
          color: const Color(0xFFA6E3A1), // Glowing lime green firefly
          isFirefly: true,
        ),
      );
    }

    // 3. Falling leaves
    for (int i = 0; i < 20; i++) {
      _particles.add(
        _AmbientParticle(
          x: _random.nextDouble() * GameConstants.worldWidth,
          y: _random.nextDouble() * GameConstants.worldHeight,
          radius: 3.0 + _random.nextDouble() * 2.0,
          alpha: 0.5 + _random.nextDouble() * 0.3,
          speedX: 18.0 + _random.nextDouble() * 24.0,
          speedY: 10.0 + _random.nextDouble() * 15.0,
          color: const Color(0xFF81C784),
          isLeaf: true,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    for (final p in _particles) {
      p.update(dt);
      if (p.x > GameConstants.worldWidth + 20) p.x = -20;
      if (p.x < -20) p.x = GameConstants.worldWidth + 20;
      if (p.y < -20) p.y = GameConstants.worldHeight + 20;
      if (p.y > GameConstants.worldHeight + 20) p.y = -20;
    }

    // Spawn gentle smoke puffs from Potion Lab chimney (460, 720)
    if (_smokeParticles.length < 12 && _random.nextDouble() < 0.3) {
      _smokeParticles.add(
        _AmbientParticle(
          x: 460.0 + (_random.nextDouble() - 0.5) * 18.0,
          y: 710.0,
          radius: 10.0,
          alpha: 0.55,
          speedX: 6.0 + (_random.nextDouble() * 8.0),
          speedY: -22.0 - (_random.nextDouble() * 12.0),
          color: Colors.white,
          isSmoke: true,
        ),
      );
    }

    for (int i = _smokeParticles.length - 1; i >= 0; i--) {
      _smokeParticles[i].update(dt);
      if (_smokeParticles[i].isDead) {
        _smokeParticles.removeAt(i);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Render Potion Lab chimney smoke puffs
    for (final s in _smokeParticles) {
      if (_smokeSprite != null) {
        _smokeSprite!.render(
          canvas,
          position: Vector2(s.x - s.radius, s.y - s.radius),
          size: Vector2(s.radius * 2, s.radius * 2),
        );
      } else {
        canvas.drawCircle(
          Offset(s.x, s.y),
          s.radius,
          Paint()
            ..color = Colors.white.withValues(alpha: s.alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
        );
      }
    }

    // 2. Render particles & fireflies
    for (final p in _particles) {
      if (p.isLeaf) {
        canvas.save();
        canvas.translate(p.x, p.y);
        canvas.rotate(math.sin(_time * 3.0 + p.x) * 0.4);
        final Path leafPath = Path()
          ..moveTo(0, -p.radius)
          ..quadraticBezierTo(p.radius, 0, 0, p.radius)
          ..quadraticBezierTo(-p.radius, 0, 0, -p.radius);
        canvas.drawPath(leafPath, Paint()..color = p.color.withValues(alpha: p.alpha));
        canvas.restore();
      } else if (p.isFirefly) {
        // Firefly glow aura
        canvas.drawCircle(
          Offset(p.x, p.y),
          p.radius + 3.0,
          Paint()
            ..color = p.color.withValues(alpha: p.alpha * 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
        );
        canvas.drawCircle(Offset(p.x, p.y), p.radius, Paint()..color = Colors.white);
      } else {
        // Magic Sparkle
        canvas.drawCircle(
          Offset(p.x, p.y),
          p.radius,
          Paint()
            ..color = p.color.withValues(alpha: p.alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
        );
      }
    }
  }
}

class _Hotspot {
  final Offset center;
  final Color color;
  const _Hotspot(this.center, this.color);
}
