// Generated asset path constants for the Hexafalls game asset library.
// Do not hardcode asset path strings elsewhere; reference these constants instead.

abstract final class AssetManager {
  static const all = <String>[
    ...BuildingAssets.all,
    ...NatureAssets.all,
    ...TileAssets.all,
    ...PlayerAssets.all,
    ...EffectAssets.all,
    ...UiAssets.all,
    ...NpcAssets.all,
    ...DecorationAssets.all,
    ...ReferenceAssets.all,
    ...RankAssets.all,
  ];
}

/// Progression emblems supplied with the game art pack.
abstract final class RankAssets {
  static const bronze = 'game-assets/rank/bronze.jpeg';
  static const silver = 'game-assets/rank/silver.jpeg';
  // The supplied Master crest is used for the Gold tier.
  static const gold = 'game-assets/rank/master.jpeg';
  static const platinum = 'game-assets/rank/platinum.jpeg';
  static const diamond = 'game-assets/rank/diamond.jpeg';

  static const all = <String>[bronze, silver, gold, platinum, diamond];
}

abstract final class BuildingAssets {
  static const alchemyLab = 'game-assets/buildings/alchemy_lab.png';
  static const alchemyLabTwoX = 'game-assets/buildings/alchemy_lab_2x.png';
  static const astronomyTower = 'game-assets/buildings/astronomy_tower.png';
  static const astronomyTowerTwoX =
      'game-assets/buildings/astronomy_tower_2x.png';
  static const codingTower = 'game-assets/buildings/coding_tower.png';
  static const codingTowerTwoX = 'game-assets/buildings/coding_tower_2x.png';
  static const duelArena = 'game-assets/buildings/duel_arena.png';
  static const duelArenaTwoX = 'game-assets/buildings/duel_arena_2x.png';
  static const grandHall = 'game-assets/buildings/grand_hall.png';
  static const grandHallTwoX = 'game-assets/buildings/grand_hall_2x.png';
  static const historyHall = 'game-assets/buildings/history_hall.png';
  static const historyHallTwoX = 'game-assets/buildings/history_hall_2x.png';
  static const library = 'game-assets/buildings/library.png';
  static const libraryTwoX = 'game-assets/buildings/library_2x.png';

  static const all = <String>[
    alchemyLab,
    alchemyLabTwoX,
    astronomyTower,
    astronomyTowerTwoX,
    codingTower,
    codingTowerTwoX,
    duelArena,
    duelArenaTwoX,
    grandHall,
    grandHallTwoX,
    historyHall,
    historyHallTwoX,
    library,
    libraryTwoX,
  ];
}

abstract final class NatureAssets {
  static const bushesGrayRockBush =
      'game-assets/nature/bushes/gray_rock_bush.png';
  static const bushesGrayRockBushTwoX =
      'game-assets/nature/bushes/gray_rock_bush_2x.png';
  static const bushesLeafyBush = 'game-assets/nature/bushes/leafy_bush.png';
  static const bushesLeafyBushTwoX =
      'game-assets/nature/bushes/leafy_bush_2x.png';
  static const bushesPinkFlowerBush =
      'game-assets/nature/bushes/pink_flower_bush.png';
  static const bushesPinkFlowerBushTwoX =
      'game-assets/nature/bushes/pink_flower_bush_2x.png';
  static const bushesSmallLeafyPatch =
      'game-assets/nature/bushes/small_leafy_patch.png';
  static const bushesSmallLeafyPatchTwoX =
      'game-assets/nature/bushes/small_leafy_patch_2x.png';
  static const bushesYellowFlowerBush =
      'game-assets/nature/bushes/yellow_flower_bush.png';
  static const bushesYellowFlowerBushTwoX =
      'game-assets/nature/bushes/yellow_flower_bush_2x.png';
  static const flowersFlowerCliffColumn =
      'game-assets/nature/flowers/flower_cliff_column.png';
  static const flowersFlowerCliffColumnTwoX =
      'game-assets/nature/flowers/flower_cliff_column_2x.png';
  static const flowersFlowerGrassMound =
      'game-assets/nature/flowers/flower_grass_mound.png';
  static const flowersFlowerGrassMoundTwoX =
      'game-assets/nature/flowers/flower_grass_mound_2x.png';
  static const flowersPinkFlowerGrassTile =
      'game-assets/nature/flowers/pink_flower_grass_tile.png';
  static const flowersPinkFlowerGrassTileTwoX =
      'game-assets/nature/flowers/pink_flower_grass_tile_2x.png';
  static const flowersPinkFlowerPatch =
      'game-assets/nature/flowers/pink_flower_patch.png';
  static const flowersPinkFlowerPatchTwoX =
      'game-assets/nature/flowers/pink_flower_patch_2x.png';
  static const flowersPurpleFlowerGrassTile =
      'game-assets/nature/flowers/purple_flower_grass_tile.png';
  static const flowersPurpleFlowerGrassTileTwoX =
      'game-assets/nature/flowers/purple_flower_grass_tile_2x.png';
  static const flowersPurpleFlowerPatch =
      'game-assets/nature/flowers/purple_flower_patch.png';
  static const flowersPurpleFlowerPatchTwoX =
      'game-assets/nature/flowers/purple_flower_patch_2x.png';
  static const flowersTinyFlowerCluster =
      'game-assets/nature/flowers/tiny_flower_cluster.png';
  static const flowersTinyFlowerClusterTwoX =
      'game-assets/nature/flowers/tiny_flower_cluster_2x.png';
  static const flowersTinyGroundSprout =
      'game-assets/nature/flowers/tiny_ground_sprout.png';
  static const flowersTinyGroundSproutTwoX =
      'game-assets/nature/flowers/tiny_ground_sprout_2x.png';
  static const flowersWhiteFlowerGrassTile =
      'game-assets/nature/flowers/white_flower_grass_tile.png';
  static const flowersWhiteFlowerGrassTileTwoX =
      'game-assets/nature/flowers/white_flower_grass_tile_2x.png';
  static const flowersYellowFlowerBed =
      'game-assets/nature/flowers/yellow_flower_bed.png';
  static const flowersYellowFlowerBedTwoX =
      'game-assets/nature/flowers/yellow_flower_bed_2x.png';
  static const flowersYellowFlowerPatch =
      'game-assets/nature/flowers/yellow_flower_patch.png';
  static const flowersYellowFlowerPatchTwoX =
      'game-assets/nature/flowers/yellow_flower_patch_2x.png';
  static const flowersYellowFlowerShrub =
      'game-assets/nature/flowers/yellow_flower_shrub.png';
  static const flowersYellowFlowerShrubTwoX =
      'game-assets/nature/flowers/yellow_flower_shrub_2x.png';
  static const rocksRockCluster = 'game-assets/nature/rocks/rock_cluster.png';
  static const rocksRockClusterTwoX =
      'game-assets/nature/rocks/rock_cluster_2x.png';
  static const rocksSmallRockPile =
      'game-assets/nature/rocks/small_rock_pile.png';
  static const rocksSmallRockPileTwoX =
      'game-assets/nature/rocks/small_rock_pile_2x.png';
  static const treesAutumnTree = 'game-assets/nature/trees/autumn_tree.png';
  static const treesAutumnTreeTwoX =
      'game-assets/nature/trees/autumn_tree_2x.png';
  static const treesBroadleafTree =
      'game-assets/nature/trees/broadleaf_tree.png';
  static const treesBroadleafTreeTwoX =
      'game-assets/nature/trees/broadleaf_tree_2x.png';
  static const treesEnchantedForestTree =
      'game-assets/nature/trees/enchanted_forest_tree.png';
  static const treesEnchantedForestTreeTwoX =
      'game-assets/nature/trees/enchanted_forest_tree_2x.png';
  static const treesFirewoodStack =
      'game-assets/nature/trees/firewood_stack.png';
  static const treesFirewoodStackTwoX =
      'game-assets/nature/trees/firewood_stack_2x.png';
  static const treesLogPile = 'game-assets/nature/trees/log_pile.png';
  static const treesLogPileTwoX = 'game-assets/nature/trees/log_pile_2x.png';
  static const treesMediumPineTree =
      'game-assets/nature/trees/medium_pine_tree.png';
  static const treesMediumPineTreeTwoX =
      'game-assets/nature/trees/medium_pine_tree_2x.png';
  static const treesRoundLeafTree =
      'game-assets/nature/trees/round_leaf_tree.png';
  static const treesRoundLeafTreeTwoX =
      'game-assets/nature/trees/round_leaf_tree_2x.png';
  static const treesRoundTree = 'game-assets/nature/trees/round_tree.png';
  static const treesRoundTreeTwoX =
      'game-assets/nature/trees/round_tree_2x.png';
  static const treesSmallBroadleafTree =
      'game-assets/nature/trees/small_broadleaf_tree.png';
  static const treesSmallBroadleafTreeTwoX =
      'game-assets/nature/trees/small_broadleaf_tree_2x.png';
  static const treesSmallPineTree =
      'game-assets/nature/trees/small_pine_tree.png';
  static const treesSmallPineTreeTwoX =
      'game-assets/nature/trees/small_pine_tree_2x.png';
  static const treesSmallPineTreeTwoXTiles =
      'game-assets/nature/trees/small_pine_tree_2x_tiles.png';
  static const treesSmallPineTreeTiles =
      'game-assets/nature/trees/small_pine_tree_tiles.png';
  static const treesSmallSapling = 'game-assets/nature/trees/small_sapling.png';
  static const treesSmallSaplingTwoX =
      'game-assets/nature/trees/small_sapling_2x.png';
  static const treesSmallTreeStump =
      'game-assets/nature/trees/small_tree_stump.png';
  static const treesSmallTreeStumpTwoX =
      'game-assets/nature/trees/small_tree_stump_2x.png';
  static const treesTallPineTree =
      'game-assets/nature/trees/tall_pine_tree.png';
  static const treesTallPineTreeTwoX =
      'game-assets/nature/trees/tall_pine_tree_2x.png';
  static const treesTreeStump = 'game-assets/nature/trees/tree_stump.png';
  static const treesTreeStumpTwoX =
      'game-assets/nature/trees/tree_stump_2x.png';

