import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/buildings/building_data.dart';
import '../game/managers/building_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_ui.dart';
import 'subject_dashboard_screen.dart';

class MapListScreen extends StatefulWidget {
  final VoidCallback? onBackToWorld;

  const MapListScreen({super.key, this.onBackToWorld});

  @override
  State<MapListScreen> createState() => _MapListScreenState();
}

class _MapListScreenState extends State<MapListScreen> {
  String _filter = 'All';

  void _handleSubjectTap(BuildingData building) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectDashboardScreen(
          subjectName: building.name,
          themeColor: building.themeColor,
        ),
      ),
    );
  }

  List<BuildingData> _filteredBuildings(List<BuildingData> all) {
    if (_filter == 'Calculus') {
      return all
          .where((b) =>
              b.name.contains('Derivation') || b.name.contains('Integration'))
          .toList();
    }
    if (_filter == 'Foundation') {
      return all
          .where((b) =>
              b.name.contains('Algebra') ||
              b.name.contains('Geometry') ||
              b.name.contains('Arithmetic') ||
              b.name.contains('Trigonometry'))
          .toList();
    }
    if (_filter == 'Active') {
      return all.where((b) => b.unlocked && b.currentXp > 0).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WorldBackdrop(
        child: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: BuildingManager(),
            builder: (context, _) {
              final all = BuildingManager().allBuildings;
              final buildings = _filteredBuildings(all);
              final totalXp = all.fold<int>(0, (sum, b) => sum + b.currentXp);
              final unlockedCount = all.where((b) => b.unlocked).length;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 850;
                  final horizontalPadding = isWide ? 36.0 : 18.0;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: CustomScrollView(
                        slivers: [
                          // Header Section
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                20,
                                horizontalPadding,
                                14,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Back to World',
                                        onPressed: () {
                                          if (widget.onBackToWorld != null) {
                                            widget.onBackToWorld!();
                                          } else {
                                            Navigator.of(context).maybePop();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          color: AppColors.onSurface,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Color(0xFFE2EAE5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Mathematics Realms',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Explore the syllabus and master core concepts for every house.',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Clean Overview Banner (No extra icons)
                                  _RealmOverviewBanner(
                                    totalRealms: all.length,
                                    unlockedRealms: unlockedCount,
                                    totalXp: totalXp,
                                  ),
                                  const SizedBox(height: 16),

                                  // Clean Filter Pills (No extra icons)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _FilterChip(
                                          label: 'All Houses (${all.length})',
                                          isSelected: _filter == 'All',
                                          onTap: () =>
                                              setState(() => _filter = 'All'),
                                        ),
                                        const SizedBox(width: 8),
                                        _FilterChip(
                                          label: 'Calculus',
                                          isSelected: _filter == 'Calculus',
                                          onTap: () => setState(
                                              () => _filter = 'Calculus'),
                                        ),
                                        const SizedBox(width: 8),
                                        _FilterChip(
                                          label: 'Foundation',
                                          isSelected: _filter == 'Foundation',
                                          onTap: () => setState(
                                              () => _filter = 'Foundation'),
                                        ),
                                        const SizedBox(width: 8),
                                        _FilterChip(
                                          label: 'In Progress',
                                          isSelected: _filter == 'Active',
                                          onTap: () => setState(
                                              () => _filter = 'Active'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                              ),
                            ),
                          ),

                          // Districts Grid / List
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              kNavBarReserve + 32,
                            ),
                            sliver: isWide
                                ? SliverGrid(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 18,
                                      mainAxisSpacing: 18,
                                      childAspectRatio: 1.08,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => _HouseSyllabusCard(
                                        building: buildings[index],
                                        onTap: () => _handleSubjectTap(
                                            buildings[index]),
                                      ),
                                      childCount: buildings.length,
                                    ),
                                  )
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 18),
                                        child: _HouseSyllabusCard(
                                          building: buildings[index],
                                          onTap: () => _handleSubjectTap(
                                              buildings[index]),
                                        ),
                                      ),
                                      childCount: buildings.length,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HouseSyllabusInfo {
  final String imagePath;
  final String syllabusTitle;
  final List<String> topics;

  const _HouseSyllabusInfo({
    required this.imagePath,
    required this.syllabusTitle,
    required this.topics,
  });
}

_HouseSyllabusInfo _getHouseSyllabus(String name) {
  final n = name.toLowerCase();
  if (n.contains('derivation')) {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_derivation.jpg',
      syllabusTitle: 'Differential Calculus & Derivatives',
      topics: [
        'Tangents & Slopes',
        'Instantaneous Rates',
        'Power & Chain Rule',
        'Optimization',
      ],
    );
  } else if (n.contains('integration')) {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_integration.jpg',
      syllabusTitle: 'Integral Calculus & Area',
      topics: [
        'Definite Integrals',
        'Area Under Curves',
        'Riemann Sums',
        'Antiderivatives',
      ],
    );
  } else if (n.contains('trigonometry')) {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_trigonometry.jpg',
      syllabusTitle: 'Trigonometry & Unit Circle',
      topics: [
        'Unit Circle (0-360°)',
        'Sin, Cos, Tan Ratios',
        'Radians & Degrees',
        'Wave Functions',
      ],
    );
  } else if (n.contains('algebra')) {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_algebra.jpg',
      syllabusTitle: 'Algebra & Equations',
      topics: [
        'Simple Equations',
        'Solving for x',
        'Quadratic Formula',
        'Parabola Curves',
      ],
    );
  } else if (n.contains('geometry')) {
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_geometry.jpg',
      syllabusTitle: 'Geometry & Angles',
      topics: [
        'Lines & Transversals',
        'Triangles & Angles',
        'Circles & Area (πr²)',
        '3D Polygons',
      ],
    );
  } else {
    // Arithmetic
    return const _HouseSyllabusInfo(
      imagePath: 'assets/images/syllabus_arithmetic.jpg',
      syllabusTitle: 'Arithmetic & Number Systems',
      topics: [
        'Integers & Number Line',
        'Fractions & Decimals',
        'PEMDAS Order',
        'Prime Numbers',
      ],
    );
  }
}

