import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/asset_paths.dart';
import '../../../config/game_constants.dart';
import '../../managers/asset_manager.dart';

/// Modular terrain component rendering default grass tiles, connecting stone/dirt roads,
/// and building plaza courtyards across the map.
class TerrainComponent extends PositionComponent {
  Sprite? _grassTile0;
  Sprite? _grassTile1;
  Sprite? _grassTile2;
  Sprite? _pathTile;
  Sprite? _stoneTile;

  TerrainComponent()
      : super(
          size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
          position: Vector2.zero(),
          priority: -100,
        );

  final Paint _bgPaint = Paint()..color = GameConstants.gridBgColor;
  final Paint _gridPaint = Paint()
    ..color = GameConstants.gridLineColor.withValues(alpha: 0.25)
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final assetManager = GameAssetManager();
    _grassTile0 = assetManager.getSprite(AssetPaths.tileGrass0);
    _grassTile1 = assetManager.getSprite(AssetPaths.tileGrass1);
    _grassTile2 = assetManager.getSprite(AssetPaths.tileGrass2);
    _pathTile = assetManager.getSprite(AssetPaths.tilePath0);
    _stoneTile = assetManager.getSprite(AssetPaths.tileStone0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Fallback background fill
    canvas.drawRect(size.toRect(), _bgPaint);

    final double tileSize = GameConstants.gridCellSize;
    final int cols = (size.x / tileSize).ceil();
    final int rows = (size.y / tileSize).ceil();

    if (_grassTile0 != null) {
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final Vector2 pos = Vector2(c * tileSize, r * tileSize);
          final Vector2 tSize = Vector2.all(tileSize);

          if (_isRoadTile(c, r)) {
            // Render connecting road path
            (_pathTile ?? _grassTile0)!.render(canvas, position: pos, size: tSize);
          } else if (_isPlazaTile(c, r)) {
            // Render building courtyard plaza
            (_stoneTile ?? _grassTile0)!.render(canvas, position: pos, size: tSize);
          } else {
            // Render default grass terrain with subtle variation
            Sprite grassSprite = _grassTile0!;
            if ((c * 3 + r * 7) % 11 == 0 && _grassTile1 != null) {
              grassSprite = _grassTile1!;
            } else if ((c * 5 + r * 2) % 13 == 0 && _grassTile2 != null) {
              grassSprite = _grassTile2!;
            }
            grassSprite.render(canvas, position: pos, size: tSize);
          }
        }
      }
    }

    // Overlay light grid guidelines
    for (double x = 0; x <= size.x; x += tileSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _gridPaint);
    }
    for (double y = 0; y <= size.y; y += tileSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _gridPaint);
    }
  }

  /// Evaluates if coordinate is part of the interconnected road network between buildings.
  bool _isRoadTile(int c, int r) {
    // Horizontal main roads connecting East and West campus wings
    if ((r == 7 || r == 16) && (c >= 6 && c <= 26)) return true;
    // Vertical main roads connecting North and South campus wings
    if ((c == 8 || c == 16 || c == 24) && (r >= 5 && r <= 18)) return true;
    return false;
  }

  /// Evaluates if coordinate is a building plaza courtyard.
  bool _isPlazaTile(int c, int r) {
    if ((c >= 7 && c <= 9 && r >= 6 && r <= 8) ||
        (c >= 23 && c <= 25 && r >= 6 && r <= 8) ||
        (c >= 15 && c <= 17 && r >= 10 && r <= 12) ||
        (c >= 7 && c <= 9 && r >= 15 && r <= 17) ||
        (c >= 23 && c <= 25 && r >= 15 && r <= 17)) {
      return true;
    }
    return false;
  }
}