  static const all = <String>[
    bushesGrayRockBush,
    bushesGrayRockBushTwoX,
    bushesLeafyBush,
    bushesLeafyBushTwoX,
    bushesPinkFlowerBush,
    bushesPinkFlowerBushTwoX,
    bushesSmallLeafyPatch,
    bushesSmallLeafyPatchTwoX,
    bushesYellowFlowerBush,
    bushesYellowFlowerBushTwoX,
    flowersFlowerCliffColumn,
    flowersFlowerCliffColumnTwoX,
    flowersFlowerGrassMound,
    flowersFlowerGrassMoundTwoX,
    flowersPinkFlowerGrassTile,
    flowersPinkFlowerGrassTileTwoX,
    flowersPinkFlowerPatch,
    flowersPinkFlowerPatchTwoX,
    flowersPurpleFlowerGrassTile,
    flowersPurpleFlowerGrassTileTwoX,
    flowersPurpleFlowerPatch,
    flowersPurpleFlowerPatchTwoX,
    flowersTinyFlowerCluster,
    flowersTinyFlowerClusterTwoX,
    flowersTinyGroundSprout,
    flowersTinyGroundSproutTwoX,
    flowersWhiteFlowerGrassTile,
    flowersWhiteFlowerGrassTileTwoX,
    flowersYellowFlowerBed,
    flowersYellowFlowerBedTwoX,
    flowersYellowFlowerPatch,
    flowersYellowFlowerPatchTwoX,
    flowersYellowFlowerShrub,
    flowersYellowFlowerShrubTwoX,
    rocksRockCluster,
    rocksRockClusterTwoX,
    rocksSmallRockPile,
    rocksSmallRockPileTwoX,
    treesAutumnTree,
    treesAutumnTreeTwoX,
    treesBroadleafTree,
    treesBroadleafTreeTwoX,
    treesEnchantedForestTree,
    treesEnchantedForestTreeTwoX,
    treesFirewoodStack,
    treesFirewoodStackTwoX,
    treesLogPile,
    treesLogPileTwoX,
    treesMediumPineTree,
    treesMediumPineTreeTwoX,
    treesRoundLeafTree,
    treesRoundLeafTreeTwoX,
    treesRoundTree,
    treesRoundTreeTwoX,
    treesSmallBroadleafTree,
    treesSmallBroadleafTreeTwoX,
    treesSmallPineTree,
    treesSmallPineTreeTwoX,
    treesSmallPineTreeTwoXTiles,
    treesSmallPineTreeTiles,
    treesSmallSapling,
    treesSmallSaplingTwoX,
    treesSmallTreeStump,
    treesSmallTreeStumpTwoX,
    treesTallPineTree,
    treesTallPineTreeTwoX,
    treesTreeStump,
    treesTreeStumpTwoX,
  ];
}

