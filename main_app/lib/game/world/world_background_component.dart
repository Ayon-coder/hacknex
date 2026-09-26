import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_assets.dart';
import '../../config/game_constants.dart';

/// Cloud entity for drifting sky background.
class _Cloud {
  double x, y, width, height, alpha, speed;
  _Cloud({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.alpha,
    required this.speed,
  });
}

/// Mist particle below waterfalls.
class _WaterfallMistParticle {
  double x, y;
  double radius;
  double alpha;
  double speedY;

  _WaterfallMistParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.alpha,
    required this.speedY,
  });

  void update(double dt) {
    y += speedY * dt;
    alpha -= dt * 0.4;
  }

  bool get isDead => alpha <= 0;
}

class _TilePoint {
  final double x;
  final double y;
  final String tileType;
  _TilePoint(this.x, this.y, {this.tileType = 'stone'});
}

/// WorldBackgroundComponent — Renders AAA Handcrafted Floating Island Hub:
/// - Real floating island with visible cliff PNG tiles (grass_cliff_column, leafy_cliff_column, tall_grass_cliff_chunk)
/// - Ambient occlusion cliff shadow layer
/// - ANIMATED WATERFALLS cascading off cliff edges at South (800, 920), SW (420, 860), and SE (1180, 860)
/// - Rising mist particles below waterfalls
/// - Randomized RPG grass terrain grid
/// - Tile-based stone road network
/// - Animated Central Fountain with blue glow, water ripples & sparkles
class WorldBackgroundComponent extends Component with HasGameReference {
  final List<_Cloud> _clouds = [];
  final List<_WaterfallMistParticle> _mistParticles = [];
  final math.Random _random = math.Random(42);

  // Tile & Prop Sprites
  final List<Sprite> _grassTileSprites = [];
  Sprite? _cliffColumnSprite;
  Sprite? _leafyCliffSprite;
  Sprite? _tallCliffSprite;
  Sprite? _waterfallEdgeSprite;
  Sprite? _wideWaterfallSprite;
  Sprite? _narrowWaterfallSprite;

  Sprite? _stonePathSprite;
  Sprite? _cobblestoneSprite;
  Sprite? _dirtPathSprite;
  Sprite? _stoneFloorPlatformSprite;
  Sprite? _blueGoldTrimSprite;
  Sprite? _fountainSprite;
  Sprite? _gateSprite;

  static const double kPlazaCX = 800.0;
  static const double kPlazaCY = 520.0;
  static const double kPlazaRadius = 115.0;

  final Set<String> _placedRoadTileKeys = {};
  final List<_TilePoint> _roadTiles = [];
  final List<_TilePoint> _plazaTiles = [];
  final List<_TilePoint> _grassTiles = [];
  final List<_TilePoint> _cliffTiles = [];

  double _waterAnimTime = 0.0;
  static const double kTileSize = 36.0;

