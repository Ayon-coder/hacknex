import 'game_assets.dart';

/// Centralized single source of truth defining file paths for all game assets strictly using game-assets/ pipeline.
abstract final class AssetPaths {
  // --- Background Map Asset ---
  static const String mapBackground = ReferenceAssets.arcanistIslandFullReference;
  static const String skyCloudBackground = ReferenceAssets.skyCloudBackground;

  // --- Player Character Animations ---
  static List<String> playerIdleFrames() => [
        PlayerAssets.idleArcanistIdleFront01,
        PlayerAssets.idleArcanistIdleFront02,
        PlayerAssets.idleArcanistIdleFront03,
      ];

  static List<String> playerWalkFrames() => [
        PlayerAssets.walkArcanistWalkLeft01,
        PlayerAssets.walkArcanistWalkLeft02,
        PlayerAssets.walkArcanistWalkRight01,
        PlayerAssets.walkArcanistWalkRight02,
        PlayerAssets.walkArcanistWalkBack,
      ];

  // Directional helper aliases
  static List<String> wizardIdleFrames(String dir) => playerIdleFrames();
  static List<String> wizardWalkFrames(String dir) => playerWalkFrames();

  // --- Player Character Sprites ---
  static const String playerArcanist = PlayerAssets.idleArcanistIdleFront01;
  static const String playerArcanistPortrait = PlayerAssets.idleArcanistIdleFront01;

  // --- Building Sprite Assets ---
  static const String buildingGrandHall = BuildingAssets.grandHall;
  static const String buildingAstronomyTower = BuildingAssets.astronomyTower;
  static const String buildingLibrary = BuildingAssets.library;
  static const String buildingAlchemyLab = BuildingAssets.alchemyLab;
  static const String buildingDuelArena = BuildingAssets.duelArena;
  static const String buildingHistoryHall = BuildingAssets.historyHall;
  static const String buildingCodingTower = BuildingAssets.codingTower;
  static const String buildingQuestCenter = BuildingAssets.grandHall;

  // --- Landmark & Prop Assets ---
  static const String landmarkCentralPlaza = DecorationAssets.propsCentralFountain;
  static const String landmarkEnchantedForest = NatureAssets.treesEnchantedForestTree;
  static const String envEntranceGate = DecorationAssets.fencesWoodenGate;
  static const String envPathSegment = TileAssets.roadsStonePathTile;

  // --- Terrain Tile Assets ---
  static const String tileGrass0 = TileAssets.grassTile;
  static const String tileGrass1 = TileAssets.cloverGrassTile;
  static const String tileGrass2 = TileAssets.grassLeafyGroundTile;
  static const String tileGrass3 = TileAssets.grassGoldFleckedBlueTile;
  static const String tilePath0 = TileAssets.roadsStonePathTile;
  static const String tilePath1 = TileAssets.roadsCobblestoneTile;
  static const String tilePath2 = TileAssets.roadsDirtPathTile;
  static const String tileStone0 = TileAssets.roadsCobblestoneTile;
  static const String tileWater0 = TileAssets.blueMagicWaterTile;

  // --- Decoration Sprite Assets ---
  static const String decTreeOak = NatureAssets.treesRoundTree;
  static const String decTreePine = NatureAssets.treesTallPineTree;
  static const String decTreeMagic = NatureAssets.treesEnchantedForestTree;
  static const String decRock = NatureAssets.rocksRockCluster;
  static const String decBush = NatureAssets.bushesLeafyBush;
  static const String decFlowers = NatureAssets.flowersYellowFlowerBed;

  // --- Maps ---
  static const String defaultMapTmx = 'world_map.tmx';

  /// Complete list of images to pre-cache.
  static List<String> get preloadImages {
    final list = <String>[
      mapBackground,
      skyCloudBackground,
      playerArcanist,
      playerArcanistPortrait,
      buildingGrandHall,
      buildingAstronomyTower,
      buildingLibrary,
      buildingAlchemyLab,
      buildingDuelArena,
      buildingHistoryHall,
      buildingCodingTower,
      buildingQuestCenter,
      landmarkCentralPlaza,
      landmarkEnchantedForest,
      envEntranceGate,
      decTreeOak,
      decTreePine,
      decTreeMagic,
      decRock,
      decBush,
      decFlowers,
      tileGrass0,
      tileGrass1,
      tileGrass2,
      tileGrass3,
      tilePath0,
      tilePath1,
      tilePath2,
      tileStone0,
    ];

    list.addAll(playerIdleFrames());
    list.addAll(playerWalkFrames());

    return list;
  }
}