abstract final class TileAssets {
  static const cliffsGrassCliffColumn =
      'game-assets/tiles/cliffs/grass_cliff_column.png';
  static const cliffsGrassCliffColumnTwoX =
      'game-assets/tiles/cliffs/grass_cliff_column_2x.png';
  static const cliffsLeafyCliffColumn =
      'game-assets/tiles/cliffs/leafy_cliff_column.png';
  static const cliffsLeafyCliffColumnTwoX =
      'game-assets/tiles/cliffs/leafy_cliff_column_2x.png';
  static const cliffsTallGrassCliffChunk =
      'game-assets/tiles/cliffs/tall_grass_cliff_chunk.png';
  static const cliffsTallGrassCliffChunkTwoX =
      'game-assets/tiles/cliffs/tall_grass_cliff_chunk_2x.png';
  static const grassBlueGoldTrimTile =
      'game-assets/tiles/grass/blue_gold_trim_tile.png';
  static const grassBlueGoldTrimTileTwoX =
      'game-assets/tiles/grass/blue_gold_trim_tile_2x.png';
  static const cloverGrassTile =
      'game-assets/tiles/grass/clover_grass_tile.png';
  static const cloverGrassTileTwoX =
      'game-assets/tiles/grass/clover_grass_tile_2x.png';
  static const grassGoldFleckedBlueTile =
      'game-assets/tiles/grass/gold_flecked_blue_tile.png';
  static const grassGoldFleckedBlueTileTwoX =
      'game-assets/tiles/grass/gold_flecked_blue_tile_2x.png';
  static const grassMound = 'game-assets/tiles/grass/grass_mound.png';
  static const grassMoundTwoX = 'game-assets/tiles/grass/grass_mound_2x.png';
  static const grassTile = 'game-assets/tiles/grass/grass_tile.png';
  static const grassTileTwoX = 'game-assets/tiles/grass/grass_tile_2x.png';
  static const grassWithStonesTile =
      'game-assets/tiles/grass/grass_with_stones_tile.png';
  static const grassWithStonesTileTwoX =
      'game-assets/tiles/grass/grass_with_stones_tile_2x.png';
  static const grassLeafyGroundTile =
      'game-assets/tiles/grass/leafy_ground_tile.png';
  static const grassLeafyGroundTileTwoX =
      'game-assets/tiles/grass/leafy_ground_tile_2x.png';
  static const grassPurpleCrystalGroundTile =
      'game-assets/tiles/grass/purple_crystal_ground_tile.png';
  static const grassPurpleCrystalGroundTileTwoX =
      'game-assets/tiles/grass/purple_crystal_ground_tile_2x.png';
  static const grassPurpleCrystalOreTile =
      'game-assets/tiles/grass/purple_crystal_ore_tile.png';
  static const grassPurpleCrystalOreTileTwoX =
      'game-assets/tiles/grass/purple_crystal_ore_tile_2x.png';
  static const roadsCobblestoneTile =
      'game-assets/tiles/roads/cobblestone_tile.png';
  static const roadsCobblestoneTileTwoX =
      'game-assets/tiles/roads/cobblestone_tile_2x.png';
  static const roadsDarkWoodPlankTile =
      'game-assets/tiles/roads/dark_wood_plank_tile.png';
  static const roadsDarkWoodPlankTileTwoX =
      'game-assets/tiles/roads/dark_wood_plank_tile_2x.png';
  static const roadsDirtPathTile = 'game-assets/tiles/roads/dirt_path_tile.png';
  static const roadsDirtPathTileTwoX =
      'game-assets/tiles/roads/dirt_path_tile_2x.png';
  static const roadsStonePathTile =
      'game-assets/tiles/roads/stone_path_tile.png';
  static const roadsStonePathTileTwoX =
      'game-assets/tiles/roads/stone_path_tile_2x.png';
  static const roadsWoodPlankTile =
      'game-assets/tiles/roads/wood_plank_tile.png';
  static const roadsWoodPlankTileTwoX =
      'game-assets/tiles/roads/wood_plank_tile_2x.png';
  static const blueMagicWaterTile =
      'game-assets/tiles/water/blue_magic_water_tile.png';
  static const blueMagicWaterTileTwoX =
      'game-assets/tiles/water/blue_magic_water_tile_2x.png';
  static const waterBluePondTile = 'game-assets/tiles/water/blue_pond_tile.png';
  static const waterBluePondTileTwoX =
      'game-assets/tiles/water/blue_pond_tile_2x.png';
  static const waterGrassCliffWaterfallEdge =
      'game-assets/tiles/water/grass_cliff_waterfall_edge.png';
  static const waterGrassCliffWaterfallEdgeTwoX =
      'game-assets/tiles/water/grass_cliff_waterfall_edge_2x.png';
  static const waterNarrowWaterfallSegment =
      'game-assets/tiles/water/narrow_waterfall_segment.png';
  static const waterNarrowWaterfallSegmentTwoX =
      'game-assets/tiles/water/narrow_waterfall_segment_2x.png';
  static const waterWideWaterfallSegment =
      'game-assets/tiles/water/wide_waterfall_segment.png';
  static const waterWideWaterfallSegmentTwoX =
      'game-assets/tiles/water/wide_waterfall_segment_2x.png';

  static const all = <String>[
    cliffsGrassCliffColumn,
    cliffsGrassCliffColumnTwoX,
    cliffsLeafyCliffColumn,
    cliffsLeafyCliffColumnTwoX,
    cliffsTallGrassCliffChunk,
    cliffsTallGrassCliffChunkTwoX,
    grassBlueGoldTrimTile,
    grassBlueGoldTrimTileTwoX,
    cloverGrassTile,
    cloverGrassTileTwoX,
    grassGoldFleckedBlueTile,
    grassGoldFleckedBlueTileTwoX,
    grassMound,
    grassMoundTwoX,
    grassTile,
    grassTileTwoX,
    grassWithStonesTile,
    grassWithStonesTileTwoX,
    grassLeafyGroundTile,
    grassLeafyGroundTileTwoX,
    grassPurpleCrystalGroundTile,
    grassPurpleCrystalGroundTileTwoX,
    grassPurpleCrystalOreTile,
    grassPurpleCrystalOreTileTwoX,
    roadsCobblestoneTile,
    roadsCobblestoneTileTwoX,
    roadsDarkWoodPlankTile,
    roadsDarkWoodPlankTileTwoX,
    roadsDirtPathTile,
    roadsDirtPathTileTwoX,
    roadsStonePathTile,
    roadsStonePathTileTwoX,
    roadsWoodPlankTile,
    roadsWoodPlankTileTwoX,
    blueMagicWaterTile,
    blueMagicWaterTileTwoX,
    waterBluePondTile,
    waterBluePondTileTwoX,
    waterGrassCliffWaterfallEdge,
    waterGrassCliffWaterfallEdgeTwoX,
    waterNarrowWaterfallSegment,
    waterNarrowWaterfallSegmentTwoX,
    waterWideWaterfallSegment,
    waterWideWaterfallSegmentTwoX,
  ];
}

