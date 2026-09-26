import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HudBar extends StatelessWidget {
  const HudBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Left: Player Level + XP
            _HudPill(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'LVL 14',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '840/1200 XP',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: const SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(
                            value: 0.7,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryContainer),
                            minHeight: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Center / Right: Resource Pills (Coins, Gems, Energy⚡, XP)
            const Row(
              children: [
                _ResourcePill(
                  icon: Icons.monetization_on_rounded,
                  value: '1,240',
                  bgColor: AppColors.secondaryContainer,
                  iconColor: AppColors.onSecondaryContainer,
                  borderColor: AppColors.secondary,
                ),
                SizedBox(width: 6),
                _ResourcePill(
                  icon: Icons.diamond_rounded,
                  value: '24',
                  bgColor: AppColors.dangerSoft,
                  iconColor: Colors.white,
                  borderColor: AppColors.error,
                ),
                SizedBox(width: 6),
                _ResourcePill(
                  icon: Icons.bolt_rounded,
                  value: '100/100',
                  bgColor: Color(0xFFFFD167),
                  iconColor: Color(0xFF765900),
                  borderColor: Color(0xFFD49B00),
                ),
                SizedBox(width: 6),
                _ResourcePill(
                  icon: Icons.school_rounded,
                  value: '450 XP',
                  bgColor: AppColors.tertiaryContainer,
                  iconColor: AppColors.onTertiaryContainer,
                  borderColor: AppColors.tertiary,
                ),
              ],
            ),

            const SizedBox(width: 10),

            // Right: Notification Bell & Quick Profile
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: AppColors.outlineVariant, width: 1),
              ),
              child: const Icon(Icons.notifications_rounded,
                  color: AppColors.onSurfaceVariant, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  final Widget child;

  const _HudPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.6), width: 1),
      ),
      child: child,
    );
  }
}

class _ResourcePill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color bgColor;
  final Color iconColor;
  final Color borderColor;

  const _ResourcePill({
    required this.icon,
    required this.value,
    required this.bgColor,
    required this.iconColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border(bottom: BorderSide(color: borderColor, width: 2.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
