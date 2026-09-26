import 'package:flutter/material.dart';

/// HUD widget displaying player coin currency balance.
class CoinsDisplayWidget extends StatelessWidget {
  final int coins;

  const CoinsDisplayWidget({
    super.key,
    this.coins = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC1E1E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF9E2AF), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            color: Color(0xFFF9E2AF),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
