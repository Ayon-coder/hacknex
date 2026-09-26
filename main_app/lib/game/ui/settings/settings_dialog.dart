import 'package:flutter/material.dart';
import '../../managers/game_state.dart';

/// Interactive Settings modal dialog for switching movement control modes.
class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = GameState();

    return AnimatedBuilder(
      animation: gameState,
      builder: (context, child) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: Color(0xFF89B4FA), width: 2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.settings, color: Color(0xFF89B4FA)),
                        SizedBox(width: 8),
                        Text(
                          'Game Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF313244), height: 24),
                const Text(
                  'Movement Mode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFCDD6F4),
                  ),
                ),
                const SizedBox(height: 12),
                _buildModeTile(
                  context,
                  mode: MovementMode.joystick,
                  title: 'Mode 1: Virtual Joystick',
                  subtitle: 'Move using HUD joystick in bottom-left',
                  icon: Icons.gamepad,
                  isSelected: gameState.movementMode == MovementMode.joystick,
                  onTap: () => gameState.setMovementMode(MovementMode.joystick),
                ),
                const SizedBox(height: 8),
                _buildModeTile(
                  context,
                  mode: MovementMode.tapToMove,
                  title: 'Mode 2: Tap-to-Move',
                  subtitle: 'Tap anywhere or tap buildings to auto-walk',
                  icon: Icons.touch_app,
                  isSelected: gameState.movementMode == MovementMode.tapToMove,
                  onTap: () => gameState.setMovementMode(MovementMode.tapToMove),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF89B4FA),
                      foregroundColor: const Color(0xFF181825),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Save & Close', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeTile(
    BuildContext context, {
    required MovementMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x3389B4FA) : const Color(0xFF181825),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF89B4FA) : const Color(0xFF313244),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF89B4FA) : Colors.white60),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF89B4FA), size: 20),
          ],
        ),
      ),
    );
  }
}
