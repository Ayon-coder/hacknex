import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../../config/asset_paths.dart';
import '../managers/asset_manager.dart';

/// Reusable helper class for loading and initializing Tiled (.tmx) map files
/// and extracting map layers and object spawners.
class TiledMapLoader {
  /// Loads a Tiled map component asynchronously.
  static Future<TiledComponent?> loadMap({
    String mapPath = AssetPaths.defaultMapTmx,
    Vector2? destTileSize,
  }) async {
    final assetManager = GameAssetManager();
    return await assetManager.loadTiledMap(
      mapPath,
      destTileSize: destTileSize,
    );
  }
}
