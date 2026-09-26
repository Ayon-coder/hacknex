import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';

import '../../config/asset_paths.dart';
import '../buildings/building_component.dart';
import '../buildings/sample_building_data.dart';
import '../managers/asset_manager.dart';
import '../managers/game_state.dart';
import '../managers/game_state_manager.dart';
import '../pathfinding/a_star_pathfinder.dart';
import '../pathfinding/navigation_grid.dart';
import '../player/player.dart';
import '../player/player_animation_controller.dart';
import '../player/player_animation_state.dart';
import 'ambient_particles_component.dart';
import 'decorations/decoration_component.dart';
import 'decorations/decoration_manager.dart';
import 'world_background_component.dart';

/// WorldMap — Handcrafted single floating island academy hub:
/// - One floating island canvas (1600 x 1100)
/// - Central circular plaza with magical fountain at (800, 520)
/// - Buildings arranged around plaza: North (Grand Hall), NW (Library),
///   NE (Astronomy Tower), W (Arena), SW (Potion Lab), SE (Coding Tower)
/// - Player spawn: Bottom center (800, 840)
/// - Handcrafted stone paths & structured decoration layering (Building -> Trees -> Bushes -> Flowers -> Lamp -> Fence)
/// - Blue Magical Tap Trail along A* road path waypoints
/// - Pinch-to-zoom (0.8x to 1.6x) and Double Tap Zoom Reset to 1.0x
/// - Deferred Building Panel opening: UI opens ONLY after player walks to entrance, stops, faces building, and plays idle animation.
class WorldMap extends World
    with TapCallbacks, DoubleTapCallbacks, ScaleCallbacks, HasGameReference {
  final Player player;
  final JoystickComponent joystick;
  final List<BuildingComponent> buildings = [];
  final List<DecorationComponent> decorations = [];

  late final NavigationGrid navigationGrid;
  TiledComponent? tiledMap;

  bool showDebugPath = false;

  void Function(String message)? onBuildingNotification;

  double _startZoom = 1.0;
  Vector2? _tapTargetPosition;
  double _targetPulseTime = 0.0;

  BuildingComponent? _targetBuilding;
  BuildingComponent? get targetBuilding => _targetBuilding;

  WorldMap({required this.joystick, this.onBuildingNotification})
    : player = Player(
        position: Vector2(800.0, 840.0), // Bottom center spawn
        joystick: joystick,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Navigation grid
    navigationGrid = NavigationGrid();

    // 2. Tiled (.tmx) map loader (prepared if map asset exists)
    await _tryLoadTiledMap();

    // 3. Handcrafted Single Island Background component (renders sky, island, paths, plaza, fountain)
    await add(WorldBackgroundComponent());

    // 4. Ambient floating magic particles & drifting falling leaves
    await add(AmbientParticlesComponent());

    // 5. Handcrafted Layered Decorations (Building -> Trees -> Bushes -> Flowers -> Lamp -> Fence around EVERY building)
    final spawnedDecorations = DecorationManager.createDecorations();
    decorations.addAll(spawnedDecorations);
    await addAll(spawnedDecorations);

    // 6. Buildings (arranged around Central Plaza)
    await _loadBuildings();

    // 7. Update pathfinding obstacle grid
    navigationGrid.updateObstacles(
      buildings: buildings,
      decorations: decorations,
    );

    // 8. Player component mounted on top
    await add(player);
  }

  /// Attempts to load Tiled (.tmx) map if available in assets/maps.
  Future<void> _tryLoadTiledMap() async {
    try {
      tiledMap = await GameAssetManager().loadTiledMap(
        AssetPaths.defaultMapTmx,
      );
      if (tiledMap != null) {
        await add(tiledMap!);
      }
    } catch (_) {
      // Soft fallback to procedural handcrafted canvas island
    }
  }

  void _clearAllBuildingHighlights() {
    for (final building in buildings) {
      building.isHighlighted = false;
    }
  }

  // ─── Scale (Pinch-to-zoom: 0.8x to 1.6x) ───────────────────────────────

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    _startZoom = GameState().zoomLevel;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    super.onScaleUpdate(event);
    final double scaleFactor = event.scale;
    if (scaleFactor != 1.0) {
      final double newZoom = (_startZoom * scaleFactor).clamp(0.8, 1.6);
      GameState().setZoomLevel(newZoom);
      game.camera.viewfinder.zoom = newZoom;
    }
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    super.onDoubleTapDown(event);
    GameState().resetZoomLevel();
    game.camera.viewfinder.zoom = 1.0;
  }

  // ─── Tap (Pathfinding + Deferred Building Arrival UI Flow) ─────────────────

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final fsm = GameStateManager();

    // Don't start auto-navigation while joystick is active
    final bool isJoystickActive =
        joystick.direction != JoystickDirection.idle &&
        !joystick.relativeDelta.isZero();
    if (isJoystickActive) return;

    final Vector2 tapWorldPosition = event.localPosition;
    _clearAllBuildingHighlights();

    BuildingComponent? tappedBuilding;
    for (final building in buildings) {
      if (building.containsLocalPoint(
        building.absoluteToLocal(event.canvasPosition),
      )) {
        tappedBuilding = building;
        break;
      }
    }

    if (tappedBuilding != null ||
        GameState().movementMode == MovementMode.tapToMove) {
      Vector2 destination;
      if (tappedBuilding != null) {
        if (!_isMathematicsBuilding(tappedBuilding)) {
          onBuildingNotification?.call(
            'This room is locked. Complete the Mathematics world first.',
          );
          return;
        }
        _targetBuilding = tappedBuilding;
        tappedBuilding.isHighlighted = true;
        fsm.toBuildingSelected(tappedBuilding.buildingData);
        fsm.toAutoWalking(tappedBuilding.buildingData);

        // Nearest entrance in front of building
        destination = Vector2(
          tappedBuilding.position.x,
          tappedBuilding.position.y + (tappedBuilding.size.y / 2) + 24.0,
        );
      } else {
        _targetBuilding = null;
        fsm.toExploring();
        destination = tapWorldPosition;
      }

      final List<Vector2> calculatedPath = AStarPathfinder().findPath(
        startWorldPos: player.position,
        targetWorldPos: destination,
        grid: navigationGrid,
      );

      if (calculatedPath.isNotEmpty) {
        player.controller.setPath(calculatedPath);
        _tapTargetPosition = calculatedPath.last;
      } else {
        fsm.showNotification('Tap Mode follows connected roads only!');
        onBuildingNotification?.call('Tap Mode follows connected roads only!');
        _tapTargetPosition = null;
        _targetBuilding = null;
        _clearAllBuildingHighlights();
      }
    }

    _targetPulseTime = 0.0;
  }

  // ─── Update (Handles Building Entrance Arrival & Deferred UI Opening) ─────

  @override
  void update(double dt) {
    super.update(dt);

    for (final building in buildings) {
      building.checkPlayerProximity(player.position);
    }

    if (player.controller.targetDestination == null) {
      // If player was walking towards a building target and has arrived at the entrance:
      if (_targetBuilding != null) {
        final BuildingComponent b = _targetBuilding!;

        // 1. Stop movement
        player.controller.velocity.setZero();

        // 2. Face building direction (up, down, left, right)
        final double diffX = b.position.x - player.position.x;
        final double diffY = b.position.y - player.position.y;
        if (diffY.abs() > diffX.abs()) {
          player.animationController.currentFacing = diffY < 0
              ? PlayerFacing.up
              : PlayerFacing.down;
        } else {
          player.animationController.currentFacing = diffX < 0
              ? PlayerFacing.left
              : PlayerFacing.right;
        }

        // 3. Play idle animation & keep golden glow active
        player.animationController.currentState = PlayerAnimationState.idle;
        b.isHighlighted = true;

        // 4. NOW open the interaction UI panel!
        b.triggerActionPanel();
        onBuildingNotification?.call('Arrived at ${b.name} entrance!');

        _targetBuilding = null;
      }

      _tapTargetPosition = null;
      if (GameStateManager().state == GamePlayState.autoWalking) {
        GameStateManager().toExploring();
      }
    } else {
      _targetPulseTime += dt;
    }
  }

  /// Interacts with any nearby building in proximity or closest to player (e.g. on keyboard Space/E press).
  bool interactWithNearbyBuilding() {
    // 1. First priority: any building currently in proximity
    for (final building in buildings) {
      if (building.isPlayerInProximity && _isMathematicsBuilding(building)) {
        building.triggerActionPanel();
        onBuildingNotification?.call('Interacting with ${building.name}');
        return true;
      }
    }

    // 2. Second priority: any building within a generous interaction radius (120px)
    BuildingComponent? closest;
    double minDistance = 120.0;
    for (final building in buildings) {
      final double d = building.position.distanceTo(player.position);
      if (d < minDistance && _isMathematicsBuilding(building)) {
        minDistance = d;
        closest = building;
      }
    }

    if (closest != null) {
      closest.triggerActionPanel();
      onBuildingNotification?.call('Interacting with ${closest.name}');
      return true;
    }

    return false;
  }

  bool _isMathematicsBuilding(BuildingComponent building) =>
      building.buildingData.subject.toLowerCase().startsWith('mathematics');

  // ─── Render Blue Magical Tap Trail & Overlay Effects ───────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // BLUE MAGICAL TAP TRAIL (Priority 10)
    if (player.controller.targetPath.isNotEmpty) {
      final List<Vector2> path = player.controller.targetPath;
      final int activeIndex = player.controller.currentWaypointIndex;

      if (activeIndex < path.length) {
        final Path trailPath = Path();
        trailPath.moveTo(player.position.x, player.position.y);

        for (int i = activeIndex; i < path.length; i++) {
          trailPath.lineTo(path[i].x, path[i].y);
        }

        // 1. Outer Glowing Cyan-Blue Magic Aura
        canvas.drawPath(
          trailPath,
          Paint()
            ..color = const Color(0xFF00E5FF).withValues(alpha: 0.65)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9.0
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
        );

        // 2. Inner Bright Cyan Magic Trail Line
        canvas.drawPath(
          trailPath,
          Paint()
            ..color = const Color(0xFF89DCEB)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );

        // 3. Glowing Magic Circle Waypoint Nodes
        for (int i = activeIndex; i < path.length; i++) {
          final pt = path[i];
          final double pulseR =
              6.5 + (math.sin(_targetPulseTime * 8.0 + i) * 2.5);

          canvas.drawCircle(
            Offset(pt.x, pt.y),
            pulseR + 4.0,
            Paint()
              ..color = const Color(0xAA00E5FF)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
          );
          canvas.drawCircle(
            Offset(pt.x, pt.y),
            pulseR,
            Paint()..color = const Color(0xFF89DCEB),
          );
        }
      }
    }

    // Tap target pulse indicator
    if (_tapTargetPosition != null) {
      final double radius = 14.0 + (math.sin(_targetPulseTime * 8.0) * 4.0);
      canvas.drawCircle(
        Offset(_tapTargetPosition!.x, _tapTargetPosition!.y),
        radius,
        Paint()
          ..color = const Color(0xAA89B4FA)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      canvas.drawCircle(
        Offset(_tapTargetPosition!.x, _tapTargetPosition!.y),
        4.0,
        Paint()..color = const Color(0xFF89B4FA),
      );
    }
  }

  // ─── Handcrafted Building Layout around Central Plaza (800, 520) ───────────

  Future<void> _loadBuildings() async {
    final configs = [
      // 1. North: Derivation House (Differential Calculus)
      BuildingComponent(
        buildingData: SampleBuildingData.derivationHouse,
        position: Vector2(800.0, 210.0),
        size: Vector2(190, 175),
        triggerRadius: 75,
        onPlayerEnter: (b) => _handleEnter(b),
        onPlayerLeave: (b) => _handleLeave(b),
        onInteract: (b) => _handleInteract(b),
      ),

      // 2. North West: Integration House (Integral Calculus)
      BuildingComponent(
        buildingData: SampleBuildingData.integrationHouse,
        position: Vector2(400.0, 260.0),
        size: Vector2(150, 142),
        onPlayerEnter: (b) => _handleEnter(b),
        onPlayerLeave: (b) => _handleLeave(b),
        onInteract: (b) => _handleInteract(b),
      ),

      // 3. North East: Trigonometry House (Trigonometric Ratios & Angles)
      BuildingComponent(
        buildingData: SampleBuildingData.trigonometryHouse,
        position: Vector2(1200.0, 260.0),
        size: Vector2(142, 142),
        onPlayerEnter: (b) => _handleEnter(b),
        onPlayerLeave: (b) => _handleLeave(b),
        onInteract: (b) => _handleInteract(b),
      ),

      // 4. West: Algebra House (Equations, Polynomials & Factoring)
      BuildingComponent(
        buildingData: SampleBuildingData.algebraHouse,
        position: Vector2(310.0, 520.0),
        size: Vector2(155, 150),
        onPlayerEnter: (b) => _handleEnter(b),
        onPlayerLeave: (b) => _handleLeave(b),
        onInteract: (b) => _handleInteract(b),
      ),

      // 5. South West: Geometry House (Geometry, Coordinate Planes & Vectors)
      BuildingComponent(
        buildingData: SampleBuildingData.geometryHouse,
        position: Vector2(440.0, 770.0),
        size: Vector2(145, 140),
        onPlayerEnter: (b) => _handleEnter(b),
        onPlayerLeave: (b) => _handleLeave(b),
        onInteract: (b) => _handleInteract(b),
      ),

      // 6. South East: Arithmetic House (Mental Math, Primes & Sequences)
      BuildingComponent(
        buildingData: SampleBuildingData.arithmeticHouse,
        position: Vector2(1160.0, 770.0),
        size: Vector2(140, 138),
        onPlayerEnter: (b) => _handleEnter(b),
        onPlayerLeave: (b) => _handleLeave(b),
        onInteract: (b) => _handleInteract(b),
      ),
    ];

    buildings.addAll(configs);
    await addAll(configs);
  }

  void _handleEnter(BuildingComponent building) {
    onBuildingNotification?.call('Approached ${building.name}');
  }

  void _handleLeave(BuildingComponent building) {
    building.isHighlighted = false;
  }

  void _handleInteract(BuildingComponent building) {
    onBuildingNotification?.call('Entered ${building.name}!');
    player.triggerInteractionState();
  }
}
