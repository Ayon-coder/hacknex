import 'package:flutter/foundation.dart';
import '../buildings/building_data.dart';
import '../buildings/sample_building_data.dart';

/// Independent manager service handling building registrations, unlock states,
/// building progression (XP, Level 1->2->3 upgrades with visual environment improvements),
/// and single-panel UI state.
class BuildingManager extends ChangeNotifier {
  static final BuildingManager _instance = BuildingManager._internal();
  factory BuildingManager() => _instance;

  BuildingManager._internal() {
    _initDefaultBuildings();
  }

  /// Building registry indexed by building ID.
  final Map<String, BuildingData> _buildings = {};

  /// Currently active building action panel (null if closed).
  BuildingData? _activePanelBuilding;

  /// Currently open building action panel data.
  BuildingData? get activePanelBuilding => _activePanelBuilding;

  /// Returns unmodifiable list of all registered buildings.
  List<BuildingData> get allBuildings => List.unmodifiable(_buildings.values);

  /// Registers default sample buildings on startup.
  void _initDefaultBuildings() {
    for (final building in SampleBuildingData.allBuildings) {
      _buildings[building.id] = building;
    }
  }

  /// Registers a building or updates an existing building definition.
  void registerBuilding(BuildingData building) {
    _buildings[building.id] = building;
    notifyListeners();
  }

  /// Returns building information by ID (or null if not registered).
  BuildingData? getBuilding(String id) => _buildings[id];

  /// Checks if a building is unlocked.
  bool isUnlocked(String id) => _buildings[id]?.unlocked ?? false;

  /// Checks if a building has enough XP to level up (Level 1->2 or 2->3).
  bool canUpgrade(String id) {
    final b = _buildings[id];
    return b != null && b.level < 3 && b.currentXp >= b.xpRequired;
  }

  /// Upgrades building level (Level 1 -> 2 -> 3), unlocking visual environment enhancements around the building.
  bool upgradeBuilding(String id) {
    final existing = _buildings[id];
    if (existing == null || existing.level >= 3 || existing.currentXp < existing.xpRequired) {
      return false;
    }

    final int nextLevel = existing.level + 1;
    final int leftoverXp = existing.currentXp - existing.xpRequired;
    final int nextXpRequired = (nextLevel == 2) ? 700 : 9999;

    final updated = BuildingData(
      id: existing.id,
      name: existing.name,
      icon: existing.icon,
      sprite: existing.sprite, // Buildings ALWAYS preserve the original high-quality sprite!
      level: nextLevel,
      subject: existing.subject,
      description: existing.description,
      unlocked: existing.unlocked,
      currentXp: leftoverXp,
      xpRequired: nextXpRequired,
      lessonsAvailable: existing.lessonsAvailable + 5,
      themeColor: existing.themeColor,
    );

    _buildings[id] = updated;

    if (_activePanelBuilding?.id == id) {
      _activePanelBuilding = updated;
    }

    notifyListeners();
    return true;
  }

  /// Unlocks a building by ID.
  void unlockBuilding(String id) {
    final existing = _buildings[id];
    if (existing != null && !existing.unlocked) {
      _buildings[id] = BuildingData(
        id: existing.id,
        name: existing.name,
        icon: existing.icon,
        sprite: existing.sprite,
        level: existing.level,
        subject: existing.subject,
        description: existing.description,
        unlocked: true,
        currentXp: existing.currentXp,
        xpRequired: existing.xpRequired,
        lessonsAvailable: existing.lessonsAvailable,
        themeColor: existing.themeColor,
      );
      notifyListeners();
    }
  }

  /// Tracks player progress by adding XP to a specific building.
  void addXp(String id, int amount) {
    final existing = _buildings[id];
    if (existing == null) return;

    final int newXp = existing.currentXp + amount;

    final updated = BuildingData(
      id: existing.id,
      name: existing.name,
      icon: existing.icon,
      sprite: existing.sprite,
      level: existing.level,
      subject: existing.subject,
      description: existing.description,
      unlocked: existing.unlocked,
      currentXp: newXp,
      xpRequired: existing.xpRequired,
      lessonsAvailable: existing.lessonsAvailable,
      themeColor: existing.themeColor,
    );

    _buildings[id] = updated;

    if (_activePanelBuilding?.id == id) {
      _activePanelBuilding = updated;
    }

    notifyListeners();
  }

  /// Opens the Building Action Panel for a specified building ID.
  void openPanel(String id) {
    final building = _buildings[id];
    if (building != null && building.unlocked) {
      _activePanelBuilding = building;
      notifyListeners();
    }
  }

  /// Opens panel for a BuildingData instance directly.
  void openPanelForBuilding(BuildingData building) {
    openPanel(building.id);
  }

  /// Closes the currently active building action panel.
  void closePanel() {
    if (_activePanelBuilding != null) {
      _activePanelBuilding = null;
      notifyListeners();
    }
  }
}