abstract final class PlayerAssets {
  static const castArcanistCastFrontRelease =
      'game-assets/player/cast/arcanist_cast_front_release.png';
  static const castArcanistCastFrontReleaseTwoX =
      'game-assets/player/cast/arcanist_cast_front_release_2x.png';
  static const castArcanistCastFrontStart =
      'game-assets/player/cast/arcanist_cast_front_start.png';
  static const castArcanistCastFrontStartTwoX =
      'game-assets/player/cast/arcanist_cast_front_start_2x.png';
  static const castArcanistCastSideCharge =
      'game-assets/player/cast/arcanist_cast_side_charge.png';
  static const castArcanistCastSideChargeTwoX =
      'game-assets/player/cast/arcanist_cast_side_charge_2x.png';
  static const castArcanistCastSideProjectile =
      'game-assets/player/cast/arcanist_cast_side_projectile.png';
  static const castArcanistCastSideProjectileTwoX =
      'game-assets/player/cast/arcanist_cast_side_projectile_2x.png';
  static const castArcanistCastSideStep =
      'game-assets/player/cast/arcanist_cast_side_step.png';
  static const castArcanistCastSideStepTwoX =
      'game-assets/player/cast/arcanist_cast_side_step_2x.png';
  static const idleArcanistIdleBack01 =
      'game-assets/player/idle/arcanist_idle_back_01.png';
  static const idleArcanistIdleBack01TwoX =
      'game-assets/player/idle/arcanist_idle_back_01_2x.png';
  static const idleArcanistIdleBack02 =
      'game-assets/player/idle/arcanist_idle_back_02.png';
  static const idleArcanistIdleBack02TwoX =
      'game-assets/player/idle/arcanist_idle_back_02_2x.png';
  static const idleArcanistIdleFront01 =
      'game-assets/player/idle/arcanist_idle_front_01.png';
  static const idleArcanistIdleFront01TwoX =
      'game-assets/player/idle/arcanist_idle_front_01_2x.png';
  static const idleArcanistIdleFront02 =
      'game-assets/player/idle/arcanist_idle_front_02.png';
  static const idleArcanistIdleFront02TwoX =
      'game-assets/player/idle/arcanist_idle_front_02_2x.png';
  static const idleArcanistIdleFront03 =
      'game-assets/player/idle/arcanist_idle_front_03.png';
  static const idleArcanistIdleFront03TwoX =
      'game-assets/player/idle/arcanist_idle_front_03_2x.png';
  static const walkArcanistWalkBack =
      'game-assets/player/walk/arcanist_walk_back.png';
  static const walkArcanistWalkBackTwoX =
      'game-assets/player/walk/arcanist_walk_back_2x.png';
  static const walkArcanistWalkLeft01 =
      'game-assets/player/walk/arcanist_walk_left_01.png';
  static const walkArcanistWalkLeft01TwoX =
      'game-assets/player/walk/arcanist_walk_left_01_2x.png';
  static const walkArcanistWalkLeft02 =
      'game-assets/player/walk/arcanist_walk_left_02.png';
  static const walkArcanistWalkLeft02TwoX =
      'game-assets/player/walk/arcanist_walk_left_02_2x.png';
  static const walkArcanistWalkRight01 =
      'game-assets/player/walk/arcanist_walk_right_01.png';
  static const walkArcanistWalkRight01TwoX =
      'game-assets/player/walk/arcanist_walk_right_01_2x.png';
  static const walkArcanistWalkRight02 =
      'game-assets/player/walk/arcanist_walk_right_02.png';
  static const walkArcanistWalkRight02TwoX =
      'game-assets/player/walk/arcanist_walk_right_02_2x.png';

  static const all = <String>[
    castArcanistCastFrontRelease,
    castArcanistCastFrontReleaseTwoX,
    castArcanistCastFrontStart,
    castArcanistCastFrontStartTwoX,
    castArcanistCastSideCharge,
    castArcanistCastSideChargeTwoX,
    castArcanistCastSideProjectile,
    castArcanistCastSideProjectileTwoX,
    castArcanistCastSideStep,
    castArcanistCastSideStepTwoX,
    idleArcanistIdleBack01,
    idleArcanistIdleBack01TwoX,
    idleArcanistIdleBack02,
    idleArcanistIdleBack02TwoX,
    idleArcanistIdleFront01,
    idleArcanistIdleFront01TwoX,
    idleArcanistIdleFront02,
    idleArcanistIdleFront02TwoX,
    idleArcanistIdleFront03,
    idleArcanistIdleFront03TwoX,
    walkArcanistWalkBack,
    walkArcanistWalkBackTwoX,
    walkArcanistWalkLeft01,
    walkArcanistWalkLeft01TwoX,
    walkArcanistWalkLeft02,
    walkArcanistWalkLeft02TwoX,
    walkArcanistWalkRight01,
    walkArcanistWalkRight01TwoX,
    walkArcanistWalkRight02,
    walkArcanistWalkRight02TwoX,
  ];
}

abstract final class EffectAssets {
  static const magicBlueIceSpike =
      'game-assets/effects/magic/blue_ice_spike.png';
  static const magicBlueIceSpikeTwoX =
      'game-assets/effects/magic/blue_ice_spike_2x.png';
  static const blueMagicFloorDecal =
      'game-assets/effects/magic/blue_magic_floor_decal.png';
  static const blueMagicFloorDecalTwoX =
      'game-assets/effects/magic/blue_magic_floor_decal_2x.png';
  static const blueMagicFloorDecalVariant =
      'game-assets/effects/magic/blue_magic_floor_decal_variant.png';
  static const blueMagicFloorDecalVariantTwoX =
      'game-assets/effects/magic/blue_magic_floor_decal_variant_2x.png';
  static const blueMagicSpark =
      'game-assets/effects/magic/blue_magic_spark.png';
  static const blueMagicSparkTwoX =
      'game-assets/effects/magic/blue_magic_spark_2x.png';
  static const magicBlueStarburst =
      'game-assets/effects/magic/blue_starburst.png';
  static const magicBlueStarburstTwoX =
      'game-assets/effects/magic/blue_starburst_2x.png';
  static const purpleMagicCircle =
      'game-assets/effects/magic/purple_magic_circle.png';
  static const purpleMagicCircleTwoX =
      'game-assets/effects/magic/purple_magic_circle_2x.png';
  static const magicVioletStarburst =
      'game-assets/effects/magic/violet_starburst.png';
  static const magicVioletStarburstTwoX =
      'game-assets/effects/magic/violet_starburst_2x.png';
  static const particlesBrownDustSpark =
      'game-assets/effects/particles/brown_dust_spark.png';
  static const particlesBrownDustSparkTwoX =
      'game-assets/effects/particles/brown_dust_spark_2x.png';
  static const particlesGoldSparkleCluster =
      'game-assets/effects/particles/gold_sparkle_cluster.png';
  static const particlesGoldSparkleClusterTwoX =
      'game-assets/effects/particles/gold_sparkle_cluster_2x.png';
  static const particlesGoldenBurst =
      'game-assets/effects/particles/golden_burst.png';
  static const particlesGoldenBurstTwoX =
      'game-assets/effects/particles/golden_burst_2x.png';
  static const particlesPurpleSparkleCluster =
      'game-assets/effects/particles/purple_sparkle_cluster.png';
  static const particlesPurpleSparkleClusterTwoX =
      'game-assets/effects/particles/purple_sparkle_cluster_2x.png';
  static const particlesSmallPurpleSpark =
      'game-assets/effects/particles/small_purple_spark.png';
  static const particlesSmallPurpleSparkTwoX =
      'game-assets/effects/particles/small_purple_spark_2x.png';
  static const particlesTinyGoldSpark =
      'game-assets/effects/particles/tiny_gold_spark.png';
  static const particlesTinyGoldSparkTwoX =
      'game-assets/effects/particles/tiny_gold_spark_2x.png';
  static const particlesTinyPurpleSpark =
      'game-assets/effects/particles/tiny_purple_spark.png';
  static const particlesTinyPurpleSparkTwoX =
      'game-assets/effects/particles/tiny_purple_spark_2x.png';
  static const particlesTinyWhiteSpark =
      'game-assets/effects/particles/tiny_white_spark.png';
  static const particlesTinyWhiteSparkTwoX =
      'game-assets/effects/particles/tiny_white_spark_2x.png';
  static const particlesWhiteLightSpark =
      'game-assets/effects/particles/white_light_spark.png';
  static const particlesWhiteLightSparkTwoX =
      'game-assets/effects/particles/white_light_spark_2x.png';
  static const smokePuff = 'game-assets/effects/smoke/smoke_puff.png';
  static const smokePuffTwoX = 'game-assets/effects/smoke/smoke_puff_2x.png';

