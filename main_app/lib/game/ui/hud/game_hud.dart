import 'package:flutter/material.dart';
import '../../../screens/world_archipelago_screen.dart';
import '../../managers/building_manager.dart';
import '../../managers/game_state.dart';
import '../../managers/game_state_manager.dart';
import '../dialogs/building_action_panel.dart';
import '../dialogs/lesson_launcher.dart';
import 'currency_row.dart';
import 'movement_toggle.dart';
import 'notification_banner.dart';
import 'portrait_card.dart';
import 'settings_button.dart';
import 'side_buttons.dart';

/// Full HUD overlay matching the reference image layout:
/// - Top-left: Back button + Portrait card + currency stack
/// - Top-right: Movement toggle + Settings gear
/// - Right-edge (center): Quests + Inventory side buttons
/// - Bottom-left: (Joystick is rendered by Flame viewport — not here)
/// - Center-top (conditional): Notification banner
/// - Center (conditional): Building action panel
class GameHudWidget extends StatelessWidget {
  final String? notificationMessage;
  final VoidCallback? onBack;

  const GameHudWidget({super.key, this.notificationMessage, this.onBack});

  void _navigateBackToSubjects(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) =>
              const WorldArchipelagoScreen(),
          transitionsBuilder: (context, anim1, anim2, child) {
            return FadeTransition(opacity: anim1, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = GameState();
    final buildingManager = BuildingManager();
    final fsm = GameStateManager();

    return AnimatedBuilder(
      animation: Listenable.merge([gameState, buildingManager, fsm]),
      builder: (context, child) {
        final activeBuilding = buildingManager.activePanelBuilding;
        final String? currentNotification =
            notificationMessage ?? fsm.activeNotification;

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 14,
              left: 14,
              child: SafeArea(
                child: HudBackButtonWidget(
                  onTap: () => _navigateBackToSubjects(context),
                ),
              ),
            ),

            // ─── Top-Left: Portrait Card + Currency ───────────────────────
            Positioned(
              top: 70,
              left: 12,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PortraitCardWidget(
                      playerName: 'Arcanist',
                      level: 12,
                      currentXp: 850,
                      maxXp: 1500,
                    ),
                    const SizedBox(height: 10),
                    CurrencyRowWidget(
                      coins: 2450,
                      gems: 340,
                      energy: 120,
                      maxEnergy: 120,
                    ),
                  ],
                ),
              ),
            ),

            // ─── Top-Right: Movement Toggle + Settings ─────────────────────
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MovementToggleWidget(currentMode: gameState.movementMode),
                    const SizedBox(width: 8),
                    const SettingsButtonWidget(),
                  ],
                ),
              ),
            ),

            // ─── Right Edge (center): Quests + Inventory ───────────────────
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(child: const SideButtonsWidget()),
            ),

            // ─── Notification Banner (center-top) ─────────────────────────
            if (currentNotification != null && currentNotification.isNotEmpty)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: NotificationBannerWidget(message: currentNotification),
                ),
              ),

            // ─── Building Action Panel (fullscreen overlay) ────────────────
            if (activeBuilding != null)
              BuildingActionPanel(
                building: activeBuilding,
                onClose: () => buildingManager.closePanel(),
                onLearn: () {
                  buildingManager.closePanel();
                  LessonLauncher.launchBuilding(context, activeBuilding);
                },
              ),
          ],
        );
      },
    );
  }
}

/// Back button on the game world HUD that redirects to Subject Selection.
/// Implemented with MouseRegion + GestureDetector for 100% reliable click registration on desktop.
class HudBackButtonWidget extends StatefulWidget {
  final VoidCallback onTap;

  const HudBackButtonWidget({super.key, required this.onTap});

  @override
  State<HudBackButtonWidget> createState() => _HudBackButtonWidgetState();
}

class _HudBackButtonWidgetState extends State<HudBackButtonWidget> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Subject Selection',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.90 : (_isHovered ? 1.08 : 1.0),
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isHovered
                    ? const Color(0xFF1E3563)
                    : const Color(0xEE122040),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFFF9E2AF)
                      : const Color(0xFF6B5A3E),
                  width: _isHovered ? 2.0 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: _isHovered ? 10 : 6,
                    offset: const Offset(0, 3),
                  ),
                  if (_isHovered)
                    BoxShadow(
                      color: const Color(0xFFF9E2AF).withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFFF9E2AF),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

