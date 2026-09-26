import 'package:flutter/material.dart';
import '../../managers/game_state.dart';
import 'coins_display.dart';
import 'movement_toggle.dart';
import 'settings_button.dart';
import 'xp_display.dart';

/// Top Bar HUD layout widget composing CoinsDisplay, XpDisplay, MovementToggle,
/// and SettingsButton into a responsive top bar overlay.
class TopBarWidget extends StatelessWidget {
  final MovementMode movementMode;
  final int coins;
  final int level;
  final int currentXp;
  final int maxXp;

  const TopBarWidget({
    super.key,
    required this.movementMode,
    this.coins = 250,
    this.level = 5,
    this.currentXp = 730,
    this.maxXp = 1000,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Group: Coins and XP Displays
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CoinsDisplayWidget(coins: coins),
                const SizedBox(width: 8),
                XpDisplayWidget(
                  level: level,
                  currentXp: currentXp,
                  maxXp: maxXp,
                ),
              ],
            ),

            // Right Group: Movement Mode Toggle and Settings Button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MovementToggleWidget(currentMode: movementMode),
                const SizedBox(width: 8),
                const SettingsButtonWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
