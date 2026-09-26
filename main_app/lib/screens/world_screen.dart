import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/academy_game.dart';
import '../game/ui/hud/game_hud.dart';

/// Primary World Screen hosting the 2D floating Academy Flame Game
/// with player movement, camera controls, building interactions, and HUD overlays.
class WorldScreen extends StatelessWidget {
  const WorldScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: GameWidget<AcademyGame>.controlled(
        gameFactory: AcademyGame.new,
        autofocus: true,
        overlayBuilderMap: {
          'HUD': (context, game) => GameHudWidget(onBack: onBack),
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}
