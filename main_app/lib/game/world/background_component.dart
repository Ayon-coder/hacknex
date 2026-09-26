import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/asset_paths.dart';
import '../../config/game_constants.dart';
import '../managers/asset_manager.dart';

/// Reusable terrain background component rendering tiled grass, cobblestone paths,
/// and plazas using production terrain tile assets.
class BackgroundComponent extends PositionComponent {
  Sprite? _grassTile;
  Sprite? _grassTileAlt;
  Sprite? _pathTile;
  Sprite? _stoneTile;

  BackgroundComponent()
      : super(
          size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
          position: Vector2.zero(),
          priority: -10,
        );

  final Paint _bgPaint = Paint()..color = GameConstants.gridBgColor;
  final Paint _gridPaint = Paint()
    ..color = GameConstants.gridLineColor.withValues(alpha: 0.3)
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final assetManager = GameAssetManager();
    _grassTile = assetManager.getSprite(AssetPaths.tileGrass0);
    _grassTileAlt = assetManager.getSprite(AssetPaths.tileGrass1);
    _pathTile = assetManager.getSprite(AssetPaths.tilePath0);
    _stoneTile = assetManager.getSprite(AssetPaths.tileStone0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Fallback background color fill
    canvas.drawRect(size.toRect(), _bgPaint);

    final double tileSize = GameConstants.gridCellSize;
    final int cols = (size.x / tileSize).ceil();
    final int rows = (size.y / tileSize).ceil();

    if (_grassTile != null) {
      // Tile terrain across map
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final Vector2 pos = Vector2(c * tileSize, r * tileSize);
          final Vector2 tSize = Vector2.all(tileSize);

          // Render path tiles connecting central building areas
          if (_isPathTile(c, r)) {
            (_pathTile ?? _grassTile)!.render(canvas, position: pos, size: tSize);
          } else if (_isPlazaTile(c, r)) {
            (_stoneTile ?? _grassTile)!.render(canvas, position: pos, size: tSize);
          } else {
            // Alternate grass tiles for natural terrain texture variation
            final sprite = ((c + r) % 5 == 0 && _grassTileAlt != null)
                ? _grassTileAlt!
                : _grassTile!;
            sprite.render(canvas, position: pos, size: tSize);
          }
        }
      }
    }

    // Overlay subtle grid lines
    for (double x = 0; x <= size.x; x += tileSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _gridPaint);
    }
    for (double y = 0; y <= size.y; y += tileSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _gridPaint);
    }
  }

  /// Determines if (c, r) coordinate is part of connecting pathways.
  bool _isPathTile(int c, int r) {
    if ((r == 6 || r == 17) && (c >= 5 && c <= 27)) return true;
    if ((c == 15 || c == 16) && (r >= 5 && r <= 18)) return true;
    return false;
  }

  /// Determines if (c, r) coordinate is a building plaza courtyard.
  bool _isPlazaTile(int c, int r) {
    if ((c >= 5 && c <= 7 && r >= 5 && r <= 7) ||
        (c >= 23 && c <= 25 && r >= 5 && r <= 7) ||
        (c >= 14 && c <= 17 && r >= 10 && r <= 12) ||
        (c >= 5 && c <= 7 && r >= 16 && r <= 18) ||
        (c >= 23 && c <= 25 && r >= 16 && r <= 18)) {
      return true;
    }
    return false;
  }
}