  static const all = <String>[
    magicBlueIceSpike,
    magicBlueIceSpikeTwoX,
    blueMagicFloorDecal,
    blueMagicFloorDecalTwoX,
    blueMagicFloorDecalVariant,
    blueMagicFloorDecalVariantTwoX,
    blueMagicSpark,
    blueMagicSparkTwoX,
    magicBlueStarburst,
    magicBlueStarburstTwoX,
    purpleMagicCircle,
    purpleMagicCircleTwoX,
    magicVioletStarburst,
    magicVioletStarburstTwoX,
    particlesBrownDustSpark,
    particlesBrownDustSparkTwoX,
    particlesGoldSparkleCluster,
    particlesGoldSparkleClusterTwoX,
    particlesGoldenBurst,
    particlesGoldenBurstTwoX,
    particlesPurpleSparkleCluster,
    particlesPurpleSparkleClusterTwoX,
    particlesSmallPurpleSpark,
    particlesSmallPurpleSparkTwoX,
    particlesTinyGoldSpark,
    particlesTinyGoldSparkTwoX,
    particlesTinyPurpleSpark,
    particlesTinyPurpleSparkTwoX,
    particlesTinyWhiteSpark,
    particlesTinyWhiteSparkTwoX,
    particlesWhiteLightSpark,
    particlesWhiteLightSparkTwoX,
    smokePuff,
    smokePuffTwoX,
  ];
}

