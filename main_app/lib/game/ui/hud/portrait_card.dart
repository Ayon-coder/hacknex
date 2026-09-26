import 'package:flutter/material.dart';

import '../../../config/asset_paths.dart';

/// Reference-style player portrait card widget — top-left corner.
/// Shows avatar, player name "Arcanist", level badge, and XP progress bar.
class PortraitCardWidget extends StatelessWidget {
  final String playerName;
  final int level;
  final int currentXp;
  final int maxXp;

  const PortraitCardWidget({
    super.key,
    this.playerName = 'Arcanist',
    this.level = 12,
    this.currentXp = 850,
    this.maxXp = 1500,
  });

  @override
  Widget build(BuildContext context) {
    final double xpRatio = (currentXp / maxXp).clamp(0.0, 1.0);

    return Container(
      width: 210,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xE0122040),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B5A3E), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar portrait
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6B5A3E), width: 2.5),
              color: const Color(0xFF0D1B2A),
              image: const DecorationImage(
                image: AssetImage(
                  AssetPaths.playerArcanistPortrait,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name, level, XP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  playerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Level $level',
                  style: const TextStyle(
                    color: Color(0xFFCDD6F4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                // XP Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 7,
                    width: double.infinity,
                    color: const Color(0xFF1A1A2E),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: xpRatio,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF9B59D4), Color(0xFFCBA6F7)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$currentXp / $maxXp XP',
                  style: const TextStyle(
                    color: Color(0xFFCBA6F7),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Shield/emblem on right
          const SizedBox(width: 6),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A2E),
              border: Border.all(color: const Color(0xFF6B5A3E), width: 1.5),
            ),
            child: const Icon(Icons.shield, color: Color(0xFFF9E2AF), size: 20),
          ),
        ],
      ),
    );
  }
}
