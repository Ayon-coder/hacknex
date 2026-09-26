import 'package:flutter/material.dart';

/// Reference-style stacked side buttons — Quests and Inventory on right edge.
class SideButtonsWidget extends StatefulWidget {
  const SideButtonsWidget({super.key});

  @override
  State<SideButtonsWidget> createState() => _SideButtonsWidgetState();
}

class _SideButtonsWidgetState extends State<SideButtonsWidget> {
  bool _questsHovered = false;
  bool _inventoryHovered = false;

  // MouseRegion callbacks run while Flutter updates its mouse annotation tree.
  // Rebuilding from that synchronous pass can recursively re-enter MouseTracker
  // on Windows, so schedule the visual hover response for the next frame.
  void _setHover({required bool quests, required bool value}) {
    final current = quests ? _questsHovered : _inventoryHovered;
    if (current == value) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final latest = quests ? _questsHovered : _inventoryHovered;
      if (latest == value) return;
      setState(() {
        if (quests) {
          _questsHovered = value;
        } else {
          _inventoryHovered = value;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SideIconButton(
          label: 'Quests',
          icon: Icons.map,
          color: const Color(0xFFF9E2AF),
          isHovered: _questsHovered,
          onHoverChange: (v) => _setHover(quests: true, value: v),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _SideIconButton(
          label: 'Inventory',
          icon: Icons.inventory_2,
          color: const Color(0xFFFAB387),
          isHovered: _inventoryHovered,
          onHoverChange: (v) => _setHover(quests: false, value: v),
          onTap: () {},
        ),
      ],
    );
  }
}

class _SideIconButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isHovered;
  final ValueChanged<bool> onHoverChange;
  final VoidCallback onTap;

  const _SideIconButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isHovered,
    required this.onHoverChange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isHovered ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 64,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xDD122040),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF6B5A3E), width: 1.5),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
