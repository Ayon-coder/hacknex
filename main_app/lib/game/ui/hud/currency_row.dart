import 'package:flutter/material.dart';

/// Reference-style currency row widget — gold, gems, energy displayed in vertical stack.
class CurrencyRowWidget extends StatelessWidget {
  final int coins;
  final int gems;
  final int energy;
  final int maxEnergy;

  const CurrencyRowWidget({
    super.key,
    this.coins = 2450,
    this.gems = 340,
    this.energy = 120,
    this.maxEnergy = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _CurrencyItem(
          emoji: '🪙',
          emojiColor: const Color(0xFFF9E2AF),
          value: '$coins',
        ),
        const SizedBox(height: 4),
        _CurrencyItem(
          emoji: '💎',
          emojiColor: const Color(0xFFCBA6F7),
          value: '$gems',
        ),
        const SizedBox(height: 4),
        _CurrencyItem(
          emoji: '⚡',
          emojiColor: const Color(0xFF89B4FA),
          value: '$energy/$maxEnergy',
          showPlus: true,
        ),
      ],
    );
  }
}

class _CurrencyItem extends StatelessWidget {
  final String emoji;
  final Color emojiColor;
  final String value;
  final bool showPlus;

  const _CurrencyItem({
    required this.emoji,
    required this.emojiColor,
    required this.value,
    this.showPlus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xCC0D1520),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (showPlus) ...[
            const SizedBox(width: 6),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF2D7A3E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4CAF50), width: 1),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 12),
            ),
          ],
        ],
      ),
    );
  }
}