abstract final class UiAssets {
  static const buttonsCloseButton = 'game-assets/ui/buttons/close_button.png';
  static const buttonsCloseButtonTwoX =
      'game-assets/ui/buttons/close_button_2x.png';
  static const buttonsInventoryTabButton =
      'game-assets/ui/buttons/inventory_tab_button.png';
  static const buttonsInventoryTabButtonTwoX =
      'game-assets/ui/buttons/inventory_tab_button_2x.png';
  static const buttonsLearnButton = 'game-assets/ui/buttons/learn_button.png';
  static const buttonsLearnButtonTwoX =
      'game-assets/ui/buttons/learn_button_2x.png';
  static const buttonsMapTabButton =
      'game-assets/ui/buttons/map_tab_button.png';
  static const buttonsMapTabButtonTwoX =
      'game-assets/ui/buttons/map_tab_button_2x.png';
  static const buttonsPlusButton = 'game-assets/ui/buttons/plus_button.png';
  static const buttonsPlusButtonTwoX =
      'game-assets/ui/buttons/plus_button_2x.png';
  static const buttonsSettingsButton =
      'game-assets/ui/buttons/settings_button.png';
  static const buttonsSettingsButtonTwoX =
      'game-assets/ui/buttons/settings_button_2x.png';
  static const buttonsSocialTabButton =
      'game-assets/ui/buttons/social_tab_button.png';
  static const buttonsSocialTabButtonTwoX =
      'game-assets/ui/buttons/social_tab_button_2x.png';
  static const buttonsTrophyTabButton =
      'game-assets/ui/buttons/trophy_tab_button.png';
  static const buttonsTrophyTabButtonTwoX =
      'game-assets/ui/buttons/trophy_tab_button_2x.png';
  static const buttonsUpgradeButton =
      'game-assets/ui/buttons/upgrade_button.png';
  static const buttonsUpgradeButtonTwoX =
      'game-assets/ui/buttons/upgrade_button_2x.png';
  static const hudCoinCounter = 'game-assets/ui/hud/coin_counter.png';
  static const hudCoinCounterTwoX = 'game-assets/ui/hud/coin_counter_2x.png';
  static const hudEnergyBar = 'game-assets/ui/hud/energy_bar.png';
  static const hudEnergyBarTwoX = 'game-assets/ui/hud/energy_bar_2x.png';
  static const hudGemCounter = 'game-assets/ui/hud/gem_counter.png';
  static const hudGemCounterTwoX = 'game-assets/ui/hud/gem_counter_2x.png';
  static const hudHealthBar = 'game-assets/ui/hud/health_bar.png';
  static const hudHealthBarTwoX = 'game-assets/ui/hud/health_bar_2x.png';
  static const hudXpBar = 'game-assets/ui/hud/xp_bar.png';
  static const hudXpBarTwoX = 'game-assets/ui/hud/xp_bar_2x.png';
  static const iconsArmoredStatueIcon =
      'game-assets/ui/icons/armored_statue_icon.png';
  static const iconsArmoredStatueIconTwoX =
      'game-assets/ui/icons/armored_statue_icon_2x.png';
  static const iconsBlueDiamondGemIcon =
      'game-assets/ui/icons/blue_diamond_gem_icon.png';
  static const iconsBlueDiamondGemIconTwoX =
      'game-assets/ui/icons/blue_diamond_gem_icon_2x.png';
  static const iconsBluePotionIcon =
      'game-assets/ui/icons/blue_potion_icon.png';
  static const iconsBluePotionIconTwoX =
      'game-assets/ui/icons/blue_potion_icon_2x.png';
  static const iconsCrossedSwordsIcon =
      'game-assets/ui/icons/crossed_swords_icon.png';
  static const iconsCrossedSwordsIconTwoX =
      'game-assets/ui/icons/crossed_swords_icon_2x.png';
  static const iconsGoldAmuletIcon =
      'game-assets/ui/icons/gold_amulet_icon.png';
  static const iconsGoldAmuletIconTwoX =
      'game-assets/ui/icons/gold_amulet_icon_2x.png';
  static const iconsGoldChandelierIcon =
      'game-assets/ui/icons/gold_chandelier_icon.png';
  static const iconsGoldChandelierIconTwoX =
      'game-assets/ui/icons/gold_chandelier_icon_2x.png';
  static const iconsGoldenBellIcon =
      'game-assets/ui/icons/golden_bell_icon.png';
  static const iconsGoldenBellIconTwoX =
      'game-assets/ui/icons/golden_bell_icon_2x.png';
  static const iconsGoldenStarBadgeIcon =
      'game-assets/ui/icons/golden_star_badge_icon.png';
  static const iconsGoldenStarBadgeIconTwoX =
      'game-assets/ui/icons/golden_star_badge_icon_2x.png';
  static const iconsGoldenSunOrbIcon =
      'game-assets/ui/icons/golden_sun_orb_icon.png';
  static const iconsGoldenSunOrbIconTwoX =
      'game-assets/ui/icons/golden_sun_orb_icon_2x.png';
  static const iconsInteractionExclamationSpeechBubble =
      'game-assets/ui/icons/interaction_exclamation_speech_bubble.png';
  static const iconsInteractionExclamationSpeechBubbleTwoX =
      'game-assets/ui/icons/interaction_exclamation_speech_bubble_2x.png';
  static const iconsMagicCompassIcon =
      'game-assets/ui/icons/magic_compass_icon.png';
  static const iconsMagicCompassIconTwoX =
      'game-assets/ui/icons/magic_compass_icon_2x.png';
  static const iconsPurpleCrystalClusterIcon =
      'game-assets/ui/icons/purple_crystal_cluster_icon.png';
  static const iconsPurpleCrystalClusterIconTwoX =
      'game-assets/ui/icons/purple_crystal_cluster_icon_2x.png';
  static const iconsPurpleGemIcon = 'game-assets/ui/icons/purple_gem_icon.png';
  static const iconsPurpleGemIconTwoX =
      'game-assets/ui/icons/purple_gem_icon_2x.png';
  static const iconsPurplePotionIcon =
      'game-assets/ui/icons/purple_potion_icon.png';
  static const iconsPurplePotionIconTwoX =
      'game-assets/ui/icons/purple_potion_icon_2x.png';
  static const iconsQuestScrollIcon =
      'game-assets/ui/icons/quest_scroll_icon.png';
  static const iconsQuestScrollIconTwoX =
      'game-assets/ui/icons/quest_scroll_icon_2x.png';
  static const iconsRedSpellbookIcon =
      'game-assets/ui/icons/red_spellbook_icon.png';
  static const iconsRedSpellbookIconTwoX =
      'game-assets/ui/icons/red_spellbook_icon_2x.png';
  static const iconsRoundDrumIcon = 'game-assets/ui/icons/round_drum_icon.png';
  static const iconsRoundDrumIconTwoX =
      'game-assets/ui/icons/round_drum_icon_2x.png';
  static const iconsSealedEnvelopeIcon =
      'game-assets/ui/icons/sealed_envelope_icon.png';
  static const iconsSealedEnvelopeIconTwoX =
      'game-assets/ui/icons/sealed_envelope_icon_2x.png';
  static const iconsShieldBadgeIcon =
      'game-assets/ui/icons/shield_badge_icon.png';
  static const iconsShieldBadgeIconTwoX =
      'game-assets/ui/icons/shield_badge_icon_2x.png';
  static const iconsSpellbookIcon = 'game-assets/ui/icons/spellbook_icon.png';
  static const iconsSpellbookIconTwoX =
      'game-assets/ui/icons/spellbook_icon_2x.png';
  static const iconsStoneResourcePileIcon =
      'game-assets/ui/icons/stone_resource_pile_icon.png';
  static const iconsStoneResourcePileIconTwoX =
      'game-assets/ui/icons/stone_resource_pile_icon_2x.png';
  static const iconsSwordIcon = 'game-assets/ui/icons/sword_icon.png';
  static const iconsSwordIconTwoX = 'game-assets/ui/icons/sword_icon_2x.png';
  static const iconsTreasureChestIcon =
      'game-assets/ui/icons/treasure_chest_icon.png';
  static const iconsTreasureChestIconTwoX =
      'game-assets/ui/icons/treasure_chest_icon_2x.png';
  static const iconsTrophyCupIcon = 'game-assets/ui/icons/trophy_cup_icon.png';
  static const iconsTrophyCupIconTwoX =
      'game-assets/ui/icons/trophy_cup_icon_2x.png';
  static const iconsWoodenCrateIcon =
      'game-assets/ui/icons/wooden_crate_icon.png';
  static const iconsWoodenCrateIconTwoX =
      'game-assets/ui/icons/wooden_crate_icon_2x.png';
  static const panelsCodingTowerLessonPanel =
      'game-assets/ui/panels/coding_tower_lesson_panel.png';
  static const panelsCodingTowerLessonPanelTwoX =
      'game-assets/ui/panels/coding_tower_lesson_panel_2x.png';
  static const panelsProfessorDialoguePanel =
      'game-assets/ui/panels/professor_dialogue_panel.png';
  static const panelsProfessorDialoguePanelTwoX =
      'game-assets/ui/panels/professor_dialogue_panel_2x.png';
  static const panelsQuestCompletedPanel =
      'game-assets/ui/panels/quest_completed_panel.png';
  static const panelsQuestCompletedPanelTwoX =
      'game-assets/ui/panels/quest_completed_panel_2x.png';
  static const panelsUiPanelBorderSlice =
      'game-assets/ui/panels/ui_panel_border_slice.png';
  static const panelsUiPanelBorderSliceTwoX =
      'game-assets/ui/panels/ui_panel_border_slice_2x.png';

