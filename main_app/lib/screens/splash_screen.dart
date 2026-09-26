import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_profile.dart';
import '../theme/app_theme.dart';
import 'login_selection_screen.dart';
import 'world_archipelago_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _rotateAnimation = Tween<double>(begin: -0.025, end: 0.025).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _beginAdventure() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginSelectionScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  /// Returning players skip onboarding; first-timers are sent through it so
  /// they never land in an empty world.
  Future<void> _continueExisting() async {
    final profile = await PlayerProfile.load();
    if (!mounted) return;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No world found yet — let’s create yours first.'),
          duration: Duration(seconds: 2),
        ),
      );
      _beginAdventure();
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WorldArchipelagoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background atmospheric landscape
          Image.asset(
            'assets/images/splash_background.jpg',
            fit: BoxFit.cover,
            color: Colors.white.withValues(alpha: 0.15),
            colorBlendMode: BlendMode.lighten,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF9FD9FF),
                      Color(0xFFd4f0d4),
                      Color(0xFFf7f9fb),
                    ],
                  ),
                ),
              );
            },
          ),

          // Light overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),

          // Floating island
          Positioned(
            top: size.height * 0.1,
            left: 0,
            right: 0,
            height: size.height * 0.5,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatAnimation.value),
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/floating_island.jpg',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return const _IslandPlaceholder();
                },
              ),
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 900.ms),

          // HUD top decoration
          Positioned(
            top: 56,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Level 1 Traveler',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 1400.ms).slideY(begin: -0.5),

          // Bottom content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'THE JOURNEY BEGINS',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5),

                  const SizedBox(height: 16),

                  // Title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome to\n',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 34,
                            height: 1.2,
                            color: AppColors.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: 'KnowledgeVerse',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 34,
                            height: 1.2,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.3),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Every lesson you master shapes the\narchitecture of your own civilization.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 1200.ms),

                  const SizedBox(height: 32),

                  // Keep CTAs deliberately compact on wide desktop displays.
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _beginAdventure,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.primary,
                                  offset: Offset(0, 5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.explore_rounded,
                                    color: AppColors.onPrimaryContainer, size: 20),
                                const SizedBox(width: 8),
                                Text('Begin Adventure',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppColors.onPrimaryContainer)),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 1300.ms).slideY(begin: 0.3),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.surfaceContainerHighest,
                              width: 2,
                            ),
                          ),
                          child: TextButton(
                            onPressed: _continueExisting,
                            style: TextButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text('I Already Have a World',
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.onSurface)),
                          ),
                        ).animate().fadeIn(delay: 1400.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.public_rounded,
                        color: AppColors.onSurfaceVariant,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '1.2M Civilizations Active',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Education First',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IslandPlaceholder extends StatelessWidget {
  const _IslandPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryFixed,
            AppColors.primaryContainer,
            AppColors.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.castle_rounded, size: 80, color: Colors.white),
      ),
    );
  }
}
