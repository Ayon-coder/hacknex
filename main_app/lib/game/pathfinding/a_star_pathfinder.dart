import 'package:flame/components.dart';
import 'navigation_grid.dart';

/// Reusable A* Pathfinding service navigating 8-directional tile grids,
/// enforcing road-only traversal in Tap Mode, avoiding non-walkable grass and obstacles,
/// and returning world waypoint paths.
class AStarPathfinder {
  static final AStarPathfinder _instance = AStarPathfinder._internal();
  factory AStarPathfinder() => _instance;
  AStarPathfinder._internal();

  /// Calculates an A* path from [startWorldPos] to [targetWorldPos] over [grid].
  /// Returns a list of world vector waypoints strictly along connected road tiles.
  List<Vector2> findPath({
    required Vector2 startWorldPos,
    required Vector2 targetWorldPos,
    required NavigationGrid grid,
  }) {
    PathNode? startNode = grid.getNodeFromWorldPosition(startWorldPos);
    PathNode? targetNode = grid.getNodeFromWorldPosition(targetWorldPos);

    if (startNode == null || targetNode == null) {
      return [];
    }

    // If start node is non-walkable (e.g. player entered grass in Joystick mode), snap start to nearest road tile
    if (!startNode.isWalkable) {
      startNode = _findNearestWalkableNode(startNode, grid);
      if (startNode == null) return [];
    }

    // If target node is non-walkable (e.g. grass or building footprint), snap target to nearest road tile
    if (!targetNode.isWalkable) {
      targetNode = _findNearestWalkableNode(targetNode, grid);
      if (targetNode == null) return [];
    }

    // Reset A* parameters on all nodes
    for (int c = 0; c < grid.cols; c++) {
      for (int r = 0; r < grid.rows; r++) {
        grid.grid[c][r].reset();
      }
    }

    final List<PathNode> openSet = [startNode];
    final Set<PathNode> closedSet = {};

    while (openSet.isNotEmpty) {
      // Find node in openSet with lowest fCost (and hCost tie-breaking)
      openSet.sort((a, b) {
        final int compare = a.fCost.compareTo(b.fCost);
        if (compare == 0) {
          return a.hCost.compareTo(b.hCost);
        }
        return compare;
      });

      final PathNode current = openSet.removeAt(0);
      closedSet.add(current);

      if (current == targetNode) {
        // Reconstruct path strictly along connected road tiles
        final List<Vector2> waypoints = _reconstructPath(startNode, targetNode);
        if (waypoints.isEmpty) {
          waypoints.add(targetNode.worldPosition.clone());
        }
        return waypoints;
      }

      for (final neighbor in grid.getNeighbors(current)) {
        if (!neighbor.isWalkable || closedSet.contains(neighbor)) {
          continue;
        }

        // Distance cost (1.0 for orthogonal, ~1.414 for diagonal)
        final bool isDiagonal = (current.gridX != neighbor.gridX) && (current.gridY != neighbor.gridY);
        final double baseDist = isDiagonal ? 1.414 : 1.0;

        final double newCostToNeighbor = current.gCost + (baseDist * neighbor.movementCost);

        if (newCostToNeighbor < neighbor.gCost || !openSet.contains(neighbor)) {
          neighbor.gCost = newCostToNeighbor;
          neighbor.hCost = _getDistanceHeuristic(neighbor, targetNode);
          neighbor.parent = current;

          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
        }
      }
    }

    // No valid road path found
    return [];
  }

  /// Finds nearest walkable road node within grid radius.
  PathNode? _findNearestWalkableNode(PathNode node, NavigationGrid grid) {
    PathNode? nearest;
    double minDistance = double.infinity;

    const int searchRadius = 8;
    final int minC = (node.gridX - searchRadius).clamp(0, grid.cols - 1);
    final int maxC = (node.gridX + searchRadius).clamp(0, grid.cols - 1);
    final int minR = (node.gridY - searchRadius).clamp(0, grid.rows - 1);
    final int maxR = (node.gridY + searchRadius).clamp(0, grid.rows - 1);

    for (int c = minC; c <= maxC; c++) {
      for (int r = minR; r <= maxR; r++) {
        final candidate = grid.grid[c][r];
        if (candidate.isWalkable) {
          final double dist = node.worldPosition.distanceTo(candidate.worldPosition);
          if (dist < minDistance) {
            minDistance = dist;
            nearest = candidate;
          }
        }
      }
    }
    return nearest;
  }

  /// Reconstructs path list from target node back to start node.
  List<Vector2> _reconstructPath(PathNode startNode, PathNode targetNode) {
    final List<Vector2> path = [];
    PathNode? current = targetNode;

    while (current != null && current != startNode) {
      path.add(current.worldPosition.clone());
      current = current.parent;
    }

    return path.reversed.toList();
  }

  /// Calculates Euclidean/Octile distance heuristic for A*.
  double _getDistanceHeuristic(PathNode nodeA, PathNode nodeB) {
    final int dx = (nodeA.gridX - nodeB.gridX).abs();
    final int dy = (nodeA.gridY - nodeB.gridY).abs();

    if (dx > dy) {
      return 1.414 * dy + (dx - dy);
    }
    return 1.414 * dx + (dy - dx);
  }
}