  @override
  int get priority => -100; // Render behind all game components

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _generateClouds();
    await _loadTileSprites();
    _buildHandcraftedTerrainAndRoads();
  }

  Future<void> _loadTileSprites() async {
    // 1. Grass PNG tile textures
    const grassAssetPaths = [
      TileAssets.grassTile,
      TileAssets.cloverGrassTile,
      TileAssets.grassLeafyGroundTile,
      TileAssets.grassGoldFleckedBlueTile,
      TileAssets.grassWithStonesTile,
      TileAssets.grassPurpleCrystalGroundTile,
    ];

    for (final path in grassAssetPaths) {
      try {
        final sprite = await game.loadSprite(path);
        _grassTileSprites.add(sprite);
      } catch (_) {}
    }

    // 2. Cliff & Waterfall PNG textures
    try {
      _cliffColumnSprite = await game.loadSprite(TileAssets.cliffsGrassCliffColumn);
    } catch (_) {}
    try {
      _leafyCliffSprite = await game.loadSprite(TileAssets.cliffsLeafyCliffColumn);
    } catch (_) {}
    try {
      _tallCliffSprite = await game.loadSprite(TileAssets.cliffsTallGrassCliffChunk);
    } catch (_) {}
    try {
      _waterfallEdgeSprite = await game.loadSprite(TileAssets.waterGrassCliffWaterfallEdge);
    } catch (_) {}
    try {
      _wideWaterfallSprite = await game.loadSprite(TileAssets.waterWideWaterfallSegment);
    } catch (_) {}
    try {
      _narrowWaterfallSprite = await game.loadSprite(TileAssets.waterNarrowWaterfallSegment);
    } catch (_) {}

    // 3. Road & Prop PNG textures
    try {
      _stonePathSprite = await game.loadSprite(TileAssets.roadsStonePathTile);
    } catch (_) {}
    try {
      _cobblestoneSprite = await game.loadSprite(TileAssets.roadsCobblestoneTile);
    } catch (_) {}
    try {
      _dirtPathSprite = await game.loadSprite(TileAssets.roadsDirtPathTile);
    } catch (_) {}
    try {
      _stoneFloorPlatformSprite = await game.loadSprite(DecorationAssets.propsStoneFloorPlatform);
    } catch (_) {}
    try {
      _blueGoldTrimSprite = await game.loadSprite(TileAssets.grassBlueGoldTrimTile);
    } catch (_) {}
    try {
      _fountainSprite = await game.loadSprite(DecorationAssets.propsCentralFountain);
    } catch (_) {}
    try {
      _gateSprite = await game.loadSprite(DecorationAssets.fencesWoodenGate);
    } catch (_) {}
  }

  void _generateClouds() {
    for (int i = 0; i < 10; i++) {
      _clouds.add(_Cloud(
        x: _random.nextDouble() * GameConstants.worldWidth,
        y: 20 + _random.nextDouble() * 260,
        width: 160 + _random.nextDouble() * 220,
        height: 50 + _random.nextDouble() * 70,
        alpha: 0.25 + _random.nextDouble() * 0.25,
        speed: 7.0 + _random.nextDouble() * 10.0,
      ));
    }
  }

  /// Builds randomized RPG grass terrain grid, island cliff borders, and seamless tile-based roads.
  void _buildHandcraftedTerrainAndRoads() {
    _placedRoadTileKeys.clear();
    _roadTiles.clear();
    _plazaTiles.clear();
    _grassTiles.clear();
    _cliffTiles.clear();

    // 1. Central Plaza floor & outer ring
    for (double x = kPlazaCX - kPlazaRadius - 20; x <= kPlazaCX + kPlazaRadius + 20; x += kTileSize) {
      for (double y = kPlazaCY - kPlazaRadius - 20; y <= kPlazaCY + kPlazaRadius + 20; y += kTileSize) {
        final double dist = math.sqrt((x - kPlazaCX) * (x - kPlazaCX) + (y - kPlazaCY) * (y - kPlazaCY));
        if (dist <= kPlazaRadius) {
          final String key = '${(x / kTileSize).round()},${(y / kTileSize).round()}';
          _placedRoadTileKeys.add(key);

          if (dist > kPlazaRadius - 28.0) {
            _plazaTiles.add(_TilePoint(x, y, tileType: 'trim'));
          } else if (dist > kPlazaRadius - 60.0) {
            _plazaTiles.add(_TilePoint(x, y, tileType: 'cobble'));
          } else {
            _plazaTiles.add(_TilePoint(x, y, tileType: 'stone'));
          }
        }
      }
    }

    // 2. Road segments
    final roadSegments = [
      [const Offset(kPlazaCX, kPlazaCY - 80), const Offset(kPlazaCX, 210.0)],
      [const Offset(kPlazaCX, kPlazaCY + 80), const Offset(kPlazaCX, 880.0)],
      [const Offset(kPlazaCX - 80, kPlazaCY), const Offset(310.0, 520.0)],
      [const Offset(kPlazaCX - 60, kPlazaCY - 60), const Offset(400.0, 260.0)],
      [const Offset(kPlazaCX + 60, kPlazaCY - 60), const Offset(1200.0, 260.0)],
      [const Offset(kPlazaCX - 60, kPlazaCY + 60), const Offset(440.0, 770.0)],
      [const Offset(kPlazaCX + 60, kPlazaCY + 60), const Offset(1160.0, 770.0)],
    ];

    for (final seg in roadSegments) {
      _rasterizeRoadSegment(seg[0], seg[1]);
    }

    // 3. Island Cliff Edge Border Ring
    const double rx = 665.0;
    const double ry = 385.0;
    for (double angle = 0; angle < math.pi * 2; angle += 0.08) {
      final double cx = kPlazaCX + math.cos(angle) * rx;
      final double cy = kPlazaCY + math.sin(angle) * ry;
      final String type = (angle > math.pi * 0.25 && angle < math.pi * 0.75) ? 'tall' : 'column';
      _cliffTiles.add(_TilePoint(cx, cy, tileType: type));
    }

    // 4. Randomized RPG Grass Terrain across island surface
    int lastTileIdx = -1;
    int repeatCount = 0;

    for (double x = 140.0; x <= 1460.0; x += kTileSize) {
      for (double y = 140.0; y <= 900.0; y += kTileSize) {
        final double nx = (x - kPlazaCX) / rx;
        final double ny = (y - kPlazaCY) / ry;
        if (nx * nx + ny * ny <= 0.96) {
          final String key = '${(x / kTileSize).round()},${(y / kTileSize).round()}';
          if (!_placedRoadTileKeys.contains(key)) {
            final int hash = ((x.toInt() * 73856093) ^ (y.toInt() * 19349663)).abs();
            int tileIdx = hash % (_grassTileSprites.isEmpty ? 1 : _grassTileSprites.length);

            if (tileIdx == lastTileIdx) {
              repeatCount++;
              if (repeatCount >= 3) {
                tileIdx = (tileIdx + 1) % _grassTileSprites.length;
                repeatCount = 1;
              }
            } else {
              repeatCount = 1;
              lastTileIdx = tileIdx;
            }

            _grassTiles.add(_TilePoint(x, y, tileType: '$tileIdx'));
          }
        }
      }
    }
  }

  void _rasterizeRoadSegment(Offset start, Offset end) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);
    final int steps = (distance / (kTileSize * 0.5)).ceil();

    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      final double cx = start.dx + dx * t;
      final double cy = start.dy + dy * t;

      for (double ox = -kTileSize * 0.5; ox <= kTileSize * 0.5; ox += kTileSize) {
        for (double oy = -kTileSize * 0.5; oy <= kTileSize * 0.5; oy += kTileSize) {
          final double tx = ((cx + ox) / kTileSize).round() * kTileSize;
          final double ty = ((cy + oy) / kTileSize).round() * kTileSize;
          final String key = '${(tx / kTileSize).round()},${(ty / kTileSize).round()}';

          if (!_placedRoadTileKeys.contains(key)) {
            _placedRoadTileKeys.add(key);

            final bool isJunction = i == 0 || i == steps;
            final String type = isJunction ? 'cobble' : 'stone';
            _roadTiles.add(_TilePoint(tx, ty, tileType: type));

            _addBorderTransitions(tx, ty);
          }
        }
      }
    }
  }

  void _addBorderTransitions(double tx, double ty) {
    const offsets = [
      Offset(-kTileSize, 0),
      Offset(kTileSize, 0),
      Offset(0, -kTileSize),
      Offset(0, kTileSize),
    ];

    for (final off in offsets) {
      final double bx = tx + off.dx;
      final double by = ty + off.dy;
      final String bKey = '${(bx / kTileSize).round()},${(by / kTileSize).round()}';

      if (!_placedRoadTileKeys.contains(bKey)) {
        _placedRoadTileKeys.add(bKey);
        _roadTiles.add(_TilePoint(bx, by, tileType: 'dirt'));
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _waterAnimTime += dt;

    for (final cloud in _clouds) {
      cloud.x += cloud.speed * dt;
      if (cloud.x > GameConstants.worldWidth + cloud.width) {
        cloud.x = -cloud.width;
        cloud.y = 20 + _random.nextDouble() * 260;
      }
    }

    // Spawn waterfall mist particles
    if (_mistParticles.length < 25 && _random.nextDouble() < 0.4) {
      const waterfallLocations = [
        Offset(800, 930),
        Offset(420, 875),
        Offset(1180, 875),
      ];

      final spot = waterfallLocations[_random.nextInt(waterfallLocations.length)];
      _mistParticles.add(
        _WaterfallMistParticle(
          x: spot.dx + (_random.nextDouble() - 0.5) * 36.0,
          y: spot.dy + 20.0 + _random.nextDouble() * 15.0,
          radius: 12.0 + _random.nextDouble() * 14.0,
          alpha: 0.45,
          speedY: -12.0 - _random.nextDouble() * 10.0,
        ),
      );
    }

    for (int i = _mistParticles.length - 1; i >= 0; i--) {
      _mistParticles[i].update(dt);
      if (_mistParticles[i].isDead) {
        _mistParticles.removeAt(i);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Sky Gradient Background
    _renderSky(canvas);

    // 2. Drifting Sky Clouds
    _renderClouds(canvas);

    // 3. Island Drop Shadow & Rock Base
    _renderIslandBase(canvas);

    // 4. Visible Island Cliff Edge PNG Tiles
    _renderCliffTiles(canvas);

    // 5. Animated Waterfalls at South, SW, SE Cliff Edges
    _renderWaterfalls(canvas);

    // 6. Randomized RPG Grass Terrain
    _renderRandomizedGrassTerrain(canvas);

    // 7. Tile-Based Road Network
    _renderTileBasedRoads(canvas);

    // 8. Central Magical Fountain
    _renderAnimatedFountain(canvas);
  }

  void _renderSky(Canvas canvas) {
    final worldRect = Rect.fromLTWH(0, 0, GameConstants.worldWidth, GameConstants.worldHeight);
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E88E5), // Vivid sky blue
          Color(0xFF42A5F5), // Mid sky
          Color(0xFF90CAF9), // Near horizon
          Color(0xFFE3F2FD), // Soft horizon glow
        ],
        stops: [0.0, 0.4, 0.75, 1.0],
      ).createShader(worldRect);

    canvas.drawRect(worldRect, skyPaint);
  }

  void _renderClouds(Canvas canvas) {
    for (final cloud in _clouds) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cloud.x, cloud.y), width: cloud.width, height: cloud.height),
        Paint()
          ..color = Colors.white.withValues(alpha: cloud.alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.0),
      );
    }
  }

  void _renderIslandBase(Canvas canvas) {
    // Ambient Occlusion Drop Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(kPlazaCX, kPlazaCY + 45),
        width: 1460,
        height: 880,
      ),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32.0),
    );

    // Rock Cliff Base
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(kPlazaCX, kPlazaCY + 18),
        width: 1440,
        height: 860,
      ),
      Paint()..color = const Color(0xFF5D4E37),
    );

    // Island Top Edge Highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(kPlazaCX, kPlazaCY + 8),
        width: 1432,
        height: 852,
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );
  }

  void _renderCliffTiles(Canvas canvas) {
    final Vector2 cliffSize = Vector2(48.0, 48.0);
    for (final c in _cliffTiles) {
      Sprite? cliffSprite = _cliffColumnSprite;
      if (c.tileType == 'tall' && _tallCliffSprite != null) {
        cliffSprite = _tallCliffSprite;
      } else if (_leafyCliffSprite != null) {
        cliffSprite = _leafyCliffSprite;
      }

      if (cliffSprite != null) {
        cliffSprite.render(
          canvas,
          position: Vector2(c.x - 24.0, c.y - 24.0),
          size: cliffSize,
        );
      }
    }
  }

  void _renderWaterfalls(Canvas canvas) {
    const waterfallSpots = [
      Offset(800, 905), // South
      Offset(420, 850), // South West
      Offset(1180, 850), // South East
    ];

    final double animShift = (math.sin(_waterAnimTime * 6.0) * 3.0);

    for (final spot in waterfallSpots) {
      // 1. Cliff edge waterfall top segment
      if (_waterfallEdgeSprite != null) {
        _waterfallEdgeSprite!.render(
          canvas,
          position: Vector2(spot.dx - 24, spot.dy),
          size: Vector2(48, 32),
        );
      }

      // 2. Cascading waterfall body
      final Sprite? wfSprite = (spot.dx == 800) ? _wideWaterfallSprite : (_narrowWaterfallSprite ?? _wideWaterfallSprite);
      if (wfSprite != null) {
        wfSprite.render(
          canvas,
          position: Vector2(spot.dx - 20, spot.dy + 24 + animShift),
          size: Vector2(40, 56),
        );
      }
    }

    // 3. Render rising mist particles below waterfalls
    for (final m in _mistParticles) {
      canvas.drawCircle(
        Offset(m.x, m.y),
        m.radius,
        Paint()
          ..color = Colors.white.withValues(alpha: m.alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0),
      );
    }
  }

  void _renderRandomizedGrassTerrain(Canvas canvas) {
    final Vector2 tileSizeVec = Vector2(kTileSize + 1.0, kTileSize + 1.0);

    if (_grassTileSprites.isNotEmpty) {
      for (final tile in _grassTiles) {
        final int idx = int.tryParse(tile.tileType) ?? 0;
        final Sprite sprite = _grassTileSprites[idx % _grassTileSprites.length];
        sprite.render(
          canvas,
          position: Vector2(tile.x - kTileSize / 2, tile.y - kTileSize / 2),
          size: tileSizeVec,
        );
      }
    }
  }

  void _renderTileBasedRoads(Canvas canvas) {
    final Vector2 tileSizeVec = Vector2(kTileSize + 1.0, kTileSize + 1.0);

    // 1. Dirt border transition PNG tiles
    for (final tile in _roadTiles.where((t) => t.tileType == 'dirt')) {
      if (_dirtPathSprite != null) {
        _dirtPathSprite!.render(
          canvas,
          position: Vector2(tile.x - kTileSize / 2, tile.y - kTileSize / 2),
          size: tileSizeVec,
        );
      }
    }

    // 2. Straight road & corner PNG tiles
    for (final tile in _roadTiles.where((t) => t.tileType != 'dirt')) {
      Sprite? spriteToUse = _stonePathSprite;
      if (tile.tileType == 'cobble' && _cobblestoneSprite != null) {
        spriteToUse = _cobblestoneSprite;
      }

      if (spriteToUse != null) {
        spriteToUse.render(
          canvas,
          position: Vector2(tile.x - kTileSize / 2, tile.y - kTileSize / 2),
          size: tileSizeVec,
        );
      }
    }

    // 3. Central Plaza floor & outer ring PNG tiles
    for (final tile in _plazaTiles) {
      Sprite? plazaSprite = _stoneFloorPlatformSprite ?? _stonePathSprite;
      if (tile.tileType == 'trim' && _blueGoldTrimSprite != null) {
        plazaSprite = _blueGoldTrimSprite;
      } else if (tile.tileType == 'cobble' && _cobblestoneSprite != null) {
        plazaSprite = _cobblestoneSprite;
      }

      if (plazaSprite != null) {
        plazaSprite.render(
          canvas,
          position: Vector2(tile.x - kTileSize / 2, tile.y - kTileSize / 2),
          size: tileSizeVec,
        );
      }
    }
  }

  void _renderAnimatedFountain(Canvas canvas) {
    const Offset center = Offset(kPlazaCX, kPlazaCY);

    // Blue Glow Aura
    final double glowRadius = 80.0 + (math.sin(_waterAnimTime * 3.0) * 8.0);
    canvas.drawCircle(
      center,
      glowRadius,
      Paint()
        ..color = const Color(0xAA0288D1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0),
    );

    // Pulsing Water Ripples
    final double waveR1 = 28.0 + (math.sin(_waterAnimTime * 4.5) * 6.0);
    final double waveR2 = 46.0 + (math.cos(_waterAnimTime * 3.5) * 8.0);

    canvas.drawCircle(
      center,
      waveR2,
      Paint()
        ..color = const Color(0x6681D4FA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
    canvas.drawCircle(
      center,
      waveR1,
      Paint()
        ..color = const Color(0x8881D4FA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    if (_fountainSprite != null) {
      _fountainSprite!.render(
        canvas,
        position: Vector2(kPlazaCX - 75, kPlazaCY - 72),
        size: Vector2(150, 144),
      );
    }

    // South Entrance Gate Accent Prop
    if (_gateSprite != null) {
      _gateSprite!.render(
        canvas,
        position: Vector2(kPlazaCX - 48, 850.0),
        size: Vector2(96, 82),
      );
    }
  }
}
