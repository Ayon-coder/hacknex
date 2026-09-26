import 'package:flutter/material.dart';
import '../../buildings/building_data.dart';
import '../../managers/building_manager.dart';

/// Clash of Clans style Building Action Panel featuring floating card design,
/// scale + fade entrance animations, building level & XP progress, subject domain,
/// available lesson count, description, and interactive action buttons.
class BuildingActionPanel extends StatefulWidget {
  final BuildingData building;
  final VoidCallback onClose;
  final VoidCallback? onLearn;

  const BuildingActionPanel({
    super.key,
    required this.building,
    required this.onClose,
    this.onLearn,
  });

  @override
  State<BuildingActionPanel> createState() => _BuildingActionPanelState();
}

class _BuildingActionPanelState extends State<BuildingActionPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animController.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    final building = widget.building;

    return GestureDetector(
      onTap: _dismiss, // Clicking outside panel closes it
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {}, // Prevent taps inside panel from closing
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 390,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.88,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: building.themeColor,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: building.themeColor.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    const BoxShadow(
                      color: Colors.black54,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Header Section ---
                      _buildHeader(building),

                      const Divider(color: Color(0xFF313244), height: 1),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Subject & Lessons Available Badges ---
                          _buildSubjectAndLessonsRow(building),

                          const SizedBox(height: 14),

                          // --- XP Progress Bar ---
                          _buildXpBar(building),

                          const SizedBox(height: 16),

                          // --- Description Block ---
                          Text(
                            building.description,
                            style: const TextStyle(
                              color: Color(0xFFCDD6F4),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- Action Buttons ---
                          _buildActionButtons(building),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  /// Builds top header row with building icon badge, name, level badge, and close button.
  Widget _buildHeader(BuildingData building) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF181825),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: building.themeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: building.themeColor, width: 1.5),
            ),
            child: Icon(building.icon, color: building.themeColor, size: 24),
          ),
          const SizedBox(width: 14),

          // Name and Level Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  building.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAB387).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFAB387), width: 1),
                  ),
                  child: Text(
                    'LEVEL ${building.level}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFAB387),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close button "X"
          InkWell(
            onTap: _dismiss,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF313244),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const Icon(Icons.close, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds row displaying Subject domain tag and Available Lesson Count from BuildingData.
  Widget _buildSubjectAndLessonsRow(BuildingData building) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: building.themeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: building.themeColor.withValues(alpha: 0.5), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category, size: 12, color: building.themeColor),
              const SizedBox(width: 4),
              Text(
                building.subject.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: building.themeColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(Icons.menu_book, size: 13, color: Color(0xFFA6ADC8)),
            const SizedBox(width: 4),
            Text(
              '${building.lessonsAvailable} Lessons',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCDD6F4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds XP Progress Bar row using currentXp and xpRequired from BuildingData.
  Widget _buildXpBar(BuildingData building) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'XP PROGRESS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA6ADC8),
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${building.currentXp} / ${building.xpRequired} XP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: building.themeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                height: 12,
                color: const Color(0xFF313244),
              ),
              FractionallySizedBox(
                widthFactor: building.progressRatio,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        building.themeColor,
                        const Color(0xFFA6E3A1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds Action Buttons: Learn & Functional Glowing Upgrade button.
  Widget _buildActionButtons(BuildingData building) {
    final bool canUpgrade = building.canUpgrade;
    final bool isMaxLevel = building.level >= 3;

    return Row(
      children: [
        // --- LEARN BUTTON ---
        Expanded(
          flex: 5,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: building.themeColor,
              foregroundColor: const Color(0xFF181825),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.school, size: 18),
            label: const Text(
              'LEARN',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
            onPressed: () {
              _dismiss();
              widget.onLearn?.call();
            },
          ),
        ),
        const SizedBox(width: 10),

        // --- UPGRADE BUTTON ---
        Expanded(
          flex: 5,
          child: Container(
            decoration: canUpgrade
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFA6E3A1),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  )
                : null,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isMaxLevel
                    ? const Color(0xFF313244)
                    : (canUpgrade ? const Color(0xFFA6E3A1) : const Color(0xFF313244)),
                foregroundColor: canUpgrade ? const Color(0xFF181825) : Colors.white38,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: canUpgrade ? 6 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: canUpgrade ? const Color(0xFFA6E3A1) : Colors.white10,
                    width: 1.5,
                  ),
                ),
              ),
              icon: Icon(
                isMaxLevel
                    ? Icons.verified
                    : (canUpgrade ? Icons.arrow_upward : Icons.lock),
                size: 16,
              ),
              label: Text(
                isMaxLevel
                    ? 'MAX LEVEL 3'
                    : (canUpgrade
                        ? 'UPGRADE (Lv.${building.level + 1})'
                        : 'NEED ${building.xpRequired - building.currentXp} XP'),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: canUpgrade ? 11.5 : 10.5,
                  letterSpacing: 0.5,
                ),
              ),
              onPressed: canUpgrade
                  ? () {
                      final bool success = BuildingManager().upgradeBuilding(building.id);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFFA6E3A1),
                            content: Text(
                              'LEVEL UP! ${building.name} upgraded to Level ${building.level + 1}!',
                              style: const TextStyle(
                                color: Color(0xFF181825),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                        _dismiss();
                      }
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
