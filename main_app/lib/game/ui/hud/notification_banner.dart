import 'package:flutter/material.dart';

/// HUD notification banner widget for rendering game alerts, achievements, and notifications.
class NotificationBannerWidget extends StatelessWidget {
  final String? message;
  final IconData icon;
  final Color accentColor;

  const NotificationBannerWidget({
    super.key,
    this.message,
    this.icon = Icons.notifications_active,
    this.accentColor = const Color(0xFF89B4FA),
  });

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(message),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xEE1E1E2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accentColor, size: 18),
            const SizedBox(width: 10),
            Text(
              message!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
