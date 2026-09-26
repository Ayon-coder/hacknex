# Hexafalls Asset Pipeline Audit
Scope: every PNG currently inside `game-assets/`. Gameplay and Flutter source code were not modified.
## Outputs
- `game-assets/assets_manifest.json` and root `assets_manifest.json`: complete structured manifest.
- `game-assets/AssetManager.dart` and `game-assets/generated/AssetManager.dart`: generated Dart constants, not imported by gameplay.
- `academy_layout.json`: regenerated reference-layout placement metadata.
- `asset_pipeline_contact_sheets/`: visual contact sheets by category.

## Summary
- Images analyzed: 356
- Exact duplicate groups inside `game-assets`: 0
- Base/2x variant groups: 177
- Missing or partial expected academy assets: 8

## Organization
- `buildings/`: 14 images
- `decorations/`: 70 images
- `effects/`: 34 images
- `nature/`: 68 images
- `npc/`: 8 images
- `player/`: 30 images
- `reference/`: 2 images
- `tiles/`: 44 images
- `ui/`: 86 images

## Rename Actions
- `decorations/banners/tile_purple_hanging_banner.png` -> `decorations/banners/short_purple_hanging_banner.png`
- `decorations/banners/tile_purple_hanging_banner_2x.png` -> `decorations/banners/short_purple_hanging_banner_2x.png`
- `decorations/containers/wooden_barrel_tiles.png` -> `decorations/containers/tall_wooden_barrel.png`
- `decorations/containers/wooden_barrel_2x_tiles.png` -> `decorations/containers/tall_wooden_barrel_2x.png`
- `nature/trees/small_pine_tree_tiles.png` -> `nature/trees/full_pine_tree.png`
- `nature/trees/small_pine_tree_2x_tiles.png` -> `nature/trees/full_pine_tree_2x.png`

All remaining numbered suffixes are animation frame or quality suffixes and should stay.

## Duplicate Findings
- No exact duplicate PNGs remain inside `game-assets`.

## Missing Assets
- `bench_set` (missing): Benches are visible/useful around plaza and academy paths; folder exists but has no PNGs. Recommended folder: `decorations/benches`.
- `stone_stairs_tiles` (missing): Reference uses several stair runs; current library has paths but no dedicated stair tile slices. Recommended folder: `tiles/roads`.
- `path_corner_and_junction_tiles` (missing): Radial path network needs clean corners, T-junctions, and intersections. Recommended folder: `tiles/roads`.
- `wooden_fence_segments` (missing): Only a gate is present; fenced yards need straight, corner, and end-cap pieces. Recommended folder: `decorations/fences`.
- `cliff_edge_corner_tiles` (partial): Floating island silhouette needs corner and transition cliff pieces. Recommended folder: `tiles/cliffs`.
- `waterfall_splash_foam` (missing): Waterfalls need base splash/foam effects to match the reference. Recommended folder: `effects/particles`.
- `building_label_signboards` (missing): Reference has black/gold building labels; current UI panels do not include world label plates. Recommended folder: `ui/panels or decorations/signs`.
- `grand_hall_stair_banners` (partial): Entrance stairs need paired vertical banners sized for south gate and Grand Hall stairs. Recommended folder: `decorations/banners`.

## Academy Reference Comparison
- The available building set matches the reference core: Grand Hall, Library, Astronomy Tower, Duel Arena, Alchemy Lab, History Hall, Coding Tower, Central Plaza/Fountain, and Enchanted Forest tree.
- The strongest final-game assets are the `_2x` versions for buildings, props, terrain, UI, NPCs, and player frames. Base assets should be retained as low-memory fallbacks or archived after integration.
- The largest visual gaps versus the reference are stair/path transition tiles, benches, fence segments, cliff corner pieces, water splash/foam, and world label signboards.

## Final Game Use
- Use `_2x` building assets for all major academy landmarks.
- Use `central_fountain_2x`, `stone_path_tile_2x`, `cobblestone_tile_2x`, and `purple_vertical_banner_2x` to anchor the Central Plaza.
- Use `enchanted_forest_tree_2x`, purple crystal ground tiles, and blue/purple magic effects for the Enchanted Forest and Coding Tower area.
- Keep UI, player, and NPC frame sequences intact; do not dedupe animation frames by filename pattern alone.

## Notes
- No PNG pixel data was recompressed or rewritten except generated contact-sheet JPGs.
- No gameplay files or Flutter source files under `lib/` were changed.
