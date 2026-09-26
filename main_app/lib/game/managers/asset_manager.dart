import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';

import '../../config/asset_paths.dart';

/// Centralized singleton AssetManager service for managing image caching,
/// building directional sprite animations from individual image frames,
/// fetching sprites, and loading Tiled (.tmx) maps using the game-assets pipeline.
class GameAssetManager {
  static final GameAssetManager _instance = GameAssetManager._internal();
  factory GameAssetManager() => _instance;
  GameAssetManager._internal() {
    images.prefix = '';
  }

  /// Reference to Flame's global image cache.
  final Images images = Flame.images;

  /// Preloads all configured game images into Flame cache safely using game-assets paths.
  Future<void> preloadAssets() async {
    images.prefix = '';
    for (final path in AssetPaths.preloadImages) {
      try {
        await rootBundle.load(path);
        await images.load(path);
      } catch (_) {
        // Soft fallback if optional asset variant is absent
      }
    }
  }

  /// Builds a [SpriteAnimation] from a list of individual frame image asset paths.
  SpriteAnimation? buildSequenceAnimation({
    required List<String> framePaths,
    required double stepTime,
    bool loop = true,
  }) {
    final sprites = <Sprite>[];

    for (final path in framePaths) {
      if (images.containsKey(path)) {
        try {
          final image = images.fromCache(path);
          sprites.add(Sprite(image));
        } catch (_) {}
      }
    }

    if (sprites.isEmpty) return null;
    return SpriteAnimation.spriteList(sprites, stepTime: stepTime, loop: loop);
  }

  /// Fetches a single [Sprite] from cached or dynamically loaded image path.
  Sprite? getSprite(String imagePath) {
    if (images.containsKey(imagePath)) {
      try {
        final image = images.fromCache(imagePath);
        return Sprite(image);
      } catch (_) {}
    }

    // Try dynamic sync load if in cache or fallback to null
    try {
      images.load(imagePath);
      if (images.containsKey(imagePath)) {
        return Sprite(images.fromCache(imagePath));
      }
    } catch (_) {}

    return null;
  }

  /// Loads a Tiled (.tmx) map component asynchronously from game-assets pipeline.
  Future<TiledComponent?> loadTiledMap(
    String filename, {
    Vector2? destTileSize,
  }) async {
    try {
      await rootBundle.load('game-assets/maps/$filename');
      return await TiledComponent.load(
        filename,
        destTileSize ?? Vector2.all(32.0),
        prefix: 'game-assets/maps/',
      );
    } catch (_) {
      return null;
    }
  }
}
