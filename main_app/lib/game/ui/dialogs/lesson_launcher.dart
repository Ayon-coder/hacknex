import 'dart:async';
import 'package:flutter/material.dart';
import '../../buildings/building_data.dart';
import '../../buildings/sample_building_data.dart';
import '../../managers/building_manager.dart';
import '../../managers/game_state_manager.dart';
import 'building_learning_panel.dart';

/// Reusable transition manager launching interactive AI-powered Building Learning Panels
/// directly over the character gameplay world session.
class LessonLauncher {
  /// Launches an AI-powered building learning session for a given building.
  static Future<void> launchBuilding(
    BuildContext context,
    BuildingData building,
  ) async {
    await launch(
      context,
      building: building,
      buildingId: building.id,
      buildingName: building.name,
      subject: building.subject,
      themeColor: building.themeColor,
    );
  }

  /// Launches an AI-powered learning interaction for a specified building.
  static Future<void> launch(
    BuildContext context, {
    BuildingData? building,
    String? buildingId,
    String? buildingName,
    String? subject,
    Color themeColor = const Color(0xFF89B4FA),
  }) async {
    final targetBuilding = building ??
        (buildingId != null ? BuildingManager().getBuilding(buildingId) : null) ??
        SampleBuildingData.codingTower;

    // Transition explicit GameStateManager to LoadingLesson
    GameStateManager().toLoadingLesson(targetBuilding);

    // Show Building Learning Panel Dialog directly over the character gameplay world
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return BuildingLearningPanel(
          building: targetBuilding,
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );

    // Return explicit GameStateManager to Exploring upon exit
    GameStateManager().toExploring();
  }
}
