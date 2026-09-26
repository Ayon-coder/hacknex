# Hexafalls Asset Duplicate Report

Scope: `/home/phantom/Documents/hexafalls/assets` and `/home/phantom/Documents/hexafalls/game-assets`.

No files were deleted, moved, or archived.

## Summary

- Images inspected: 566
- Exact duplicate groups: 94
- Files participating in exact duplicate groups: 189
- Redundant exact copies if one per group is kept: 95
- Exact cross-tree duplicate groups (`assets/` <-> `game-assets/`): 66
- Same-object `_2x` variant groups found: 174

## Recommendation Policy

- Prefer `game-assets/` over legacy `assets/` when content is byte-for-byte identical, because `game-assets/` has descriptive names and the organized folder structure.
- Prefer `_2x` variants when they represent the same object and the base version is only a lower-resolution copy.
- Do not archive animation-frame duplicates just because hashes match; repeated frames may be intentional timing holds.
- Before archiving legacy `assets/` files, update Flutter references in `lib/config/asset_paths.dart` and related code.

## Highest-Confidence Archive Candidates

These are exact duplicates across the legacy and organized trees. Keep the `game-assets/` descriptive copy; archive the legacy numbered/older copy after code references are updated.

| Keep | Archive | Size |
|---|---|---:|
| `game-assets/buildings/grand_hall.png` | `assets/buildings/buildings_00.png` | 200x196 |
| `game-assets/buildings/library.png` | `assets/buildings/buildings_01.png` | 168x160 |
| `game-assets/buildings/astronomy_tower.png` | `assets/buildings/buildings_02.png` | 115x196 |
| `game-assets/buildings/duel_arena.png` | `assets/buildings/buildings_03.png` | 179x129 |
| `game-assets/buildings/alchemy_lab.png` | `assets/buildings/buildings_04.png` | 195x143 |
| `game-assets/buildings/history_hall.png` | `assets/buildings/buildings_05.png` | 149x114 |
| `game-assets/buildings/coding_tower.png` | `assets/buildings/buildings_06.png` | 162x147 |
| `game-assets/nature/trees/enchanted_forest_tree.png` | `assets/buildings/buildings_07.png` | 175x146 |
| `game-assets/nature/trees/broadleaf_tree.png` | `assets/decorations/nature_00.png` | 69x72 |
| `game-assets/nature/trees/tall_pine_tree.png` | `assets/decorations/nature_01.png` | 42x75 |
| `game-assets/nature/trees/small_pine_tree.png` | `assets/decorations/nature_02.png` | 36x64 |
| `game-assets/nature/trees/medium_pine_tree.png` | `assets/decorations/nature_03.png` | 40x76 |
| `game-assets/nature/trees/round_leaf_tree.png` | `assets/decorations/nature_04.png` | 58x73 |
| `game-assets/nature/trees/autumn_tree.png` | `assets/decorations/nature_05.png` | 65x74 |
| `game-assets/nature/trees/small_tree_stump.png` | `assets/decorations/nature_06.png` | 28x15 |
| `game-assets/nature/bushes/leafy_bush.png` | `assets/decorations/nature_07.png` | 64x48 |
| `game-assets/nature/bushes/pink_flower_bush.png` | `assets/decorations/nature_08.png` | 47x36 |
| `game-assets/nature/bushes/yellow_flower_bush.png` | `assets/decorations/nature_09.png` | 59x40 |
| `game-assets/nature/bushes/gray_rock_bush.png` | `assets/decorations/nature_10.png` | 45x29 |
| `game-assets/nature/flowers/yellow_flower_patch.png` | `assets/decorations/nature_11.png` | 48x30 |
| `game-assets/nature/flowers/tiny_flower_cluster.png` | `assets/decorations/nature_12.png` | 21x19 |
| `game-assets/nature/rocks/rock_cluster.png` | `assets/decorations/nature_13.png` | 32x27 |
| `game-assets/nature/bushes/small_leafy_patch.png` | `assets/decorations/nature_14.png` | 43x23 |
| `game-assets/nature/trees/log_pile.png` | `assets/decorations/nature_15.png` | 38x27 |
| `game-assets/nature/trees/firewood_stack.png` | `assets/decorations/nature_16.png` | 36x28 |
| `game-assets/nature/flowers/yellow_flower_bed.png` | `assets/decorations/nature_17.png` | 45x31 |
| `game-assets/nature/trees/tree_stump.png` | `assets/decorations/nature_18.png` | 50x37 |
| `game-assets/nature/flowers/purple_flower_patch.png` | `assets/decorations/nature_19.png` | 44x32 |
| `game-assets/decorations/signs/wooden_signpost.png` | `assets/decorations/nature_20.png` | 26x72 |
| `game-assets/decorations/lamps/lantern_post.png` | `assets/decorations/nature_21.png` | 15x70 |
| `game-assets/decorations/banners/purple_banner_lamp_post.png` | `assets/decorations/nature_22.png` | 21x70 |
| `game-assets/decorations/props/blue_fountain.png` | `assets/decorations/nature_23.png` | 46x68 |
| `game-assets/decorations/props/stone_guardian_statue.png` | `assets/decorations/nature_24.png` | 44x71 |
| `game-assets/decorations/containers/wooden_barrel.png` | `assets/decorations/nature_25.png` | 33x44 |
| `game-assets/decorations/containers/blue_supply_crate.png` | `assets/decorations/nature_26.png` | 28x29 |
| `game-assets/decorations/containers/brown_treasure_crate.png` | `assets/decorations/nature_27.png` | 27x29 |
| `game-assets/nature/rocks/small_rock_pile.png` | `assets/decorations/nature_28.png` | 30x22 |
| `game-assets/effects/magic/blue_magic_floor_decal.png` | `assets/decorations/nature_29.png` | 25x22 |
| `game-assets/effects/magic/blue_magic_floor_decal_variant.png` | `assets/decorations/nature_30.png` | 24x21 |
| `game-assets/decorations/banners/purple_hanging_banner.png` | `assets/landmarks/map-decor_00.png` | 47x92 |
| `game-assets/decorations/banners/blue_hanging_banner.png` | `assets/landmarks/map-decor_01.png` | 46x91 |
| `game-assets/decorations/lamps/black_lantern_post.png` | `assets/landmarks/map-decor_02.png` | 28x85 |
| `game-assets/decorations/lamps/gold_lantern_post.png` | `assets/landmarks/map-decor_03.png` | 24x90 |
| `game-assets/decorations/signs/direction_signpost.png` | `assets/landmarks/map-decor_04.png` | 28x82 |
| `game-assets/decorations/signs/wooden_wayfinding_sign.png` | `assets/landmarks/map-decor_05.png` | 52x76 |
| `game-assets/decorations/fences/wooden_gate.png` | `assets/landmarks/map-decor_06.png` | 53x73 |
| `game-assets/decorations/props/stone_floor_platform.png` | `assets/landmarks/map-decor_07.png` | 95x81 |
| `game-assets/decorations/props/broken_stone_wall.png` | `assets/landmarks/map-decor_08.png` | 97x83 |
| `game-assets/decorations/props/stone_pillar.png` | `assets/landmarks/map-decor_09.png` | 38x80 |
| `game-assets/decorations/props/central_fountain.png` | `assets/landmarks/map-decor_10.png` | 172x162 |
| `game-assets/reference/backgrounds/sky_cloud_background.png` | `assets/maps/background.png` | 1024x682 |
| `game-assets/player/idle/arcanist_idle_front_01.png` | `assets/sprites/player/player_00.png` | 39x66 |
| `game-assets/player/idle/arcanist_idle_front_02.png` | `assets/sprites/player/player_01.png` | 38x67 |
| `game-assets/player/idle/arcanist_idle_front_03.png` | `assets/sprites/player/player_02.png` | 37x67 |
| `game-assets/player/idle/arcanist_idle_back_01.png` | `assets/sprites/player/player_03.png` | 39x66 |
| `game-assets/player/idle/arcanist_idle_back_02.png` | `assets/sprites/player/player_04.png` | 38x66 |
| `game-assets/player/walk/arcanist_walk_left_01.png` | `assets/sprites/player/player_05.png` | 41x64 |
| `game-assets/player/walk/arcanist_walk_left_02.png` | `assets/sprites/player/player_06.png` | 41x64 |
| `game-assets/player/walk/arcanist_walk_right_01.png` | `assets/sprites/player/player_07.png` | 42x64 |
| `game-assets/player/walk/arcanist_walk_right_02.png` | `assets/sprites/player/player_08.png` | 41x64 |
| `game-assets/player/walk/arcanist_walk_back.png` | `assets/sprites/player/player_09.png` | 38x64 |
| `game-assets/player/cast/arcanist_cast_front_start.png` | `assets/sprites/player/player_10.png` | 51x68 |
| `game-assets/player/cast/arcanist_cast_front_release.png` | `assets/sprites/player/player_11.png` | 53x68 |
| `game-assets/player/cast/arcanist_cast_side_charge.png` | `assets/sprites/player/player_12.png` | 41x67 |
| `game-assets/player/cast/arcanist_cast_side_step.png` | `assets/sprites/player/player_13.png` | 41x67 |
| `game-assets/player/cast/arcanist_cast_side_projectile.png` | `assets/sprites/player/player_14.png` | 61x66 |

