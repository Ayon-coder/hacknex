import 'package:flutter/foundation.dart';
import '../buildings/building_data.dart';
import 'building_manager.dart';
import 'game_state_manager.dart';

/// Available player movement control modes.
enum MovementMode {
  /// Virtual joystick input in bottom-left corner.
  joystick,

  /// Tap anywhere on the world map or on buildings to auto-navigate.
  tapToMove,
}

/// Centralized state manager handling movement modes, persistent camera zoom level,
/// and bridging with [GameStateManager].
class GameState extends ChangeNotifier {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  MovementMode _movementMode = MovementMode.joystick;
  double _zoomLevel = 1.0;

  /// Active movement control mode.
  MovementMode get movementMode => _movementMode;

  /// Persisted camera zoom level (clamped between 0.8x and 1.6x).
  double get zoomLevel => _zoomLevel;

  /// Active explicit gameplay state from [GameStateManager].
  GamePlayState get currentPlayState => GameStateManager().state;

  /// Currently open building action panel data (null if closed).
  BuildingData? get activeBuildingPanel => BuildingManager().activePanelBuilding;

  /// Updates active movement control mode and notifies listeners.
  void setMovementMode(MovementMode mode) {
    if (_movementMode != mode) {
      _movementMode = mode;
      notifyListeners();
    }
  }

  /// Toggles between Joystick and Tap-To-Move modes.
  void toggleMovementMode() {
    setMovementMode(
      _movementMode == MovementMode.joystick
          ? MovementMode.tapToMove
          : MovementMode.joystick,
    );
  }

  /// Updates persisted camera zoom level between 0.8x and 1.6x.
  void setZoomLevel(double zoom) {
    final double clamped = zoom.clamp(0.8, 1.6);
    if ((_zoomLevel - clamped).abs() > 0.001) {
      _zoomLevel = clamped;
      notifyListeners();
    }
  }

  /// Resets camera zoom level back to default 1.0x.
  void resetZoomLevel() {
    setZoomLevel(1.0);
  }

  /// Opens building action panel via [BuildingManager] and updates [GameStateManager].
  void openBuildingPanel(BuildingData buildingData) {
    BuildingManager().openPanelForBuilding(buildingData);
    GameStateManager().toBuildingPanelOpen(buildingData);
    notifyListeners();
  }

  /// Closes active building action panel via [BuildingManager] and updates [GameStateManager].
  void closeBuildingPanel() {
    BuildingManager().closePanel();
    GameStateManager().toExploring();
    notifyListeners();
  }
}