  static const all = <String>[
    buttonsCloseButton,
    buttonsCloseButtonTwoX,
    buttonsInventoryTabButton,
    buttonsInventoryTabButtonTwoX,
    buttonsLearnButton,
    buttonsLearnButtonTwoX,
    buttonsMapTabButton,
    buttonsMapTabButtonTwoX,
    buttonsPlusButton,
    buttonsPlusButtonTwoX,
    buttonsSettingsButton,
    buttonsSettingsButtonTwoX,
    buttonsSocialTabButton,
    buttonsSocialTabButtonTwoX,
    buttonsTrophyTabButton,
    buttonsTrophyTabButtonTwoX,
    buttonsUpgradeButton,
    buttonsUpgradeButtonTwoX,
    hudCoinCounter,
    hudCoinCounterTwoX,
    hudEnergyBar,
    hudEnergyBarTwoX,
    hudGemCounter,
    hudGemCounterTwoX,
    hudHealthBar,
    hudHealthBarTwoX,
    hudXpBar,
    hudXpBarTwoX,
    iconsArmoredStatueIcon,
    iconsArmoredStatueIconTwoX,
    iconsBlueDiamondGemIcon,
    iconsBlueDiamondGemIconTwoX,
    iconsBluePotionIcon,
    iconsBluePotionIconTwoX,
    iconsCrossedSwordsIcon,
    iconsCrossedSwordsIconTwoX,
    iconsGoldAmuletIcon,
    iconsGoldAmuletIconTwoX,
    iconsGoldChandelierIcon,
    iconsGoldChandelierIconTwoX,
    iconsGoldenBellIcon,
    iconsGoldenBellIconTwoX,
    iconsGoldenStarBadgeIcon,
    iconsGoldenStarBadgeIconTwoX,
    iconsGoldenSunOrbIcon,
    iconsGoldenSunOrbIconTwoX,
    iconsInteractionExclamationSpeechBubble,
    iconsInteractionExclamationSpeechBubbleTwoX,
    iconsMagicCompassIcon,
    iconsMagicCompassIconTwoX,
    iconsPurpleCrystalClusterIcon,
    iconsPurpleCrystalClusterIconTwoX,
    iconsPurpleGemIcon,
    iconsPurpleGemIconTwoX,
    iconsPurplePotionIcon,
    iconsPurplePotionIconTwoX,
    iconsQuestScrollIcon,
    iconsQuestScrollIconTwoX,
    iconsRedSpellbookIcon,
    iconsRedSpellbookIconTwoX,
    iconsRoundDrumIcon,
    iconsRoundDrumIconTwoX,
    iconsSealedEnvelopeIcon,
    iconsSealedEnvelopeIconTwoX,
    iconsShieldBadgeIcon,
    iconsShieldBadgeIconTwoX,
    iconsSpellbookIcon,
    iconsSpellbookIconTwoX,
    iconsStoneResourcePileIcon,
    iconsStoneResourcePileIconTwoX,
    iconsSwordIcon,
    iconsSwordIconTwoX,
    iconsTreasureChestIcon,
    iconsTreasureChestIconTwoX,
    iconsTrophyCupIcon,
    iconsTrophyCupIconTwoX,
    iconsWoodenCrateIcon,
    iconsWoodenCrateIconTwoX,
    panelsCodingTowerLessonPanel,
    panelsCodingTowerLessonPanelTwoX,
    panelsProfessorDialoguePanel,
    panelsProfessorDialoguePanelTwoX,
    panelsQuestCompletedPanel,
    panelsQuestCompletedPanelTwoX,
    panelsUiPanelBorderSlice,
    panelsUiPanelBorderSliceTwoX,
  ];
}

abstract final class NpcAssets {
  static const guardNpc = 'game-assets/npc/guard_npc.png';
  static const guardNpcTwoX = 'game-assets/npc/guard_npc_2x.png';
  static const librarianNpc = 'game-assets/npc/librarian_npc.png';
  static const librarianNpcTwoX = 'game-assets/npc/librarian_npc_2x.png';
  static const professorNpc = 'game-assets/npc/professor_npc.png';
  static const professorNpcTwoX = 'game-assets/npc/professor_npc_2x.png';
  static const studentNpc = 'game-assets/npc/student_npc.png';
  static const studentNpcTwoX = 'game-assets/npc/student_npc_2x.png';

  static const all = <String>[
    guardNpc,
    guardNpcTwoX,
    librarianNpc,
    librarianNpcTwoX,
    professorNpc,
    professorNpcTwoX,
    studentNpc,
    studentNpcTwoX,
  ];
}

abstract final class DecorationAssets {
  static const bannersBlueHangingBanner =
      'game-assets/decorations/banners/blue_hanging_banner.png';
  static const bannersBlueHangingBannerTwoX =
      'game-assets/decorations/banners/blue_hanging_banner_2x.png';
  static const bannersGoldBannerPost =
      'game-assets/decorations/banners/gold_banner_post.png';
  static const bannersGoldBannerPostTwoX =
      'game-assets/decorations/banners/gold_banner_post_2x.png';
  static const bannersGoldFlagPost =
      'game-assets/decorations/banners/gold_flag_post.png';
  static const bannersGoldFlagPostTwoX =
      'game-assets/decorations/banners/gold_flag_post_2x.png';
  static const bannersPurpleBannerLampPost =
      'game-assets/decorations/banners/purple_banner_lamp_post.png';
  static const bannersPurpleBannerLampPostTwoX =
      'game-assets/decorations/banners/purple_banner_lamp_post_2x.png';
  static const bannersPurpleHangingBanner =
      'game-assets/decorations/banners/purple_hanging_banner.png';
  static const bannersPurpleHangingBannerTwoX =
      'game-assets/decorations/banners/purple_hanging_banner_2x.png';
  static const bannersPurpleVerticalBanner =
      'game-assets/decorations/banners/purple_vertical_banner.png';
  static const bannersPurpleVerticalBannerTwoX =
      'game-assets/decorations/banners/purple_vertical_banner_2x.png';
  static const bannersTilePurpleHangingBanner =
      'game-assets/decorations/banners/tile_purple_hanging_banner.png';
  static const bannersTilePurpleHangingBannerTwoX =
      'game-assets/decorations/banners/tile_purple_hanging_banner_2x.png';
  static const containersBlueCauldron =
      'game-assets/decorations/containers/blue_cauldron.png';
  static const containersBlueCauldronTwoX =
      'game-assets/decorations/containers/blue_cauldron_2x.png';
  static const containersBlueSupplyCrate =
      'game-assets/decorations/containers/blue_supply_crate.png';
  static const containersBlueSupplyCrateTwoX =
      'game-assets/decorations/containers/blue_supply_crate_2x.png';
  static const containersBrownTreasureCrate =
      'game-assets/decorations/containers/brown_treasure_crate.png';
  static const containersBrownTreasureCrateTwoX =
      'game-assets/decorations/containers/brown_treasure_crate_2x.png';
  static const containersDarkMetalBarrel =
      'game-assets/decorations/containers/dark_metal_barrel.png';
  static const containersDarkMetalBarrelTwoX =
      'game-assets/decorations/containers/dark_metal_barrel_2x.png';
  static const containersGreenLiquidBarrel =
      'game-assets/decorations/containers/green_liquid_barrel.png';
  static const containersGreenLiquidBarrelTwoX =
      'game-assets/decorations/containers/green_liquid_barrel_2x.png';
  static const containersStoneBarrel =
      'game-assets/decorations/containers/stone_barrel.png';
  static const containersStoneBarrelTwoX =
      'game-assets/decorations/containers/stone_barrel_2x.png';
  static const containersWoodenBarrel =
      'game-assets/decorations/containers/wooden_barrel.png';
  static const containersWoodenBarrelTwoX =
      'game-assets/decorations/containers/wooden_barrel_2x.png';
  static const containersWoodenBarrelTwoXTiles =
      'game-assets/decorations/containers/wooden_barrel_2x_tiles.png';
  static const containersWoodenBarrelTiles =
      'game-assets/decorations/containers/wooden_barrel_tiles.png';
  static const fencesWoodenGate =
      'game-assets/decorations/fences/wooden_gate.png';
  static const fencesWoodenGateTwoX =
      'game-assets/decorations/fences/wooden_gate_2x.png';
  static const lampsBlackLanternPost =
      'game-assets/decorations/lamps/black_lantern_post.png';
  static const lampsBlackLanternPostTwoX =
      'game-assets/decorations/lamps/black_lantern_post_2x.png';
  static const lampsGoldLanternPost =
      'game-assets/decorations/lamps/gold_lantern_post.png';
  static const lampsGoldLanternPostTwoX =
      'game-assets/decorations/lamps/gold_lantern_post_2x.png';
  static const lampsLanternPost =
      'game-assets/decorations/lamps/lantern_post.png';
  static const lampsLanternPostTwoX =
      'game-assets/decorations/lamps/lantern_post_2x.png';
  static const lampsStoneLantern =
      'game-assets/decorations/lamps/stone_lantern.png';
  static const lampsStoneLanternTwoX =
      'game-assets/decorations/lamps/stone_lantern_2x.png';
  static const propsBlueFountain =
      'game-assets/decorations/props/blue_fountain.png';
  static const propsBlueFountainTwoX =
      'game-assets/decorations/props/blue_fountain_2x.png';
  static const propsBrokenStoneWall =
      'game-assets/decorations/props/broken_stone_wall.png';
  static const propsBrokenStoneWallTwoX =
      'game-assets/decorations/props/broken_stone_wall_2x.png';
  static const propsCentralFountain =
      'game-assets/decorations/props/central_fountain.png';
  static const propsCentralFountainTwoX =
      'game-assets/decorations/props/central_fountain_2x.png';
  static const propsStoneFloorPlatform =
      'game-assets/decorations/props/stone_floor_platform.png';
  static const propsStoneFloorPlatformTwoX =
      'game-assets/decorations/props/stone_floor_platform_2x.png';
  static const propsStoneGuardianStatue =
      'game-assets/decorations/props/stone_guardian_statue.png';
  static const propsStoneGuardianStatueTwoX =
      'game-assets/decorations/props/stone_guardian_statue_2x.png';
  static const propsStonePillar =
      'game-assets/decorations/props/stone_pillar.png';
  static const propsStonePillarTwoX =
      'game-assets/decorations/props/stone_pillar_2x.png';
  static const propsStoneWell = 'game-assets/decorations/props/stone_well.png';
  static const propsStoneWellTwoX =
      'game-assets/decorations/props/stone_well_2x.png';
  static const signsDirectionSignpost =
      'game-assets/decorations/signs/direction_signpost.png';
  static const signsDirectionSignpostTwoX =
      'game-assets/decorations/signs/direction_signpost_2x.png';
  static const signsHangingSignFrame =
      'game-assets/decorations/signs/hanging_sign_frame.png';
  static const signsHangingSignFrameTwoX =
      'game-assets/decorations/signs/hanging_sign_frame_2x.png';
  static const signsShieldSignpost =
      'game-assets/decorations/signs/shield_signpost.png';
  static const signsShieldSignpostTwoX =
      'game-assets/decorations/signs/shield_signpost_2x.png';
  static const signsSmallSignpost =
      'game-assets/decorations/signs/small_signpost.png';
  static const signsSmallSignpostTwoX =
      'game-assets/decorations/signs/small_signpost_2x.png';
  static const signsSquareSignpost =
      'game-assets/decorations/signs/square_signpost.png';
  static const signsSquareSignpostTwoX =
      'game-assets/decorations/signs/square_signpost_2x.png';
  static const signsTinyShieldMarker =
      'game-assets/decorations/signs/tiny_shield_marker.png';
  static const signsTinyShieldMarkerTwoX =
      'game-assets/decorations/signs/tiny_shield_marker_2x.png';
  static const signsWoodenSignpost =
      'game-assets/decorations/signs/wooden_signpost.png';
  static const signsWoodenSignpostTwoX =
      'game-assets/decorations/signs/wooden_signpost_2x.png';
  static const signsWoodenWayfindingSign =
      'game-assets/decorations/signs/wooden_wayfinding_sign.png';
  static const signsWoodenWayfindingSignTwoX =
      'game-assets/decorations/signs/wooden_wayfinding_sign_2x.png';

