import 'package:flame/components.dart';
import '../../config/game_constants.dart';
import '../buildings/building_component.dart';
import '../world/decorations/decoration_component.dart';

/// Single node in the navigation grid for pathfinding.
class PathNode {
  final int gridX;
  final int gridY;
  final Vector2 worldPosition;
  bool isWalkable;
  double movementCost;

  // A* pathfinding values
  double gCost = 0.0;
  double hCost = 0.0;
  PathNode? parent;

  double get fCost => gCost + hCost;

  PathNode({
    required this.gridX,
    required this.gridY,
    required this.worldPosition,
    this.isWalkable = true,
    this.movementCost = 1.0,
  });

  void reset() {
    gCost = 0.0;
    hCost = 0.0;
    parent = null;
  }
}

/// Navigation Grid classifying map into tile cells.
/// Restricts walkable nodes strictly to connected road & plaza tiles inside the island boundary.
/// Grass tiles and areas outside the island collision radius are marked non-walkable.
class NavigationGrid {
  final double cellSize;
  final int cols;
  final int rows;
  late final List<List<PathNode>> grid;

  NavigationGrid({
    this.cellSize = GameConstants.gridCellSize,
    double mapWidth = GameConstants.worldWidth,
    double mapHeight = GameConstants.worldHeight,
  })  : cols = (mapWidth / cellSize).ceil(),
        rows = (mapHeight / cellSize).ceil() {
    _initGrid();
  }

  /// Initializes grid cells. ONLY connected road and plaza tiles inside the island boundary are walkable.
  void _initGrid() {
    grid = List.generate(cols, (c) {
      return List.generate(rows, (r) {
        final Vector2 worldPos = Vector2(
          (c * cellSize) + (cellSize / 2),
          (r * cellSize) + (cellSize / 2),
        );

        final bool isInsideIsland = _isInsideIslandBoundary(worldPos);
        final bool isRoadOrPlaza = isInsideIsland && _isRoadOrPlazaTile(worldPos);

        return PathNode(
          gridX: c,
          gridY: r,
          worldPosition: worldPos,
          isWalkable: isRoadOrPlaza,
          movementCost: isRoadOrPlaza ? 1.0 : 100.0,
        );
      });
    });
  }

  /// Updates obstacle collision nodes for buildings and decorations.
  void updateObstacles({
    required List<BuildingComponent> buildings,
    required List<DecorationComponent> decorations,
  }) {
    // Re-evaluate walkability (only connected road/plaza tiles inside island)
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        final Vector2 pos = grid[c][r].worldPosition;
        grid[c][r].isWalkable = _isInsideIslandBoundary(pos) && _isRoadOrPlazaTile(pos);
      }
    }

    // Mark building bounds as non-walkable
    for (final building in buildings) {
      final double bMinX = building.position.x - building.size.x / 2 - 8;
      final double bMaxX = building.position.x + building.size.x / 2 + 8;
      final double bMinY = building.position.y - building.size.y / 2 - 8;
      final double bMaxY = building.position.y + building.size.y / 2 + 8;

      final int minC = (bMinX / cellSize).floor().clamp(0, cols - 1);
      final int maxC = (bMaxX / cellSize).ceil().clamp(0, cols - 1);
      final int minR = (bMinY / cellSize).floor().clamp(0, rows - 1);
      final int maxR = (bMaxY / cellSize).ceil().clamp(0, rows - 1);

      for (int c = minC; c <= maxC; c++) {
        for (int r = minR; r <= maxR; r++) {
          grid[c][r].isWalkable = false;
        }
      }
    }

    // Mark decoration bounds as non-walkable
    for (final dec in decorations) {
      final double dMinX = dec.position.x - dec.size.x / 2;
      final double dMaxX = dec.position.x + dec.size.x / 2;
      final double dMinY = dec.position.y - dec.size.y / 2;
      final double dMaxY = dec.position.y + dec.size.y / 2;

      final int minC = (dMinX / cellSize).floor().clamp(0, cols - 1);
      final int maxC = (dMaxX / cellSize).ceil().clamp(0, cols - 1);
      final int minR = (dMinY / cellSize).floor().clamp(0, rows - 1);
      final int maxR = (dMaxY / cellSize).ceil().clamp(0, rows - 1);

      for (int c = minC; c <= maxC; c++) {
        for (int r = minR; r <= maxR; r++) {
          grid[c][r].isWalkable = false;
        }
      }
    }
  }

  /// Converts world position coordinates to grid cell node.
  PathNode? getNodeFromWorldPosition(Vector2 worldPos) {
    final int c = (worldPos.x / cellSize).floor().clamp(0, cols - 1);
    final int r = (worldPos.y / cellSize).floor().clamp(0, rows - 1);
    return grid[c][r];
  }

  /// Returns valid 8-directional neighbors surrounding a node.
  List<PathNode> getNeighbors(PathNode node) {
    final neighbors = <PathNode>[];

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;

        final int checkC = node.gridX + dx;
        final int checkR = node.gridY + dy;

        if (checkC >= 0 && checkC < cols && checkR >= 0 && checkR < rows) {
          if (dx != 0 && dy != 0) {
            final bool adj1 = grid[node.gridX + dx][node.gridY].isWalkable;
            final bool adj2 = grid[node.gridX][node.gridY + dy].isWalkable;
            if (!adj1 || !adj2) continue;
          }
          neighbors.add(grid[checkC][checkR]);
        }
      }
    }
    return neighbors;
  }

  /// Checks if point lies strictly inside the island boundary oval.
  bool _isInsideIslandBoundary(Vector2 pos) {
    const double rx = 670.0;
    const double ry = 390.0;
    final double nx = (pos.x - 800.0) / rx;
    final double ny = (pos.y - 520.0) / ry;
    return (nx * nx + ny * ny) <= 1.0;
  }

  /// Evaluates whether world position lies on a connected road or plaza tile.
  bool _isRoadOrPlazaTile(Vector2 pos) {
    final plazaCenter = Vector2(800.0, 520.0);
    const double plazaRadius = 135.0;

    // 1. Central Plaza circular region
    if (pos.distanceTo(plazaCenter) <= plazaRadius) {
      return true;
    }

    // 2. Connected Road Segments (North, South, West, NW, NE, SW, SE)
    final segments = [
      [Vector2(800, 520), Vector2(800, 210)],
      [Vector2(800, 520), Vector2(800, 880)],
      [Vector2(800, 520), Vector2(310, 520)],
      [Vector2(800, 520), Vector2(400, 260)],
      [Vector2(800, 520), Vector2(1200, 260)],
      [Vector2(800, 520), Vector2(440, 770)],
      [Vector2(800, 520), Vector2(1160, 770)],
    ];

    for (final seg in segments) {
      if (_distToSegment(pos, seg[0], seg[1]) <= 38.0) {
        return true;
      }
    }

    return false;
  }

  double _distToSegment(Vector2 p, Vector2 a, Vector2 b) {
    final double l2 = (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y);
    if (l2 == 0) return p.distanceTo(a);
    double t = ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / l2;
    t = t.clamp(0.0, 1.0);
    final Vector2 projection = Vector2(a.x + t * (b.x - a.x), a.y + t * (b.y - a.y));
    return p.distanceTo(projection);
  }
}
