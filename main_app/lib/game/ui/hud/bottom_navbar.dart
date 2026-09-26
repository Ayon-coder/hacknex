import 'package:flutter/material.dart';

/// Themed bottom navigation bar for the main app navigation.
class BottomNavbarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const BottomNavbarWidget({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      destinationIndex: 0,
    ),
    _NavItem(
      label: 'Learn',
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories,
      destinationIndex: 1,
    ),
    _NavItem(
      label: 'Rank',
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events,
      destinationIndex: 2,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      destinationIndex: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xEE0D1520),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6B5A3E), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final bool isSelected = selectedIndex == item.destinationIndex;
          return GestureDetector(
            onTap: () => onSelect(item.destinationIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1E3A5A)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: const Color(0xFF6B5A3E), width: 1)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      key: ValueKey(isSelected),
                      color: isSelected
                          ? const Color(0xFFF9E2AF)
                          : const Color(0xFF8A9BB0),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFF9E2AF)
                          : const Color(0xFF8A9BB0),
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int destinationIndex;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.destinationIndex,
  });
}
