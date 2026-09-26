import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/player_profile.dart';
import '../theme/app_theme.dart';
import 'world_generation_screen.dart';

const int _kStepCount = 5;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final Set<int> _selectedDistrictIndices = {0};
  int _selectedAvatarIndex = 0;
  String _grade = 'Class 10';
  String _curriculum = 'CBSE';
  String _difficulty = 'Balanced';
  int _selectedThemeIndex = 0;

  static const List<String> _grades = [
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
  ];

  static const List<String> _curriculums = [
    'CBSE',
    'ICSE',
    'IB',
    'Cambridge',
    'State Board',
  ];

  static const List<Map<String, String>> _difficulties = [
    {
      'label': 'Gentle',
      'desc': 'Steady pace, extra guidance',
    },
    {
      'label': 'Balanced',
      'desc': 'A fair climb with real challenge',
    },
    {
      'label': 'Challenging',
      'desc': 'Steep, fast, for the ambitious',
    },
  ];

  static const List<Map<String, dynamic>> _themes = [
    {
      'name': 'Green Highlands',
      'icon': Icons.landscape_rounded,
      'color': Color(0xFF7acb74),
      'textColor': Color(0xFF005611),
    },
    {
      'name': 'Desert Kingdom',
      'icon': Icons.wb_sunny_rounded,
      'color': Color(0xFFFFD167),
      'textColor': Color(0xFF765900),
    },
    {
      'name': 'Frozen Peaks',
      'icon': Icons.ac_unit_rounded,
      'color': Color(0xFF44c9da),
      'textColor': Color(0xFF00515a),
    },
    {
      'name': 'Sky Islands',
      'icon': Icons.cloud_rounded,
      'color': Color(0xFF9FD9FF),
      'textColor': Color(0xFF00515a),
    },
  ];

  final List<Map<String, dynamic>> _districts = [
    {
      'title': 'Math House',
      'subject': 'Mathematics',
      'icon': Icons.calculate_rounded,
      'color': const Color(0xFF7acb74),
      'textColor': const Color(0xFF005611),
    },
    {
      'title': 'Royal Archives',
      'subject': 'History',
      'icon': Icons.castle_rounded,
      'color': const Color(0xFFFFD167),
      'textColor': const Color(0xFF765900),
    },
    {
      'title': 'Science Lab',
      'subject': 'Physics',
      'icon': Icons.science_rounded,
      'color': const Color(0xFF44c9da),
      'textColor': const Color(0xFF00515a),
    },
    {
      'title': 'Library Tower',
      'subject': 'Literature',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFF28B82),
      'textColor': const Color(0xFF93000a),
    },
  ];

  final List<IconData> _avatars = [
    Icons.face_retouching_natural_rounded,
    Icons.smart_toy_rounded,
    Icons.auto_awesome_rounded,
    Icons.military_tech_rounded,
  ];

  PlayerProfile _buildProfile() {
    final name = _nameController.text.trim();
    return PlayerProfile(
      name: name.isEmpty ? 'Explorer' : name,
      grade: _grade,
      curriculum: _curriculum,
      subjects: _selectedDistrictIndices
          .map((i) => _districts[i]['subject'] as String)
          .toList(),
      difficulty: _difficulty,
      worldTheme: _themes[_selectedThemeIndex]['name'] as String,
      learningGoal: _goalController.text.trim(),
      avatarIndex: _selectedAvatarIndex,
    );
  }

  Future<void> _nextStep() async {
    if (_currentStep < _kStepCount - 1) {
      FocusScope.of(context).unfocus();
      setState(() => _currentStep++);
      return;
    }

    final profile = _buildProfile();
    await profile.save();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WorldGenerationScreen(profile: profile),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1B6D22),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: LayoutBuilder(
              builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;
                return Flex(
                  direction: compact ? Axis.vertical : Axis.horizontal,
          children: [
            // ── LEFT PANEL (38%) ─────────────────────────────────────
            Expanded(
              flex: compact ? 42 : 38,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF9FD9FF),
                      Color(0xFF7ACB74),
                      Color(0xFF1B6D22),
                    ],
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars_rounded,
                                  color: AppColors.secondary, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                'EXPLORER CREATION',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                  letterSpacing: 1.0,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      if (!compact) const Spacer(),

                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          _avatars[_selectedAvatarIndex],
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ).animate().scale(
                          duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 10),

                      Text(
                        _nameController.text.trim().isEmpty
                            ? 'Unknown Traveler'
                            : _nameController.text.trim(),
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Level 1 Civilization Architect',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Live summary of what's been chosen so far.
                      _ProfileSummary(
                        grade: _grade,
                        curriculum: _curriculum,
                        difficulty: _difficulty,
                        theme: _themes[_selectedThemeIndex]['name'] as String,
                        subjectCount: _selectedDistrictIndices.length,
                        visibleFromStep: _currentStep,
                      ),

                      if (!compact) const Spacer(),
                    ],
                  ),
                ),
              ),
            ),

            // ── RIGHT PANEL (62%) ────────────────────────────────────
            Expanded(
              flex: compact ? 58 : 62,
              child: Container(
                color: AppColors.surface,
                padding: EdgeInsets.symmetric(
                    horizontal: compact ? 20 : 28, vertical: compact ? 10 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STEP ${_currentStep + 1} OF $_kStepCount',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1.5,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          children: List.generate(_kStepCount, (index) {
                            final isActive = index == _currentStep;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(left: 5),
                              width: isActive ? 20 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primaryContainer
                                    : AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: SingleChildScrollView(
                          key: ValueKey(_currentStep),
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: compact ? double.infinity : 620,
                            ),
                            child: _buildStepContent(),
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          TextButton.icon(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() => _currentStep--);
                            },
                            icon:
                                const Icon(Icons.arrow_back_rounded, size: 16),
                            label: Text(
                              'Back',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        GestureDetector(
                          onTap: _nextStep,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.primary,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              _currentStep == _kStepCount - 1
                                  ? 'Generate My World 🚀'
                                  : 'Continue →',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _StepShell(
          key: const ValueKey(0),
          title: 'What should we call you, Explorer?',
          subtitle: 'Your name will be inscribed in the Royal Archives.',
          children: [
            _FieldBox(
              child: TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                maxLength: 24,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.edit_rounded,
                      color: AppColors.primary, size: 20),
                  hintText: 'Enter your explorer name...',
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'What do you want to achieve? (optional)',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            _FieldBox(
              child: TextField(
                controller: _goalController,
                textInputAction: TextInputAction.done,
                maxLength: 80,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.flag_rounded,
                      color: AppColors.primary, size: 20),
                  hintText: 'e.g. ace my board exams',
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        );

      case 1:
        return _StepShell(
          key: const ValueKey(1),
          title: 'Which class are you in?',
          subtitle: 'This tunes every lesson to your level and curriculum.',
          children: [
            _ChipGroup(
              options: _grades,
              selected: _grade,
              onSelect: (v) => setState(() => _grade = v),
            ),
            const SizedBox(height: 16),
            Text(
              'Curriculum',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _ChipGroup(
              options: _curriculums,
              selected: _curriculum,
              onSelect: (v) => setState(() => _curriculum = v),
            ),
          ],
        );

      case 2:
        return _StepShell(
          key: const ValueKey(2),
          title: 'Choose Your Starter Districts',
          subtitle: 'Select the domains where your civilization begins.',
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.0,
              ),
              itemCount: _districts.length,
              itemBuilder: (context, index) {
                final d = _districts[index];
                final isSelected = _selectedDistrictIndices.contains(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        // Always leave at least one district selected.
                        if (_selectedDistrictIndices.length > 1) {
                          _selectedDistrictIndices.remove(index);
                        }
                      } else {
                        _selectedDistrictIndices.add(index);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (d['color'] as Color).withValues(alpha: 0.25)
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? d['color'] as Color
                            : AppColors.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: d['color'] as Color,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(d['icon'] as IconData,
                              color: d['textColor'] as Color, size: 17),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['title'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                d['subject'] as String,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  color: d['textColor'] as Color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              size: 18, color: d['textColor'] as Color),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );

      case 3:
        return _StepShell(
          key: const ValueKey(3),
          title: 'How steep should the climb be?',
          subtitle: 'You can change this later from Settings.',
          children: [
            ..._difficulties.map((d) {
              final label = d['label']!;
              final isSelected = _difficulty == label;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer.withValues(alpha: 0.25)
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 20,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                d['desc']!,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );

      case 4:
        return _StepShell(
          key: const ValueKey(4),
          title: 'Shape your world',
          subtitle: 'Pick the land your civilization will rise from.',
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.05,
              ),
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                final t = _themes[index];
                final isSelected = index == _selectedThemeIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedThemeIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (t['color'] as Color).withValues(alpha: 0.3)
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? t['color'] as Color
                            : AppColors.outlineVariant,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(t['icon'] as IconData,
                            size: 26, color: t['textColor'] as Color),
                        const SizedBox(height: 6),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            t['name'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Your Explorer Emblem',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_avatars.length, (index) {
                final isSelected = index == _selectedAvatarIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatarIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        width: isSelected ? 3 : 1.5,
                      ),
                    ),
                    child: Icon(
                      _avatars[index],
                      size: 26,
                      color: isSelected
                          ? AppColors.onPrimaryContainer
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// Title + subtitle + body, shared by every onboarding step.
class _StepShell extends StatelessWidget {
  const _StepShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              option,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: isSelected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Choices made so far, revealed on the left panel as the player progresses.
class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({
    required this.grade,
    required this.curriculum,
    required this.difficulty,
    required this.theme,
    required this.subjectCount,
    required this.visibleFromStep,
  });

  final String grade;
  final String curriculum;
  final String difficulty;
  final String theme;
  final int subjectCount;
  final int visibleFromStep;

  @override
  Widget build(BuildContext context) {
    final rows = <_SummaryRow>[
      if (visibleFromStep >= 2)
        _SummaryRow(Icons.school_rounded, '$grade · $curriculum'),
      if (visibleFromStep >= 3)
        _SummaryRow(Icons.widgets_rounded,
            '$subjectCount district${subjectCount == 1 ? '' : 's'}'),
      if (visibleFromStep >= 4) _SummaryRow(Icons.trending_up_rounded, difficulty),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
