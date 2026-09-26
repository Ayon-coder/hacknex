import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../managers/asset_manager.dart';
import '../managers/audio_manager.dart';
import '../managers/building_manager.dart';
import '../managers/game_state.dart';
import 'building_data.dart';
import 'interaction_button_component.dart';

/// Floating particle entity rendered when building is selected or leveled up.
class _BuildingParticle {
  Vector2 position;
  Vector2 velocity;
  double alpha;
  double radius;
  double lifespan;

  _BuildingParticle({
    required this.position,
    required this.velocity,
    required this.alpha,
    required this.radius,
    required this.lifespan,
  });

  void update(double dt) {
    position.add(velocity * dt);
    alpha = (alpha - dt * 0.9).clamp(0.0, 1.0);
    lifespan -= dt;
  }

  bool get isDead => lifespan <= 0 || alpha <= 0;
}

/// Reusable Building component featuring original high-quality building PNG sprite graphics,
/// physical collision, soft drop shadow, level-gated visual environmental effects (Level 1 base,
/// Level 2 soft aura & sparkles, Level 3 grand magic aura & base rune circle), level-up flash animation,
/// golden floating labels, and Building Action Panel triggers.
class BuildingComponent extends PositionComponent with CollisionCallbacks {
  /// Structured building data specification.
  BuildingData buildingData;

  /// Optional relative image asset path for building sprite.
  final String? assetPath;

  /// Proximity radius distance trigger for showing interaction button.
  final double triggerRadius;

  /// Whether building is currently highlighted as selected tap target.
  bool isHighlighted = false;

  bool _wasHighlighted = false;
  double _bounceTime = 0.0;
  double _pulseTime = 0.0;
  double _flashTime = 0.0;
  final List<_BuildingParticle> _particles = [];
  final math.Random _random = math.Random();

  final void Function(BuildingComponent building)? onPlayerEnter;
  final void Function(BuildingComponent building)? onPlayerLeave;
  final void Function(BuildingComponent building)? onInteract;

  bool _isPlayerInProximity = false;
  Sprite? _buildingSprite;
  int _lastRenderedLevel = 1;

  String get name => buildingData.name;
  IconData get icon => buildingData.icon;
  Color get buildingColor => buildingData.themeColor;
  bool get isPlayerInProximity => _isPlayerInProximity;

  late final InteractionButtonComponent _interactionButton;

  BuildingComponent({
    required this.buildingData,
    required Vector2 position,
    Vector2? size,
    this.assetPath,
    this.triggerRadius = 50.0,
    this.onPlayerEnter,
    this.onPlayerLeave,
    this.onInteract,
  }) : super(
         position: position,
         size: size ?? Vector2(100.0, 100.0),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());

    _lastRenderedLevel = buildingData.level;
    final String spritePath = assetPath ?? buildingData.sprite;
    _buildingSprite = GameAssetManager().getSprite(spritePath);

    _interactionButton = InteractionButtonComponent(
      buildingName: name,
      onPressed: () {
        if (_isPlayerInProximity) {
          triggerActionPanel();
        }
      },
    );

