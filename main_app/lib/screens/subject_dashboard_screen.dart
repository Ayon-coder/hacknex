import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/premium_ui.dart';

class _HouseSyllabusInfo {
  final String imagePath;
  final String syllabusTitle;
  final List<String> topics;
  final String formulaSnippet;

  const _HouseSyllabusInfo({
    required this.imagePath,
    required this.syllabusTitle,
    required this.topics,
    required this.formulaSnippet,
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
      formulaSnippet: 'dy/dx = lim Δy/Δx',
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
      formulaSnippet: '∫ f(x) dx = F(b) - F(a)',
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
      formulaSnippet: 'sin²θ + cos²θ = 1',
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
      formulaSnippet: 'x = (-b ± √(b²-4ac))/2a',
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
      formulaSnippet: 'a² + b² = c² • A = πr²',
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
      formulaSnippet: '-a × -b = +ab • p/q',
    );
  }
}

class SubjectDashboardScreen extends StatelessWidget {
  final String subjectName;
  final Color themeColor;

  const SubjectDashboardScreen({
    super.key,
    required this.subjectName,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final syllabus = _getHouseSyllabus(subjectName);

    final List<Map<String, dynamic>> items = [
      {
        'title': 'Core Lessons',
        'subtitle': 'Theorems, proofs & step-by-step concepts',
        'icon': Icons.menu_book_rounded,
        'reward': '+60 XP',
        'tag': 'Essential',
        'color': themeColor,
      },
      {
        'title': 'Realm Quests',
        'subtitle': 'Applied challenge problems & missions',
        'icon': Icons.explore_rounded,
        'reward': '+120 XP',
        'tag': 'Practice',
        'color': const Color(0xFF4F46E5),
      },
      {
        'title': 'Interactive Puzzles',
        'subtitle': 'Intuitive visual & logic mini-games',
        'icon': Icons.extension_rounded,
        'reward': '+80 XP',
        'tag': 'Logic',
        'color': const Color(0xFF059669),
      },
      {
        'title': 'Formula Flashcards',
        'subtitle': 'Rapid recall of definitions & rules',
        'icon': Icons.style_rounded,
        'reward': '+40 XP',
        'tag': 'Speed Drill',
        'color': const Color(0xFFD97706),
      },
      {
        'title': 'Mastery Mock Exam',
        'subtitle': 'Timed assessment with instant feedback',
        'icon': Icons.quiz_rounded,
        'reward': '+150 XP',
        'tag': 'Test',
        'color': const Color(0xFFDC2626),
      },
      {
        'title': 'Boss Challenge Arena',
        'subtitle': 'Defeat the Realm Guardian in multi-step tests',
        'icon': Icons.sports_martial_arts_rounded,
        'reward': '+300 XP',
        'tag': 'Epic',
        'color': const Color(0xFF7C3AED),
      },
    ];

    return Scaffold(
      body: WorldBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final horizontalPadding = isWide ? 40.0 : 18.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: CustomScrollView(
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            16,
                            horizontalPadding,
                            14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
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
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subjectName,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        Text(
                                          'Campus Mathematics District • Realm Hub',
                                          style: GoogleFonts.manrope(
                                            fontSize: 12.5,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Syllabus Picture Hero Banner (Clean & Unobstructed)
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: themeColor.withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeColor.withValues(alpha: 0.15),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // High-resolution syllabus image - 100% clean and unobstructed
                                    SizedBox(
                                      height: 190,
                                      width: double.infinity,
                                      child: Image.asset(
                                        syllabus.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: themeColor.withValues(alpha: 0.2),
                                          alignment: Alignment.center,
                                          child: Text(
                                            syllabus.syllabusTitle,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w800,
                                              color: themeColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Syllabus Information & Topics Bar (Clean text, no icons)
                                    Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  syllabus.syllabusTitle,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                    color: AppColors.onSurface,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: themeColor.withValues(alpha: 0.10),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: themeColor.withValues(alpha: 0.30),
                                                  ),
                                                ),
                                                child: Text(
                                                  syllabus.formulaSnippet,
                                                  style: GoogleFonts.firaCode(
                                                    color: themeColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: syllabus.topics
                                                  .map(
                                                    (topic) => Container(
                                                      margin: const EdgeInsets.only(right: 8),
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
                                                          fontSize: 11.5,
                                                          fontWeight: FontWeight.w700,
                                                          color: AppColors.onSurface,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),

                              Text(
                                'Interactive Curriculum Modules',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),

                      // Modules Grid
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          32,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 3 : 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: isWide ? 1.25 : 1.05,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = items[index];
                              final cardColor = item['color'] as Color;

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: cardColor.withValues(alpha: 0.25),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cardColor.withValues(alpha: 0.06),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(22),
                                          ),
                                          title: Row(
                                            children: [
                                              Icon(
                                                item['icon'] as IconData,
                                                color: cardColor,
                                                size: 26,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                item['title'] as String,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Text(
                                            'Preparing ${item['title']} for $subjectName. Dive into guided challenges and earn ${item['reward']}.',
                                            style: GoogleFonts.manrope(
                                              height: 1.45,
                                            ),
                                          ),
                                          actions: [
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: cardColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text('Start Quest'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: cardColor.withValues(
                                                      alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  item['icon'] as IconData,
                                                  color: cardColor,
                                                  size: 24,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F3),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  item['reward'] as String,
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 10.5,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Text(
                                            item['title'] as String,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            item['subtitle'] as String,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.manrope(
                                              fontSize: 11,
                                              height: 1.35,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: items.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
