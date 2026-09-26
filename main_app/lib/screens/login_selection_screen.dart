import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/premium_ui.dart';
import 'onboarding_screen.dart';
import 'parent_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: WorldBackdrop(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text('KnowledgeVerse',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onSurface)),
                    const SizedBox(height: 8),
                    Text('Begin your next learning adventure.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                            color: AppColors.textSecondary, fontSize: 16)),
                    const SizedBox(height: 32),
                    LayoutBuilder(builder: (context, constraints) {
                      final child = _RoleCard(
                        icon: Icons.explore_rounded,
                        title: 'Child explorer',
                        subtitle: 'Explore your world and continue learning.',
                        cta: 'Enter my world',
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OnboardingScreen()),
                        ),
                      );
                      final parent = _RoleCard(
                        icon: Icons.family_restroom_rounded,
                        title: 'Parent guide',
                        subtitle: 'See progress and support the next step.',
                        cta: 'View progress',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ParentLoginScreen()),
                        ),
                      );
                      if (constraints.maxWidth < 580) {
                        return Column(
                            children: [child, const SizedBox(height: 16), parent]);
                      }
                      return Row(children: [
                        Expanded(child: child),
                        const SizedBox(width: 20),
                        Expanded(child: parent),
                      ]);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 7),
            Text(subtitle,
                style: GoogleFonts.manrope(
                    color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            Row(children: [
              Text(cta,
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary, fontWeight: FontWeight.w800)),
              const SizedBox(width: 7),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.primary, size: 19),
            ]),
          ],
        ),
      );
}
