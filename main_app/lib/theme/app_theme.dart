import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vertical space the HUD bar occupies at the top of every game screen.
const double kHudBarHeight = 70;

/// Vertical space reserved at the bottom so the floating nav never covers content.
const double kNavBarReserve = 70;

class AppColors {
  // Primary
  static const Color primary = Color(0xFF1b6d22);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFF7acb74);
  static const Color onPrimaryContainer = Color(0xFF005611);
  static const Color primaryFixed = Color(0xFFa3f69a);
  static const Color primaryFixedDim = Color(0xFF88da81);

  // Secondary (Gold)
  static const Color secondary = Color(0xFF785a00);
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFffd167);
  static const Color onSecondaryContainer = Color(0xFF765900);
  static const Color secondaryFixed = Color(0xFFffdf9b);
  static const Color secondaryFixedDim = Color(0xFFedc157);

  // Tertiary (XP/Teal)
  static const Color tertiary = Color(0xFF006973);
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFF44c9da);
  static const Color onTertiaryContainer = Color(0xFF00515a);
  static const Color tertiaryFixed = Color(0xFF93f1ff);

  // Surface
  static const Color surface = Color(0xFFf7f9fb);
  static const Color surfaceBright = Color(0xFFf7f9fb);
  static const Color surfaceDim = Color(0xFFd8dadc);
  static const Color surfaceContainerLowest = Colors.white;
  static const Color surfaceContainerLow = Color(0xFFf2f4f6);
  static const Color surfaceContainer = Color(0xFFeceef0);
  static const Color surfaceContainerHigh = Color(0xFFe6e8ea);
  static const Color surfaceContainerHighest = Color(0xFFe0e3e5);

  // On Surface
  static const Color onSurface = Color(0xFF191c1e);
  static const Color onSurfaceVariant = Color(0xFF40493d);

  // Misc
  static const Color background = Color(0xFFf7f9fb);
  static const Color onBackground = Color(0xFF191c1e);
  static const Color outline = Color(0xFF707a6c);
  static const Color outlineVariant = Color(0xFFbfcab9);
  static const Color skyBlue = Color(0xFF9FD9FF);
  static const Color woodBrown = Color(0xFF8D6E63);
  static const Color roadTan = Color(0xFFCBB58B);
  static const Color stonSlate = Color(0xFFAAB2BD);
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color dangerSoft = Color(0xFFF28B82);
  static const Color onDangerSoft = Color(0xFF410002);
  static const Color error = Color(0xFFba1a1a);
  static const Color errorContainer = Color(0xFFffdad6);
  static const Color onErrorContainer = Color(0xFF410002);
  static const Color onError = Colors.white;
  static const Color inverseSurface = Color(0xFF2d3133);
  static const Color inverseOnSurface = Color(0xFFeff1f3);
  static const Color inversePrimary = Color(0xFF88da81);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: _buildTextTheme(),
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 40,
        height: 48 / 40,
        color: AppColors.onSurface,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 38 / 32,
        color: AppColors.onSurface,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        color: AppColors.onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: AppColors.onSurface,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 28 / 18,
        color: AppColors.onSurface,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
        color: AppColors.onSurface,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.05 * 14,
        height: 20 / 14,
        color: AppColors.onSurface,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        color: AppColors.onSurface,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05 * 10,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