## Same-Object Quality Variants

These groups contain base and `_2x` versions of the same object. Keep the highest-resolution `_2x` version for production use; archive lower-resolution siblings if the game no longer needs them for memory/performance targets.

| Recommended | Archive Candidates |
|---|---|
| `game-assets/buildings/alchemy_lab_2x.png` (390x286) | `game-assets/buildings/alchemy_lab.png` (195x143) |
| `game-assets/buildings/astronomy_tower_2x.png` (230x392) | `game-assets/buildings/astronomy_tower.png` (115x196) |
| `game-assets/buildings/coding_tower_2x.png` (324x294) | `game-assets/buildings/coding_tower.png` (162x147) |
| `game-assets/buildings/duel_arena_2x.png` (358x258) | `game-assets/buildings/duel_arena.png` (179x129) |
| `game-assets/buildings/grand_hall_2x.png` (400x392) | `game-assets/buildings/grand_hall.png` (200x196) |
| `game-assets/buildings/history_hall_2x.png` (298x228) | `game-assets/buildings/history_hall.png` (149x114) |
| `game-assets/buildings/library_2x.png` (336x320) | `game-assets/buildings/library.png` (168x160) |
| `game-assets/decorations/banners/blue_hanging_banner_2x.png` (92x182) | `game-assets/decorations/banners/blue_hanging_banner.png` (46x91) |
| `game-assets/decorations/banners/gold_banner_post_2x.png` (42x144) | `game-assets/decorations/banners/gold_banner_post.png` (21x72) |
| `game-assets/decorations/banners/gold_flag_post_2x.png` (50x140) | `game-assets/decorations/banners/gold_flag_post.png` (25x70) |
| `game-assets/decorations/banners/purple_banner_lamp_post_2x.png` (42x140) | `game-assets/decorations/banners/purple_banner_lamp_post.png` (21x70) |
| `game-assets/decorations/banners/purple_hanging_banner_2x.png` (94x184) | `game-assets/decorations/banners/tile_purple_hanging_banner_2x.png` (78x144)<br>`game-assets/decorations/banners/purple_hanging_banner.png` (47x92)<br>`game-assets/decorations/banners/tile_purple_hanging_banner.png` (39x72) |
| `game-assets/decorations/banners/purple_vertical_banner_2x.png` (50x146) | `game-assets/decorations/banners/purple_vertical_banner.png` (25x73) |
| `game-assets/decorations/containers/blue_cauldron_2x.png` (84x82) | `game-assets/decorations/containers/blue_cauldron.png` (42x41) |
| `game-assets/decorations/containers/blue_supply_crate_2x.png` (56x58) | `game-assets/decorations/containers/blue_supply_crate.png` (28x29) |
| `game-assets/decorations/containers/brown_treasure_crate_2x.png` (54x58) | `game-assets/decorations/containers/brown_treasure_crate.png` (27x29) |
| `game-assets/decorations/containers/dark_metal_barrel_2x.png` (58x88) | `game-assets/decorations/containers/dark_metal_barrel.png` (29x44) |
| `game-assets/decorations/containers/green_liquid_barrel_2x.png` (52x90) | `game-assets/decorations/containers/green_liquid_barrel.png` (26x45) |
| `game-assets/decorations/containers/stone_barrel_2x.png` (58x86) | `game-assets/decorations/containers/stone_barrel.png` (29x43) |
| `game-assets/decorations/containers/wooden_barrel_2x_tiles.png` (64x102) | `game-assets/decorations/containers/wooden_barrel_2x.png` (66x88)<br>`game-assets/decorations/containers/wooden_barrel_tiles.png` (32x51)<br>`game-assets/decorations/containers/wooden_barrel.png` (33x44) |
| `game-assets/decorations/fences/wooden_gate_2x.png` (106x146) | `game-assets/decorations/fences/wooden_gate.png` (53x73) |
| `game-assets/decorations/lamps/black_lantern_post_2x.png` (56x170) | `game-assets/decorations/lamps/black_lantern_post.png` (28x85) |
| `game-assets/decorations/lamps/gold_lantern_post_2x.png` (48x180) | `game-assets/decorations/lamps/gold_lantern_post.png` (24x90) |
| `game-assets/decorations/lamps/lantern_post_2x.png` (30x140) | `game-assets/decorations/lamps/lantern_post.png` (15x70) |
| `game-assets/decorations/lamps/stone_lantern_2x.png` (58x106) | `game-assets/decorations/lamps/stone_lantern.png` (29x53) |
| `game-assets/decorations/props/blue_fountain_2x.png` (92x136) | `game-assets/decorations/props/blue_fountain.png` (46x68) |
| `game-assets/decorations/props/broken_stone_wall_2x.png` (194x166) | `game-assets/decorations/props/broken_stone_wall.png` (97x83) |
| `game-assets/decorations/props/central_fountain_2x.png` (344x324) | `game-assets/decorations/props/central_fountain.png` (172x162) |
| `game-assets/decorations/props/stone_floor_platform_2x.png` (190x162) | `game-assets/decorations/props/stone_floor_platform.png` (95x81) |
| `game-assets/decorations/props/stone_guardian_statue_2x.png` (88x142) | `game-assets/decorations/props/stone_guardian_statue.png` (44x71) |
| `game-assets/decorations/props/stone_pillar_2x.png` (76x160) | `game-assets/decorations/props/stone_pillar.png` (38x80) |
| `game-assets/decorations/props/stone_well_2x.png` (106x108) | `game-assets/decorations/props/stone_well.png` (53x54) |
| `game-assets/decorations/signs/direction_signpost_2x.png` (56x164) | `game-assets/decorations/signs/direction_signpost.png` (28x82) |
| `game-assets/decorations/signs/hanging_sign_frame_2x.png` (72x78) | `game-assets/decorations/signs/hanging_sign_frame.png` (36x39) |
| `game-assets/decorations/signs/shield_signpost_2x.png` (42x74) | `game-assets/decorations/signs/shield_signpost.png` (21x37) |
| `game-assets/decorations/signs/small_signpost_2x.png` (40x76) | `game-assets/decorations/signs/small_signpost.png` (20x38) |
| `game-assets/decorations/signs/square_signpost_2x.png` (44x76) | `game-assets/decorations/signs/square_signpost.png` (22x38) |
| `game-assets/decorations/signs/tiny_shield_marker_2x.png` (42x76) | `game-assets/decorations/signs/tiny_shield_marker.png` (21x38) |
| `game-assets/decorations/signs/wooden_signpost_2x.png` (52x144) | `game-assets/decorations/signs/wooden_signpost.png` (26x72) |
| `game-assets/decorations/signs/wooden_wayfinding_sign_2x.png` (104x152) | `game-assets/decorations/signs/wooden_wayfinding_sign.png` (52x76) |
| `game-assets/effects/magic/blue_ice_spike_2x.png` (92x122) | `game-assets/effects/magic/blue_ice_spike.png` (46x61) |
| `game-assets/effects/magic/blue_magic_floor_decal_2x.png` (50x44) | `game-assets/effects/magic/blue_magic_floor_decal.png` (25x22) |
| `game-assets/effects/magic/blue_magic_floor_decal_variant_2x.png` (48x42) | `game-assets/effects/magic/blue_magic_floor_decal_variant.png` (24x21) |
| `game-assets/effects/magic/blue_magic_spark_2x.png` (42x54) | `game-assets/effects/magic/blue_magic_spark.png` (21x27) |
| `game-assets/effects/magic/blue_starburst_2x.png` (94x100) | `game-assets/effects/magic/blue_starburst.png` (47x50) |
| `game-assets/effects/magic/purple_magic_circle_2x.png` (188x174) | `game-assets/effects/magic/purple_magic_circle.png` (94x87) |
| `game-assets/effects/magic/violet_starburst_2x.png` (74x90) | `game-assets/effects/magic/violet_starburst.png` (37x45) |
| `game-assets/effects/particles/brown_dust_spark_2x.png` (78x84) | `game-assets/effects/particles/brown_dust_spark.png` (39x42) |
| `game-assets/effects/particles/gold_sparkle_cluster_2x.png` (74x86) | `game-assets/effects/particles/gold_sparkle_cluster.png` (37x43) |
| `game-assets/effects/particles/golden_burst_2x.png` (54x56) | `game-assets/effects/particles/golden_burst.png` (27x28) |
| `game-assets/effects/particles/purple_sparkle_cluster_2x.png` (120x84) | `game-assets/effects/particles/purple_sparkle_cluster.png` (60x42) |
| `game-assets/effects/particles/small_purple_spark_2x.png` (28x26) | `game-assets/effects/particles/small_purple_spark.png` (14x13) |
| `game-assets/effects/particles/tiny_gold_spark_2x.png` (14x16) | `game-assets/effects/particles/tiny_gold_spark.png` (7x8) |
| `game-assets/effects/particles/tiny_purple_spark_2x.png` (28x30) | `game-assets/effects/particles/tiny_purple_spark.png` (14x15) |
| `game-assets/effects/particles/tiny_white_spark_2x.png` (12x16) | `game-assets/effects/particles/tiny_white_spark.png` (6x8) |
| `game-assets/effects/particles/white_light_spark_2x.png` (66x86) | `game-assets/effects/particles/white_light_spark.png` (33x43) |
| `game-assets/effects/smoke/smoke_puff_2x.png` (86x108) | `game-assets/effects/smoke/smoke_puff.png` (43x54) |
| `game-assets/nature/bushes/gray_rock_bush_2x.png` (90x58) | `game-assets/nature/bushes/gray_rock_bush.png` (45x29) |
| `game-assets/nature/bushes/leafy_bush_2x.png` (128x96) | `game-assets/nature/bushes/leafy_bush.png` (64x48) |
| `game-assets/nature/bushes/pink_flower_bush_2x.png` (94x72) | `game-assets/nature/bushes/pink_flower_bush.png` (47x36) |
| `game-assets/nature/bushes/small_leafy_patch_2x.png` (86x46) | `game-assets/nature/bushes/small_leafy_patch.png` (43x23) |
| `game-assets/nature/bushes/yellow_flower_bush_2x.png` (118x80) | `game-assets/nature/bushes/yellow_flower_bush.png` (59x40) |
| `game-assets/nature/flowers/flower_cliff_column_2x.png` (106x182) | `game-assets/nature/flowers/flower_cliff_column.png` (53x91) |
| `game-assets/nature/flowers/flower_grass_mound_2x.png` (94x94) | `game-assets/nature/flowers/flower_grass_mound.png` (47x47) |
| `game-assets/nature/flowers/pink_flower_grass_tile_2x.png` (110x104) | `game-assets/nature/flowers/pink_flower_grass_tile.png` (55x52) |
| `game-assets/nature/flowers/pink_flower_patch_2x.png` (84x76) | `game-assets/nature/flowers/pink_flower_patch.png` (42x38) |
| `game-assets/nature/flowers/purple_flower_grass_tile_2x.png` (110x104) | `game-assets/nature/flowers/purple_flower_grass_tile.png` (55x52) |
| `game-assets/nature/flowers/purple_flower_patch_2x.png` (88x64) | `game-assets/nature/flowers/purple_flower_patch.png` (44x32) |
| `game-assets/nature/flowers/tiny_flower_cluster_2x.png` (42x38) | `game-assets/nature/flowers/tiny_flower_cluster.png` (21x19) |
| `game-assets/nature/flowers/tiny_ground_sprout_2x.png` (32x20) | `game-assets/nature/flowers/tiny_ground_sprout.png` (16x10) |
| `game-assets/nature/flowers/white_flower_grass_tile_2x.png` (108x106) | `game-assets/nature/flowers/white_flower_grass_tile.png` (54x53) |
| `game-assets/nature/flowers/yellow_flower_bed_2x.png` (90x62) | `game-assets/nature/flowers/yellow_flower_bed.png` (45x31) |
| `game-assets/nature/flowers/yellow_flower_patch_2x.png` (96x60) | `game-assets/nature/flowers/yellow_flower_patch.png` (48x30) |
| `game-assets/nature/flowers/yellow_flower_shrub_2x.png` (82x62) | `game-assets/nature/flowers/yellow_flower_shrub.png` (41x31) |
| `game-assets/nature/rocks/rock_cluster_2x.png` (64x54) | `game-assets/nature/rocks/rock_cluster.png` (32x27) |
| `game-assets/nature/rocks/small_rock_pile_2x.png` (60x44) | `game-assets/nature/rocks/small_rock_pile.png` (30x22) |
| `game-assets/nature/trees/autumn_tree_2x.png` (130x148) | `game-assets/nature/trees/autumn_tree.png` (65x74) |
| `game-assets/nature/trees/broadleaf_tree_2x.png` (138x144) | `game-assets/nature/trees/broadleaf_tree.png` (69x72) |
| `game-assets/nature/trees/enchanted_forest_tree_2x.png` (350x292) | `game-assets/nature/trees/enchanted_forest_tree.png` (175x146) |
| `game-assets/nature/trees/firewood_stack_2x.png` (72x56) | `game-assets/nature/trees/firewood_stack.png` (36x28) |
| `game-assets/nature/trees/log_pile_2x.png` (76x54) | `game-assets/nature/trees/log_pile.png` (38x27) |
| `game-assets/nature/trees/medium_pine_tree_2x.png` (80x152) | `game-assets/nature/trees/medium_pine_tree.png` (40x76) |
| `game-assets/nature/trees/round_leaf_tree_2x.png` (116x146) | `game-assets/nature/trees/round_leaf_tree.png` (58x73) |
| `game-assets/nature/trees/round_tree_2x.png` (120x154) | `game-assets/nature/trees/round_tree.png` (60x77) |
| `game-assets/nature/trees/small_broadleaf_tree_2x.png` (118x152) | `game-assets/nature/trees/small_broadleaf_tree.png` (59x76) |
| `game-assets/nature/trees/small_pine_tree_2x_tiles.png` (106x196) | `game-assets/nature/trees/small_pine_tree_2x.png` (72x128)<br>`game-assets/nature/trees/small_pine_tree_tiles.png` (53x98)<br>`game-assets/nature/trees/small_pine_tree.png` (36x64) |
| `game-assets/nature/trees/small_sapling_2x.png` (54x50) | `game-assets/nature/trees/small_sapling.png` (27x25) |
| `game-assets/nature/trees/small_tree_stump_2x.png` (56x30) | `game-assets/nature/trees/small_tree_stump.png` (28x15) |
| `game-assets/nature/trees/tall_pine_tree_2x.png` (84x150) | `game-assets/nature/trees/tall_pine_tree.png` (42x75) |
| `game-assets/nature/trees/tree_stump_2x.png` (100x74) | `game-assets/nature/trees/tree_stump.png` (50x37) |
| `game-assets/npc/guard_npc_2x.png` (128x198) | `game-assets/npc/guard_npc.png` (64x99) |
| `game-assets/npc/librarian_npc_2x.png` (94x176) | `game-assets/npc/librarian_npc.png` (47x88) |
| `game-assets/npc/professor_npc_2x.png` (120x202) | `game-assets/npc/professor_npc.png` (60x101) |
| `game-assets/npc/student_npc_2x.png` (86x166) | `game-assets/npc/student_npc.png` (43x83) |
| `game-assets/player/cast/arcanist_cast_front_release_2x.png` (106x136) | `game-assets/player/cast/arcanist_cast_front_release.png` (53x68) |
| `game-assets/player/cast/arcanist_cast_front_start_2x.png` (102x136) | `game-assets/player/cast/arcanist_cast_front_start.png` (51x68) |
| `game-assets/player/cast/arcanist_cast_side_charge_2x.png` (82x134) | `game-assets/player/cast/arcanist_cast_side_charge.png` (41x67) |
| `game-assets/player/cast/arcanist_cast_side_projectile_2x.png` (122x132) | `game-assets/player/cast/arcanist_cast_side_projectile.png` (61x66) |
| `game-assets/player/cast/arcanist_cast_side_step_2x.png` (82x134) | `game-assets/player/cast/arcanist_cast_side_step.png` (41x67) |
| `game-assets/player/idle/arcanist_idle_back_01_2x.png` (78x132) | `game-assets/player/idle/arcanist_idle_back_01.png` (39x66) |
| `game-assets/player/idle/arcanist_idle_back_02_2x.png` (76x132) | `game-assets/player/idle/arcanist_idle_back_02.png` (38x66) |
| `game-assets/player/idle/arcanist_idle_front_01_2x.png` (78x132) | `game-assets/player/idle/arcanist_idle_front_01.png` (39x66) |
| `game-assets/player/idle/arcanist_idle_front_02_2x.png` (76x134) | `game-assets/player/idle/arcanist_idle_front_02.png` (38x67) |
| `game-assets/player/idle/arcanist_idle_front_03_2x.png` (74x134) | `game-assets/player/idle/arcanist_idle_front_03.png` (37x67) |
| `game-assets/player/walk/arcanist_walk_back_2x.png` (76x128) | `game-assets/player/walk/arcanist_walk_back.png` (38x64) |
| `game-assets/player/walk/arcanist_walk_left_01_2x.png` (82x128) | `game-assets/player/walk/arcanist_walk_left_01.png` (41x64) |
| `game-assets/player/walk/arcanist_walk_left_02_2x.png` (82x128) | `game-assets/player/walk/arcanist_walk_left_02.png` (41x64) |
| `game-assets/player/walk/arcanist_walk_right_01_2x.png` (84x128) | `game-assets/player/walk/arcanist_walk_right_01.png` (42x64) |
| `game-assets/player/walk/arcanist_walk_right_02_2x.png` (82x128) | `game-assets/player/walk/arcanist_walk_right_02.png` (41x64) |
| `game-assets/tiles/cliffs/grass_cliff_column_2x.png` (96x144) | `game-assets/tiles/cliffs/grass_cliff_column.png` (48x72) |
| `game-assets/tiles/cliffs/leafy_cliff_column_2x.png` (102x186) | `game-assets/tiles/cliffs/leafy_cliff_column.png` (51x93) |
| `game-assets/tiles/cliffs/tall_grass_cliff_chunk_2x.png` (98x158) | `game-assets/tiles/cliffs/tall_grass_cliff_chunk.png` (49x79) |
| `game-assets/tiles/grass/blue_gold_trim_tile_2x.png` (92x98) | `game-assets/tiles/grass/blue_gold_trim_tile.png` (46x49) |
| `game-assets/tiles/grass/clover_grass_tile_2x.png` (108x104) | `game-assets/tiles/grass/clover_grass_tile.png` (54x52) |
| `game-assets/tiles/grass/gold_flecked_blue_tile_2x.png` (104x144) | `game-assets/tiles/grass/gold_flecked_blue_tile.png` (52x72) |
| `game-assets/tiles/grass/grass_mound_2x.png` (110x84) | `game-assets/tiles/grass/grass_mound.png` (55x42) |
| `game-assets/tiles/grass/grass_tile_2x.png` (108x102) | `game-assets/tiles/grass/grass_tile.png` (54x51) |
| `game-assets/tiles/grass/grass_with_stones_tile_2x.png` (110x106) | `game-assets/tiles/grass/grass_with_stones_tile.png` (55x53) |
| `game-assets/tiles/grass/leafy_ground_tile_2x.png` (102x104) | `game-assets/tiles/grass/leafy_ground_tile.png` (51x52) |
| `game-assets/tiles/grass/purple_crystal_ground_tile_2x.png` (110x104) | `game-assets/tiles/grass/purple_crystal_ground_tile.png` (55x52) |
| `game-assets/tiles/grass/purple_crystal_ore_tile_2x.png` (94x96) | `game-assets/tiles/grass/purple_crystal_ore_tile.png` (47x48) |
| `game-assets/tiles/roads/cobblestone_tile_2x.png` (112x104) | `game-assets/tiles/roads/cobblestone_tile.png` (56x52) |
| `game-assets/tiles/roads/dark_wood_plank_tile_2x.png` (106x102) | `game-assets/tiles/roads/dark_wood_plank_tile.png` (53x51) |
| `game-assets/tiles/roads/dirt_path_tile_2x.png` (108x102) | `game-assets/tiles/roads/dirt_path_tile.png` (54x51) |
| `game-assets/tiles/roads/stone_path_tile_2x.png` (110x104) | `game-assets/tiles/roads/stone_path_tile.png` (55x52) |
| `game-assets/tiles/roads/wood_plank_tile_2x.png` (112x102) | `game-assets/tiles/roads/wood_plank_tile.png` (56x51) |
| `game-assets/tiles/water/blue_magic_water_tile_2x.png` (112x108) | `game-assets/tiles/water/blue_magic_water_tile.png` (56x54) |
| `game-assets/tiles/water/blue_pond_tile_2x.png` (104x88) | `game-assets/tiles/water/blue_pond_tile.png` (52x44) |
| `game-assets/tiles/water/grass_cliff_waterfall_edge_2x.png` (122x236) | `game-assets/tiles/water/grass_cliff_waterfall_edge.png` (61x118) |
| `game-assets/tiles/water/narrow_waterfall_segment_2x.png` (118x234) | `game-assets/tiles/water/narrow_waterfall_segment.png` (59x117) |
| `game-assets/tiles/water/wide_waterfall_segment_2x.png` (124x236) | `game-assets/tiles/water/wide_waterfall_segment.png` (62x118) |
| `game-assets/ui/buttons/close_button_2x.png` (212x76) | `game-assets/ui/buttons/close_button.png` (106x38) |
| `game-assets/ui/buttons/inventory_tab_button_2x.png` (114x84) | `game-assets/ui/buttons/inventory_tab_button.png` (57x42) |
| `game-assets/ui/buttons/learn_button_2x.png` (206x78) | `game-assets/ui/buttons/learn_button.png` (103x39) |
| `game-assets/ui/buttons/map_tab_button_2x.png` (116x86) | `game-assets/ui/buttons/map_tab_button.png` (58x43) |
| `game-assets/ui/buttons/plus_button_2x.png` (64x60) | `game-assets/ui/buttons/plus_button.png` (32x30) |
| `game-assets/ui/buttons/settings_button_2x.png` (116x84) | `game-assets/ui/buttons/settings_button.png` (58x42) |
| `game-assets/ui/buttons/social_tab_button_2x.png` (114x84) | `game-assets/ui/buttons/social_tab_button.png` (57x42) |
| `game-assets/ui/buttons/trophy_tab_button_2x.png` (118x84) | `game-assets/ui/buttons/trophy_tab_button.png` (59x42) |
| `game-assets/ui/buttons/upgrade_button_2x.png` (204x78) | `game-assets/ui/buttons/upgrade_button.png` (102x39) |
| `game-assets/ui/hud/coin_counter_2x.png` (288x78) | `game-assets/ui/hud/coin_counter.png` (144x39) |
| `game-assets/ui/hud/energy_bar_2x.png` (496x60) | `game-assets/ui/hud/energy_bar.png` (248x30) |
| `game-assets/ui/hud/gem_counter_2x.png` (226x74) | `game-assets/ui/hud/gem_counter.png` (113x37) |
| `game-assets/ui/hud/health_bar_2x.png` (500x50) | `game-assets/ui/hud/health_bar.png` (250x25) |
| `game-assets/ui/hud/xp_bar_2x.png` (502x54) | `game-assets/ui/hud/xp_bar.png` (251x27) |
| `game-assets/ui/icons/armored_statue_icon_2x.png` (70x72) | `game-assets/ui/icons/armored_statue_icon.png` (35x36) |
| `game-assets/ui/icons/blue_diamond_gem_icon_2x.png` (62x70) | `game-assets/ui/icons/blue_diamond_gem_icon.png` (31x35) |
| `game-assets/ui/icons/blue_potion_icon_2x.png` (62x76) | `game-assets/ui/icons/blue_potion_icon.png` (31x38) |
| `game-assets/ui/icons/crossed_swords_icon_2x.png` (66x70) | `game-assets/ui/icons/crossed_swords_icon.png` (33x35) |
| `game-assets/ui/icons/gold_amulet_icon_2x.png` (50x66) | `game-assets/ui/icons/gold_amulet_icon.png` (25x33) |
| `game-assets/ui/icons/gold_chandelier_icon_2x.png` (64x68) | `game-assets/ui/icons/gold_chandelier_icon.png` (32x34) |
| `game-assets/ui/icons/golden_bell_icon_2x.png` (66x66) | `game-assets/ui/icons/golden_bell_icon.png` (33x33) |
| `game-assets/ui/icons/golden_star_badge_icon_2x.png` (70x70) | `game-assets/ui/icons/golden_star_badge_icon.png` (35x35) |
| `game-assets/ui/icons/golden_sun_orb_icon_2x.png` (62x68) | `game-assets/ui/icons/golden_sun_orb_icon.png` (31x34) |
| `game-assets/ui/icons/interaction_exclamation_speech_bubble_2x.png` (156x138) | `game-assets/ui/icons/interaction_exclamation_speech_bubble.png` (78x69) |
| `game-assets/ui/icons/magic_compass_icon_2x.png` (62x64) | `game-assets/ui/icons/magic_compass_icon.png` (31x32) |
| `game-assets/ui/icons/purple_crystal_cluster_icon_2x.png` (64x70) | `game-assets/ui/icons/purple_crystal_cluster_icon.png` (32x35) |
| `game-assets/ui/icons/purple_gem_icon_2x.png` (62x62) | `game-assets/ui/icons/purple_gem_icon.png` (31x31) |
| `game-assets/ui/icons/purple_potion_icon_2x.png` (62x74) | `game-assets/ui/icons/purple_potion_icon.png` (31x37) |
| `game-assets/ui/icons/quest_scroll_icon_2x.png` (68x70) | `game-assets/ui/icons/quest_scroll_icon.png` (34x35) |
| `game-assets/ui/icons/red_spellbook_icon_2x.png` (62x64) | `game-assets/ui/icons/red_spellbook_icon.png` (31x32) |
| `game-assets/ui/icons/round_drum_icon_2x.png` (60x66) | `game-assets/ui/icons/round_drum_icon.png` (30x33) |
| `game-assets/ui/icons/sealed_envelope_icon_2x.png` (70x64) | `game-assets/ui/icons/sealed_envelope_icon.png` (35x32) |
| `game-assets/ui/icons/shield_badge_icon_2x.png` (58x68) | `game-assets/ui/icons/shield_badge_icon.png` (29x34) |
| `game-assets/ui/icons/spellbook_icon_2x.png` (72x72) | `game-assets/ui/icons/spellbook_icon.png` (36x36) |
| `game-assets/ui/icons/stone_resource_pile_icon_2x.png` (64x54) | `game-assets/ui/icons/stone_resource_pile_icon.png` (32x27) |
| `game-assets/ui/icons/sword_icon_2x.png` (70x72) | `game-assets/ui/icons/sword_icon.png` (35x36) |
| `game-assets/ui/icons/treasure_chest_icon_2x.png` (70x58) | `game-assets/ui/icons/treasure_chest_icon.png` (35x29) |
| `game-assets/ui/icons/trophy_cup_icon_2x.png` (76x74) | `game-assets/ui/icons/trophy_cup_icon.png` (38x37) |
| `game-assets/ui/icons/wooden_crate_icon_2x.png` (60x68) | `game-assets/ui/icons/wooden_crate_icon.png` (30x34) |
| `game-assets/ui/panels/coding_tower_lesson_panel_2x.png` (678x466) | `game-assets/ui/panels/coding_tower_lesson_panel.png` (339x233) |
| `game-assets/ui/panels/professor_dialogue_panel_2x.png` (648x234) | `game-assets/ui/panels/professor_dialogue_panel.png` (324x117) |
| `game-assets/ui/panels/quest_completed_panel_2x.png` (636x236) | `game-assets/ui/panels/quest_completed_panel.png` (318x118) |
| `game-assets/ui/panels/ui_panel_border_slice_2x.png` (20x578) | `game-assets/ui/panels/ui_panel_border_slice.png` (10x289) |