    _interactionButton.position = Vector2(size.x / 2, -28);
    add(_interactionButton);
  }

  /// Triggers opening the building action panel UI.
  void triggerActionPanel() {
    if (!buildingData.subject.toLowerCase().startsWith('mathematics')) {
      return;
    }
    GameState().openBuildingPanel(buildingData);
    onInteract?.call(this);
  }

  /// Checks if player is near building entrance to display interaction prompt button.
  void checkPlayerProximity(Vector2 playerPosition) {
    final double distance = position.distanceTo(playerPosition);
    final double totalTriggerThreshold = (size.x / 2) + triggerRadius;
    final bool isNearby = distance <= totalTriggerThreshold;

    if (_isPlayerInProximity != isNearby) {
      _isPlayerInProximity = isNearby;
      _interactionButton.isVisible = isNearby;

      if (isNearby) {
        onPlayerEnter?.call(this);
      } else {
        onPlayerLeave?.call(this);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;

    if (_flashTime > 0) {
      _flashTime -= dt;
    }

    // Sync latest BuildingData from BuildingManager
    final updatedData = BuildingManager().getBuilding(buildingData.id);
    if (updatedData != null) {
      if (updatedData.level > _lastRenderedLevel) {
        // Trigger Level-Up Animation
        _flashTime = 0.45;
        _bounceTime = 0.0;
        AudioManager().playSfx('audio/sfx/interact.wav');
      }
      _lastRenderedLevel = updatedData.level;
      buildingData = updatedData;
    }

    if (isHighlighted && !_wasHighlighted) {
      AudioManager().playSfx('audio/sfx/interact.wav');
      _bounceTime = 0.0;
      _particles.clear();
    }
    _wasHighlighted = isHighlighted;

    if (isHighlighted || _flashTime > 0) {
      _bounceTime += dt;

      if (_bounceTime < 0.35) {
        final double bounceScale =
            1.0 + (math.sin(_bounceTime * math.pi / 0.35) * 0.14);
        scale = Vector2.all(bounceScale);
      } else {
        scale = Vector2.all(1.0);
      }

      if (_particles.length < 12 && _random.nextDouble() < 0.4) {
        _particles.add(
          _BuildingParticle(
            position: Vector2(
              _random.nextDouble() * size.x,
              size.y - (_random.nextDouble() * 20),
            ),
            velocity: Vector2(
              (_random.nextDouble() - 0.5) * 20.0,
              -35.0 - (_random.nextDouble() * 25.0),
            ),
            alpha: 0.9,
            radius: 2.5 + (_random.nextDouble() * 2.5),
            lifespan: 0.8 + (_random.nextDouble() * 0.6),
          ),
        );
      }

      for (int i = _particles.length - 1; i >= 0; i--) {
        _particles[i].update(dt);
        if (_particles[i].isDead) {
          _particles.removeAt(i);
        }
      }
    } else {
      scale = Vector2.all(1.0);
      _bounceTime = 0.0;
      _particles.clear();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double center = size.x / 2;

    // 1. Soft Shadow beneath EVERY building
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center, size.y - 6.0),
        width: size.x * 0.90,
        height: 18.0,
      ),
      Paint()
        ..color = const Color(0x60000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
    );

    // 2. LEVEL 2 & LEVEL 3 VISUAL UPGRADE EFFECTS (Ambient Magical Aura & Glow)
    if (buildingData.level >= 2) {
      final double glowAlpha = (buildingData.level == 3) ? 0.45 : 0.25;
      final double auraRadius =
          (size.x / 2) + 12.0 + (math.sin(_pulseTime * 4.0) * 5.0);

      // Level 2/3 Soft Ambient Aura Glow
      canvas.drawCircle(
        Offset(center, center),
        auraRadius,
        Paint()
          ..color =
              (buildingData.level == 3
                      ? const Color(0xFFF9E2AF)
                      : buildingColor)
                  .withValues(alpha: glowAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16.0),
      );
    }

    if (buildingData.level >= 3) {
      // Level 3 Base Magic Circle Decal
      final double runeRadius = (size.x / 2) + 18.0;
      canvas.drawCircle(
        Offset(center, size.y - 12.0),
        runeRadius,
        Paint()
          ..color = const Color(0xFFF9E2AF).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // 3. Golden Glowing Aura & Selection Ring when selected
    if (isHighlighted) {
      final double ringRadius =
          (size.x / 2) + 14.0 + (math.sin(_pulseTime * 6.0) * 4.0);

      canvas.drawCircle(
        Offset(center, center),
        ringRadius,
        Paint()
          ..color = const Color(0xFFF9E2AF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );

      final RRect glowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-6, -6, size.x + 12, size.y + 12),
        const Radius.circular(20.0),
      );
      canvas.drawRRect(
        glowRRect,
        Paint()
          ..color = buildingColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
    }

    // 4. Render Original High-Quality Building Sprite
    if (_buildingSprite != null) {
      _buildingSprite!.render(canvas, size: size);
    }

    // 5. Render Level-Up White Flash Effect during upgrade
    if (_flashTime > 0) {
      final RRect flashRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(16.0),
      );
      canvas.drawRRect(
        flashRRect,
        Paint()
          ..color = Colors.white.withValues(
            alpha: (_flashTime / 0.45).clamp(0.0, 0.8),
          ),
      );
    }

    // 6. Render Floating Level-Up Green Arrow Badge when UPGRADE AVAILABLE
    if (buildingData.canUpgrade) {
      _renderLevelUpBadge(canvas);
    }

    // 7. Render floating golden label above building
    _renderReferenceLabel(canvas);

    // 8. Floating Sparkle Particles
    if (isHighlighted || buildingData.level >= 2) {
      for (final p in _particles) {
        canvas.drawCircle(
          Offset(p.position.x, p.position.y),
          p.radius,
          Paint()
            ..color =
                (buildingData.level == 3
                        ? const Color(0xFFF9E2AF)
                        : buildingColor)
                    .withValues(alpha: p.alpha)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  /// Renders glowing green level-up arrow badge above building.
  void _renderLevelUpBadge(Canvas canvas) {
    const double badgeY = -92.0;
    final double center = size.x / 2;
    final double bobY = math.sin(_pulseTime * 6.0) * 4.0;

    canvas.drawCircle(
      Offset(center, badgeY + bobY),
      18.0,
      Paint()
        ..color = const Color(0xFFA6E3A1).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0),
    );

    canvas.drawCircle(
      Offset(center, badgeY + bobY),
      14.0,
      Paint()..color = const Color(0xFFA6E3A1),
    );
    canvas.drawCircle(
      Offset(center, badgeY + bobY),
      14.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    final TextPainter arrowPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: '▲',
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w900,
          color: Color(0xFF181825),
        ),
      ),
    );
    arrowPainter.layout();
    arrowPainter.paint(
      canvas,
      Offset(
        center - arrowPainter.width / 2,
        badgeY + bobY - arrowPainter.height / 2,
      ),
    );
  }

  /// Renders reference-style golden pill label above the building.
  void _renderReferenceLabel(Canvas canvas) {
    const double labelY = -58.0;
    final double labelCX = size.x / 2;

    final TextPainter namePainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: '$name (Lv.${buildingData.level})',
        style: const TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w800,
          color: Color(0xFFF9E2AF),
          letterSpacing: 0.3,
        ),
      ),
    );
    namePainter.layout();

    final TextPainter subjectPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: '(${buildingData.subject})',
        style: const TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w500,
          color: Color(0xFFCDD6F4),
        ),
      ),
    );
    subjectPainter.layout();

    final double maxWidth = math.max(namePainter.width, subjectPainter.width);
    const double padH = 12.0;
    const double padV = 6.0;
    final double boxW = maxWidth + padH * 2;
    const double boxH = 36.0;
    final double boxX = labelCX - boxW / 2;

    final RRect labelRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxX, labelY - boxH / 2, boxW, boxH),
      const Radius.circular(8.0),
    );

    final Paint bgPaint = Paint()..color = const Color(0xDD1A1A2E);
    final Paint borderPaint = Paint()
      ..color = const Color(0xCCF9E2AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(labelRRect, bgPaint);
    canvas.drawRRect(labelRRect, borderPaint);

    namePainter.paint(
      canvas,
      Offset(labelCX - namePainter.width / 2, labelY - boxH / 2 + padV - 2),
    );

    subjectPainter.paint(
      canvas,
      Offset(
        labelCX - subjectPainter.width / 2,
        labelY - boxH / 2 + padV + namePainter.height - 2,
      ),
    );
  }
}