class _HouseSyllabusCard extends StatelessWidget {
  const _HouseSyllabusCard({
    required this.building,
    required this.onTap,
  });

  final BuildingData building;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = building.progressRatio;
    final color = building.themeColor;
    final syllabus = _getHouseSyllabus(building.name);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Clean Unobstructed Syllabus Picture Banner (No overlapping badges)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 165,
                  width: double.infinity,
                  child: Image.asset(
                    syllabus.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: color.withValues(alpha: 0.15),
                      child: Center(
                        child: Text(
                          building.name,
                          style: GoogleFonts.plusJakartaSans(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Card Content Area
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // House Name + Level Tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                building.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                syllabus.syllabusTitle,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LVL ${building.level}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Description
                    Text(
                      building.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Syllabus Topic Pills (Clean text chips, no icons)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: syllabus.topics.map((topic) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE2EBE5),
                            ),
                          ),
                          child: Text(
                            topic,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Progress Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${building.currentXp} / ${building.xpRequired} XP',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}% Mastered',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Footer Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${building.lessonsAvailable} Lessons Available',
                          style: GoogleFonts.manrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'ENTER REALM →',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: color,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RealmOverviewBanner extends StatelessWidget {
  const _RealmOverviewBanner({
    required this.totalRealms,
    required this.unlockedRealms,
    required this.totalXp,
  });

  final int totalRealms;
  final int unlockedRealms;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF133E2B),
            Color(0xFF1E5B3D),
            Color(0xFF164831),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF133E2B).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _BannerMetric(
              label: 'Realms Open',
              value: '$unlockedRealms / $totalRealms',
              accentColor: const Color(0xFF86E2A5),
            ),
          ),
          Container(
            width: 1,
            height: 34,
            color: Colors.white.withValues(alpha: 0.18),
          ),
          Expanded(
            child: _BannerMetric(
              label: 'Campus XP',
              value: '$totalXp XP',
              accentColor: const Color(0xFFFFD167),
            ),
          ),
          Container(
            width: 1,
            height: 34,
            color: Colors.white.withValues(alpha: 0.18),
          ),
          Expanded(
            child: _BannerMetric(
              label: 'Curriculum',
              value: 'Mathematics',
              accentColor: const Color(0xFF9FD9FF),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerMetric extends StatelessWidget {
  const _BannerMetric({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: accentColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFD6E3DC),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.20),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