## Exact Duplicates To Keep For Now

These are byte-identical but likely intentional animation/status duplicates. Do not archive until animation timing or UI-state behavior is reviewed.

| Group | Files |
|---|---|
| Intentional/review | `assets/sprites/player/idle/wizard_idle_ne_00.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_ne_03.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_ne_01.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_ne_02.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_ne_04.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_ne_05.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_nw_00.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_nw_03.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_nw_01.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_nw_02.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_nw_04.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_nw_05.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_se_00.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_se_03.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_se_01.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_se_02.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_se_04.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_se_05.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_sw_00.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_sw_03.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_sw_01.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_sw_02.png` (96x128) |
| Intentional/review | `assets/sprites/player/idle/wizard_idle_sw_04.png` (96x128)<br>`assets/sprites/player/idle/wizard_idle_sw_05.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_ne_00.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_ne_04.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_ne_01.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_ne_03.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_ne_05.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_ne_07.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_nw_00.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_nw_04.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_nw_01.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_nw_03.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_nw_05.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_nw_07.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_se_00.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_se_04.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_se_01.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_se_03.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_se_05.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_se_07.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_sw_00.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_sw_04.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_sw_01.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_sw_03.png` (96x128) |
| Intentional/review | `assets/sprites/player/walk/wizard_walk_sw_05.png` (96x128)<br>`assets/sprites/player/walk/wizard_walk_sw_07.png` (96x128) |
| Intentional/review | `assets/ui/coins/coin_01.png` (64x64)<br>`assets/ui/coins/coin_07.png` (64x64) |
| Intentional/review | `assets/ui/coins/coin_02.png` (64x64)<br>`assets/ui/coins/coin_06.png` (64x64) |
| Intentional/review | `assets/ui/coins/coin_03.png` (64x64)<br>`assets/ui/coins/coin_05.png` (64x64) |

## Other Exact Duplicates Requiring Design Review

These are exact duplicates but not simple cross-tree duplicates. Keep one only if the duplicate semantic names are not required by code/UI state names.

| Recommended Keep | Archive/Review Candidates |
|---|---|
| `assets/ui/buttons/btn_gold_disabled.png` (192x64) | `assets/ui/buttons/btn_primary_disabled.png` (192x64)<br>`assets/ui/buttons/btn_secondary_disabled.png` (192x64) |