  static const all = <String>[
    bannersBlueHangingBanner,
    bannersBlueHangingBannerTwoX,
    bannersGoldBannerPost,
    bannersGoldBannerPostTwoX,
    bannersGoldFlagPost,
    bannersGoldFlagPostTwoX,
    bannersPurpleBannerLampPost,
    bannersPurpleBannerLampPostTwoX,
    bannersPurpleHangingBanner,
    bannersPurpleHangingBannerTwoX,
    bannersPurpleVerticalBanner,
    bannersPurpleVerticalBannerTwoX,
    bannersTilePurpleHangingBanner,
    bannersTilePurpleHangingBannerTwoX,
    containersBlueCauldron,
    containersBlueCauldronTwoX,
    containersBlueSupplyCrate,
    containersBlueSupplyCrateTwoX,
    containersBrownTreasureCrate,
    containersBrownTreasureCrateTwoX,
    containersDarkMetalBarrel,
    containersDarkMetalBarrelTwoX,
    containersGreenLiquidBarrel,
    containersGreenLiquidBarrelTwoX,
    containersStoneBarrel,
    containersStoneBarrelTwoX,
    containersWoodenBarrel,
    containersWoodenBarrelTwoX,
    containersWoodenBarrelTwoXTiles,
    containersWoodenBarrelTiles,
    fencesWoodenGate,
    fencesWoodenGateTwoX,
    lampsBlackLanternPost,
    lampsBlackLanternPostTwoX,
    lampsGoldLanternPost,
    lampsGoldLanternPostTwoX,
    lampsLanternPost,
    lampsLanternPostTwoX,
    lampsStoneLantern,
    lampsStoneLanternTwoX,
    propsBlueFountain,
    propsBlueFountainTwoX,
    propsBrokenStoneWall,
    propsBrokenStoneWallTwoX,
    propsCentralFountain,
    propsCentralFountainTwoX,
    propsStoneFloorPlatform,
    propsStoneFloorPlatformTwoX,
    propsStoneGuardianStatue,
    propsStoneGuardianStatueTwoX,
    propsStonePillar,
    propsStonePillarTwoX,
    propsStoneWell,
    propsStoneWellTwoX,
    signsDirectionSignpost,
    signsDirectionSignpostTwoX,
    signsHangingSignFrame,
    signsHangingSignFrameTwoX,
    signsShieldSignpost,
    signsShieldSignpostTwoX,
    signsSmallSignpost,
    signsSmallSignpostTwoX,
    signsSquareSignpost,
    signsSquareSignpostTwoX,
    signsTinyShieldMarker,
    signsTinyShieldMarkerTwoX,
    signsWoodenSignpost,
    signsWoodenSignpostTwoX,
    signsWoodenWayfindingSign,
    signsWoodenWayfindingSignTwoX,
  ];
}

abstract final class ReferenceAssets {
  static const arcanistIslandFullReference =
      'game-assets/reference/arcanist_island_full_reference.png';
  static const skyCloudBackground =
      'game-assets/reference/backgrounds/sky_cloud_background.png';

  static const all = <String>[arcanistIslandFullReference, skyCloudBackground];
}
