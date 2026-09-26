import 'package:flutter/foundation.dart';
import '../buildings/building_data.dart';

/// Explicit gameplay states for finite state machine control.
enum GamePlayState {
  /// Player exploring open map freely via joystick or terrain tap.
  exploring,

  /// Player automatically navigating toward a target destination / building.
  autoWalking,

  /// Player selected a building in proximity or on map.
  buildingSelected,

  /// Clash of Clans style Building Action Panel open overlay.
  buildingPanelOpen,

  /// Fade to black screen transition and lesson loader active.
  loadingLesson,

  /// Inside interactive Lesson Scene.
  lesson,

  /// Game paused / Settings menu modal open.
  paused,
}

/// Centralized GameStateManager service managing explicit finite gameplay states,
/// HUD notifications, and notifying listening systems without scattered boolean flags.
class GameStateManager extends ChangeNotifier {
  static final GameStateManager _instance = GameStateManager._internal();
  factory GameStateManager() => _instance;
  GameStateManager._internal();

  GamePlayState _state = GamePlayState.exploring;
  BuildingData? _targetBuilding;

  /// Active transient notification message (null if clear).
  String? activeNotification;

  /// Current explicit gameplay state.
  GamePlayState get state => _state;

  /// Alias for backward compatibility.
  GamePlayState get currentState => _state;

  /// Active target or panel building (null if exploring/paused).
  BuildingData? get targetBuilding => _targetBuilding;

  /// Whether player entity is allowed to receive movement inputs.
  bool get canPlayerMove =>
      _state == GamePlayState.exploring ||
      _state == GamePlayState.autoWalking ||
      _state == GamePlayState.buildingSelected;

  /// Whether game is currently paused.
  bool get isPaused => _state == GamePlayState.paused;

  /// Displays a temporary HUD toast notification message for 3 seconds.
  void showNotification(String message) {
    activeNotification = message;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      if (activeNotification == message) {
        activeNotification = null;
        notifyListeners();
      }
    });
  }

  /// Transitions state to [GamePlayState.exploring].
  void toExploring() {
    if (_state != GamePlayState.exploring) {
      _state = GamePlayState.exploring;
      _targetBuilding = null;
      notifyListeners();
    }
  }

  /// Transitions state to [GamePlayState.autoWalking].
  void toAutoWalking(BuildingData? building) {
    _state = GamePlayState.autoWalking;
    _targetBuilding = building;
    notifyListeners();
  }

  /// Alias for backward compatibility.
  void toMovingToBuilding(BuildingData building) => toAutoWalking(building);

  /// Transitions state to [GamePlayState.buildingSelected].
  void toBuildingSelected(BuildingData building) {
    _state = GamePlayState.buildingSelected;
    _targetBuilding = building;
    notifyListeners();
  }

  /// Transitions state to [GamePlayState.buildingPanelOpen].
  void toBuildingPanelOpen(BuildingData building) {
    _state = GamePlayState.buildingPanelOpen;
    _targetBuilding = building;
    notifyListeners();
  }

  /// Transitions state to [GamePlayState.loadingLesson].
  void toLoadingLesson(BuildingData building) {
    _state = GamePlayState.loadingLesson;
    _targetBuilding = building;
    notifyListeners();
  }

  /// Transitions state to [GamePlayState.lesson].
  void toLesson(BuildingData building) {
    _state = GamePlayState.lesson;
    _targetBuilding = building;
    notifyListeners();
  }

  /// Transitions state to [GamePlayState.paused].
  void toPaused() {
    _state = GamePlayState.paused;
    notifyListeners();
  }
}
