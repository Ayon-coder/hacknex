import 'package:flame/components.dart';
import '../../../config/game_assets.dart';
import 'decoration_component.dart';

/// Reusable manager instantiating AAA level design handcrafted decoration clusters around EVERY building
/// with level-gated progression (Level 1 base, Level 2 banners/flowers/lamps, Level 3 crystals/statues/pillars)
/// and filling open grass spaces without blocking walking paths.
class DecorationManager {
  static List<DecorationComponent> createDecorations() {
    return [
      // ═══════════════════════════════════════════════════════════════════════
      // 1. GRAND HALL (North: 800, 210) — Hub & Headquarters
      // ═══════════════════════════════════════════════════════════════════════
      // Level 1 Base
      DecorationComponent(position: Vector2(665, 145), size: Vector2(64, 64), assetPath: NatureAssets.treesTallPineTree, buildingId: 'grand_hall', requiredLevel: 1),
      DecorationComponent(position: Vector2(935, 145), size: Vector2(64, 64), assetPath: NatureAssets.treesTallPineTree, buildingId: 'grand_hall', requiredLevel: 1),
      DecorationComponent(position: Vector2(740, 310), size: Vector2(36, 28), assetPath: DecorationAssets.fencesWoodenGate, buildingId: 'grand_hall', requiredLevel: 1),
      DecorationComponent(position: Vector2(860, 310), size: Vector2(36, 28), assetPath: DecorationAssets.fencesWoodenGate, buildingId: 'grand_hall', requiredLevel: 1),

      // Level 2 Enhancements
      DecorationComponent(position: Vector2(680, 260), size: Vector2(32, 54), assetPath: DecorationAssets.bannersPurpleVerticalBanner, buildingId: 'grand_hall', requiredLevel: 2),
      DecorationComponent(position: Vector2(920, 260), size: Vector2(32, 54), assetPath: DecorationAssets.bannersPurpleVerticalBanner, buildingId: 'grand_hall', requiredLevel: 2),
      DecorationComponent(position: Vector2(705, 305), size: Vector2(28, 28), assetPath: NatureAssets.flowersYellowFlowerBed, buildingId: 'grand_hall', requiredLevel: 2),
      DecorationComponent(position: Vector2(895, 305), size: Vector2(28, 28), assetPath: NatureAssets.flowersYellowFlowerBed, buildingId: 'grand_hall', requiredLevel: 2),

      // Level 3 Grand Enhancements
      DecorationComponent(position: Vector2(735, 305), size: Vector2(32, 48), assetPath: DecorationAssets.lampsGoldLanternPost, buildingId: 'grand_hall', requiredLevel: 3),
      DecorationComponent(position: Vector2(865, 305), size: Vector2(32, 48), assetPath: DecorationAssets.lampsGoldLanternPost, buildingId: 'grand_hall', requiredLevel: 3),
      DecorationComponent(position: Vector2(635, 190), size: Vector2(36, 56), assetPath: DecorationAssets.propsStonePillar, buildingId: 'grand_hall', requiredLevel: 3),
      DecorationComponent(position: Vector2(965, 190), size: Vector2(36, 56), assetPath: DecorationAssets.propsStonePillar, buildingId: 'grand_hall', requiredLevel: 3),

      // ═══════════════════════════════════════════════════════════════════════
      // 2. LIBRARY (North West: 400, 260) — Lore & Books
      // ═══════════════════════════════════════════════════════════════════════
      // Level 1 Base
      DecorationComponent(position: Vector2(275, 195), size: Vector2(60, 60), assetPath: NatureAssets.treesRoundLeafTree, buildingId: 'library', requiredLevel: 1),
      DecorationComponent(position: Vector2(525, 195), size: Vector2(60, 60), assetPath: NatureAssets.treesRoundLeafTree, buildingId: 'library', requiredLevel: 1),
      DecorationComponent(position: Vector2(340, 345), size: Vector2(36, 28), assetPath: DecorationAssets.fencesWoodenGate, buildingId: 'library', requiredLevel: 1),
      DecorationComponent(position: Vector2(460, 345), size: Vector2(36, 28), assetPath: DecorationAssets.fencesWoodenGate, buildingId: 'library', requiredLevel: 1),

      // Level 2 Enhancements
      DecorationComponent(position: Vector2(295, 305), size: Vector2(32, 32), assetPath: DecorationAssets.signsWoodenWayfindingSign, buildingId: 'library', requiredLevel: 2),
      DecorationComponent(position: Vector2(505, 305), size: Vector2(32, 32), assetPath: DecorationAssets.containersWoodenBarrel, buildingId: 'library', requiredLevel: 2),
      DecorationComponent(position: Vector2(310, 335), size: Vector2(28, 28), assetPath: NatureAssets.flowersPurpleFlowerPatch, buildingId: 'library', requiredLevel: 2),
      DecorationComponent(position: Vector2(490, 335), size: Vector2(28, 28), assetPath: NatureAssets.flowersPurpleFlowerPatch, buildingId: 'library', requiredLevel: 2),

      // Level 3 Grand Enhancements
      DecorationComponent(position: Vector2(355, 345), size: Vector2(32, 40), assetPath: DecorationAssets.lampsStoneLantern, buildingId: 'library', requiredLevel: 3),
      DecorationComponent(position: Vector2(445, 345), size: Vector2(32, 40), assetPath: DecorationAssets.lampsStoneLantern, buildingId: 'library', requiredLevel: 3),
      DecorationComponent(position: Vector2(245, 230), size: Vector2(48, 54), assetPath: DecorationAssets.propsStoneGuardianStatue, buildingId: 'library', requiredLevel: 3),

      // ═══════════════════════════════════════════════════════════════════════
      // 3. ASTRONOMY TOWER (North East: 1200, 260) — Physics & Celestial
      // ═══════════════════════════════════════════════════════════════════════
      // Level 1 Base
      DecorationComponent(position: Vector2(1075, 195), size: Vector2(60, 60), assetPath: NatureAssets.treesEnchantedForestTree, buildingId: 'astronomy_tower', requiredLevel: 1),
      DecorationComponent(position: Vector2(1325, 195), size: Vector2(60, 60), assetPath: NatureAssets.treesEnchantedForestTree, buildingId: 'astronomy_tower', requiredLevel: 1),

      // Level 2 Enhancements
      DecorationComponent(position: Vector2(1095, 305), size: Vector2(32, 54), assetPath: DecorationAssets.propsStonePillar, buildingId: 'astronomy_tower', requiredLevel: 2),
      DecorationComponent(position: Vector2(1305, 305), size: Vector2(32, 54), assetPath: DecorationAssets.propsStonePillar, buildingId: 'astronomy_tower', requiredLevel: 2),
      DecorationComponent(position: Vector2(1110, 335), size: Vector2(28, 28), assetPath: NatureAssets.flowersPurpleFlowerPatch, buildingId: 'astronomy_tower', requiredLevel: 2),
      DecorationComponent(position: Vector2(1290, 335), size: Vector2(28, 28), assetPath: NatureAssets.flowersPurpleFlowerPatch, buildingId: 'astronomy_tower', requiredLevel: 2),

      // Level 3 Grand Enhancements
      DecorationComponent(position: Vector2(1155, 345), size: Vector2(32, 48), assetPath: DecorationAssets.lampsGoldLanternPost, buildingId: 'astronomy_tower', requiredLevel: 3),
      DecorationComponent(position: Vector2(1245, 345), size: Vector2(32, 48), assetPath: DecorationAssets.lampsGoldLanternPost, buildingId: 'astronomy_tower', requiredLevel: 3),
      DecorationComponent(position: Vector2(1355, 230), size: Vector2(48, 54), assetPath: DecorationAssets.propsStoneGuardianStatue, buildingId: 'astronomy_tower', requiredLevel: 3),

      // ═══════════════════════════════════════════════════════════════════════
      // 4. ARENA (West: 310, 520) — Duel Battles & Pillars
      // ═══════════════════════════════════════════════════════════════════════
      // Level 1 Base
      DecorationComponent(position: Vector2(185, 455), size: Vector2(36, 56), assetPath: DecorationAssets.propsStonePillar, buildingId: 'arena', requiredLevel: 1),
      DecorationComponent(position: Vector2(435, 455), size: Vector2(36, 56), assetPath: DecorationAssets.propsStonePillar, buildingId: 'arena', requiredLevel: 1),

      // Level 2 Enhancements
      DecorationComponent(position: Vector2(205, 565), size: Vector2(32, 48), assetPath: DecorationAssets.bannersGoldFlagPost, buildingId: 'arena', requiredLevel: 2),
      DecorationComponent(position: Vector2(415, 565), size: Vector2(32, 48), assetPath: DecorationAssets.bannersGoldFlagPost, buildingId: 'arena', requiredLevel: 2),
      DecorationComponent(position: Vector2(220, 595), size: Vector2(28, 28), assetPath: NatureAssets.flowersYellowFlowerBed, buildingId: 'arena', requiredLevel: 2),
      DecorationComponent(position: Vector2(400, 595), size: Vector2(28, 28), assetPath: NatureAssets.flowersYellowFlowerBed, buildingId: 'arena', requiredLevel: 2),

      // Level 3 Grand Enhancements
      DecorationComponent(position: Vector2(265, 605), size: Vector2(32, 48), assetPath: DecorationAssets.lampsBlackLanternPost, buildingId: 'arena', requiredLevel: 3),
      DecorationComponent(position: Vector2(355, 605), size: Vector2(32, 48), assetPath: DecorationAssets.lampsBlackLanternPost, buildingId: 'arena', requiredLevel: 3),
      DecorationComponent(position: Vector2(250, 615), size: Vector2(36, 28), assetPath: DecorationAssets.fencesWoodenGate, buildingId: 'arena', requiredLevel: 3),
      DecorationComponent(position: Vector2(370, 615), size: Vector2(36, 28), assetPath: DecorationAssets.fencesWoodenGate, buildingId: 'arena', requiredLevel: 3),

      // ═══════════════════════════════════════════════════════════════════════
      // 5. POTION LAB (South West: 440, 770) — Alchemy Barrels & Crates
      // ═══════════════════════════════════════════════════════════════════════
      // Level 1 Base
      DecorationComponent(position: Vector2(315, 715), size: Vector2(36, 40), assetPath: DecorationAssets.containersGreenLiquidBarrel, buildingId: 'potion_lab', requiredLevel: 1),
      DecorationComponent(position: Vector2(565, 715), size: Vector2(36, 40), assetPath: DecorationAssets.containersBlueCauldron, buildingId: 'potion_lab', requiredLevel: 1),

      // Level 2 Enhancements
      DecorationComponent(position: Vector2(335, 810), size: Vector2(32, 32), assetPath: DecorationAssets.containersBlueSupplyCrate, buildingId: 'potion_lab', requiredLevel: 2),
      DecorationComponent(position: Vector2(545, 810), size: Vector2(32, 32), assetPath: DecorationAssets.containersBrownTreasureCrate, buildingId: 'potion_lab', requiredLevel: 2),
      DecorationComponent(position: Vector2(355, 835), size: Vector2(28, 28), assetPath: NatureAssets.flowersPurpleFlowerPatch, buildingId: 'potion_lab', requiredLevel: 2),
      DecorationComponent(position: Vector2(525, 835), size: Vector2(28, 28), assetPath: NatureAssets.flowersPurpleFlowerPatch, buildingId: 'potion_lab', requiredLevel: 2),

      // Level 3 Grand Enhancements
      DecorationComponent(position: Vector2(395, 850), size: Vector2(32, 40), assetPath: DecorationAssets.lampsStoneLantern, buildingId: 'potion_lab', requiredLevel: 3),
      DecorationComponent(position: Vector2(485, 850), size: Vector2(32, 40), assetPath: DecorationAssets.lampsStoneLantern, buildingId: 'potion_lab', requiredLevel: 3),
      DecorationComponent(position: Vector2(370, 855), size: Vector2(36, 28), assetPath: DecorationAssets.fencesWoodenGate, buildingId: 'potion_lab', requiredLevel: 3),
      DecorationComponent(position: Vector2(510, 855), size: Vector2(36, 28), assetPath: DecorationAssets.fencesWoodenGate, buildingId: 'potion_lab', requiredLevel: 3),

      // ═══════════════════════════════════════════════════════════════════════
      // 6. CODING TOWER (South East: 1160, 770) — Programming Crystals & Books
      // ═══════════════════════════════════════════════════════════════════════
      // Level 1 Base
      DecorationComponent(position: Vector2(1035, 715), size: Vector2(60, 60), assetPath: NatureAssets.treesRoundTree, buildingId: 'coding_tower', requiredLevel: 1),
      DecorationComponent(position: Vector2(1285, 715), size: Vector2(60, 60), assetPath: NatureAssets.treesRoundTree, buildingId: 'coding_tower', requiredLevel: 1),

      // Level 2 Enhancements
      DecorationComponent(position: Vector2(1055, 810), size: Vector2(36, 36), assetPath: NatureAssets.rocksRockCluster, buildingId: 'coding_tower', requiredLevel: 2),
      DecorationComponent(position: Vector2(1265, 810), size: Vector2(36, 36), assetPath: NatureAssets.rocksRockCluster, buildingId: 'coding_tower', requiredLevel: 2),
      DecorationComponent(position: Vector2(1075, 835), size: Vector2(28, 28), assetPath: NatureAssets.flowersWhiteFlowerGrassTile, buildingId: 'coding_tower', requiredLevel: 2),
      DecorationComponent(position: Vector2(1245, 835), size: Vector2(28, 28), assetPath: NatureAssets.flowersWhiteFlowerGrassTile, buildingId: 'coding_tower', requiredLevel: 2),

      // Level 3 Grand Enhancements
      DecorationComponent(position: Vector2(1115, 850), size: Vector2(32, 48), assetPath: DecorationAssets.lampsGoldLanternPost, buildingId: 'coding_tower', requiredLevel: 3),
      DecorationComponent(position: Vector2(1205, 850), size: Vector2(32, 48), assetPath: DecorationAssets.lampsGoldLanternPost, buildingId: 'coding_tower', requiredLevel: 3),
      DecorationComponent(position: Vector2(1090, 855), size: Vector2(36, 28), assetPath: DecorationAssets.fencesWoodenGate, buildingId: 'coding_tower', requiredLevel: 3),
      DecorationComponent(position: Vector2(1230, 855), size: Vector2(36, 28), assetPath: DecorationAssets.fencesWoodenGate, buildingId: 'coding_tower', requiredLevel: 3),

      // ═══════════════════════════════════════════════════════════════════════
      // 7. CENTRAL PLAZA & WAYPOINT LAMPS
      // ═══════════════════════════════════════════════════════════════════════
      DecorationComponent(position: Vector2(720, 520), size: Vector2(32, 48), assetPath: DecorationAssets.lampsGoldLanternPost),
      DecorationComponent(position: Vector2(880, 520), size: Vector2(32, 48), assetPath: DecorationAssets.lampsGoldLanternPost),
      DecorationComponent(position: Vector2(800, 640), size: Vector2(32, 48), assetPath: DecorationAssets.lampsGoldLanternPost),

      // ═══════════════════════════════════════════════════════════════════════
      // 8. AAA FILLER PROPS
      // ═══════════════════════════════════════════════════════════════════════
      DecorationComponent(position: Vector2(560, 160), size: Vector2(36, 36), assetPath: NatureAssets.rocksRockCluster),
      DecorationComponent(position: Vector2(250, 240), size: Vector2(32, 32), assetPath: NatureAssets.flowersPinkFlowerPatch),
      DecorationComponent(position: Vector2(1040, 160), size: Vector2(36, 36), assetPath: NatureAssets.rocksRockCluster),
      DecorationComponent(position: Vector2(1350, 240), size: Vector2(32, 32), assetPath: NatureAssets.flowersPinkFlowerPatch),
      DecorationComponent(position: Vector2(180, 580), size: Vector2(36, 36), assetPath: NatureAssets.treesTreeStump),
      DecorationComponent(position: Vector2(1420, 580), size: Vector2(36, 36), assetPath: NatureAssets.rocksRockCluster),
      DecorationComponent(position: Vector2(260, 780), size: Vector2(36, 36), assetPath: NatureAssets.bushesLeafyBush),
      DecorationComponent(position: Vector2(1340, 780), size: Vector2(36, 36), assetPath: DecorationAssets.propsStoneWell),
    ];
  }
}
