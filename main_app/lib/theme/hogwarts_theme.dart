import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette and type for the wizarding-world cinematic screens.
///
/// Kept separate from [AppTheme] so the rest of the app keeps its bright
/// civilization look while the intro runs on candlelight and midnight blue.
class HogwartsColors {
  // Night
  static const Color midnight = Color(0xFF070B18);
  static const Color deepNight = Color(0xFF0C1430);
  static const Color duskBlue = Color(0xFF1B2A4E);
  static const Color moonHaze = Color(0xFF3C5580);

  // Candle / gold
  static const Color candle = Color(0xFFFFD98A);
  static const Color candleCore = Color(0xFFFFF3CF);
  static const Color gold = Color(0xFFD4AF37);
  static const Color deepGold = Color(0xFF8C6D1F);
  static const Color emberOrange = Color(0xFFFFA94D);

  // Parchment
  static const Color parchment = Color(0xFFF2E4C4);
  static const Color parchmentDim = Color(0xFFD9C69C);
  static const Color inkBrown = Color(0xFF2B1F10);

  // Castle stone
  static const Color stone = Color(0xFF2A2D3E);
  static const Color stoneLight = Color(0xFF3A3F55);
  static const Color stoneDark = Color(0xFF171A28);
  static const Color roofSlate = Color(0xFF232838);

  // Lake
  static const Color lake = Color(0xFF0A1428);
  static const Color lakeSheen = Color(0xFF1D3355);

  // Houses
  static const Color gryffindorRed = Color(0xFF7F0909);
  static const Color gryffindorGold = Color(0xFFD3A625);
  static const Color slytherinGreen = Color(0xFF1A472A);
  static const Color slytherinSilver = Color(0xFFAAAAAA);
  static const Color ravenclawBlue = Color(0xFF222F5B);
  static const Color ravenclawBronze = Color(0xFF946B2D);
  static const Color hufflepuffYellow = Color(0xFFECB939);
  static const Color hufflepuffBlack = Color(0xFF372E29);
}

/// Type styles for the cinematic. [display] is the engraved-stone voice,
/// [scroll] the handwritten-parchment one.
class HogwartsText {
  /// Carved capitals — titles, crests, buttons.
  static TextStyle display({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w700,
    Color color = HogwartsColors.candle,
    double letterSpacing = 2.0,
    double? height,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      shadows: shadows,
    );
  }

  /// Old-press serif — narration subtitles and status lines.
  static TextStyle scroll({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = HogwartsColors.parchment,
    double letterSpacing = 0.3,
    double? height,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.imFellEnglish(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
      shadows: shadows,
    );
  }

  /// Soft candle bloom applied behind gold text so it reads against night sky.
  static List<Shadow> glow({
    Color color = HogwartsColors.candle,
    double blur = 18,
    double alpha = 0.55,
  }) {
    return [
      Shadow(color: color.withValues(alpha: alpha), blurRadius: blur),
      Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 6),
    ];
  }
}
