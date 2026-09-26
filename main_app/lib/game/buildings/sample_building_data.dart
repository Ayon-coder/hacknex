import 'package:flutter/material.dart';
import '../../config/asset_paths.dart';
import 'building_data.dart';

/// Central registry providing pre-configured specs for all campus Mathematics Houses
/// where each house specializes in a distinct branch of Mathematics:
/// - Derivation House (Differential Calculus)
/// - Integration House (Integral Calculus)
/// - Trigonometry House (Trigonometry)
/// - Algebra House (Algebra & Equations)
/// - Geometry House (Geometry & Vectors)
/// - Arithmetic House (Arithmetic & Number Theory)
abstract final class SampleBuildingData {
  /// 1. Derivation House — Differential Calculus (North).
  static const BuildingData derivationHouse = BuildingData(
    id: 'derivation_house',
    name: 'Derivation House',
    icon: Icons.trending_up,
    sprite: AssetPaths.buildingGrandHall,
    level: 1,
    subject: 'Mathematics - Derivation',
    description: 'Master differential calculus, instantaneous rates of change, tangents, power rule, product rule, and chain rule.',
    unlocked: true,
    currentXp: 100,
    xpRequired: 300,
    lessonsAvailable: 20,
    themeColor: Color(0xFFCBA6F7),
  );

  /// 2. Integration House — Integral Calculus (North West).
  static const BuildingData integrationHouse = BuildingData(
    id: 'integration_house',
    name: 'Integration House',
    icon: Icons.area_chart,
    sprite: AssetPaths.buildingLibrary,
    level: 1,
    subject: 'Mathematics - Integration',
    description: 'Master integral calculus, antiderivatives, area under curves, definite integrals, and Riemann sums.',
    unlocked: true,
    currentXp: 200,
    xpRequired: 300,
    lessonsAvailable: 15,
    themeColor: Color(0xFF89B4FA),
  );

  /// 3. Trigonometry House — Angles & Functions (North East).
  static const BuildingData trigonometryHouse = BuildingData(
    id: 'trigonometry_house',
    name: 'Trigonometry House',
    icon: Icons.change_history,
    sprite: AssetPaths.buildingAstronomyTower,
    level: 1,
    subject: 'Mathematics - Trigonometry',
    description: 'Explore sine, cosine, tangent ratios, unit circle trigonometry, radians, and trigonometric identities.',
    unlocked: true,
    currentXp: 100,
    xpRequired: 300,
    lessonsAvailable: 15,
    themeColor: Color(0xFF89DCEB),
  );

  /// 4. Algebra House — Equations & Polynomials (West).
  static const BuildingData algebraHouse = BuildingData(
    id: 'algebra_house',
    name: 'Algebra House',
    icon: Icons.calculate,
    sprite: AssetPaths.buildingDuelArena,
    level: 1,
    subject: 'Mathematics - Algebra',
    description: 'Solve linear and quadratic equations, factoring polynomials, systems of equations, and logarithms.',
    unlocked: true,
    currentXp: 100,
    xpRequired: 300,
    lessonsAvailable: 18,
    themeColor: Color(0xFFFAB387),
  );

  /// 5. Geometry House — Shapes, Proofs & Vectors (South West).
  static const BuildingData geometryHouse = BuildingData(
    id: 'geometry_house',
    name: 'Geometry House',
    icon: Icons.square_foot,
    sprite: AssetPaths.buildingAlchemyLab,
    level: 1,
    subject: 'Mathematics - Geometry',
    description: 'Discover Euclidean proofs, coordinate geometry, 2D/3D vectors, angles, perimeter, and circle geometry.',
    unlocked: true,
    currentXp: 50,
    xpRequired: 300,
    lessonsAvailable: 14,
    themeColor: Color(0xFFA6E3A1),
  );

  /// 6. Arithmetic House — Numbers & Sequences (South East).
  static const BuildingData arithmeticHouse = BuildingData(
    id: 'arithmetic_house',
    name: 'Arithmetic House',
    icon: Icons.pin,
    sprite: AssetPaths.buildingCodingTower,
    level: 1,
    subject: 'Mathematics - Arithmetic',
    description: 'Sharpen mental arithmetic, prime factorization, fractions, percentages, orders of operation, and number sequences.',
    unlocked: true,
    currentXp: 150,
    xpRequired: 300,
    lessonsAvailable: 20,
    themeColor: Color(0xFFF38BA8),
  );

  /// List of all Mathematics Houses across the campus.
  static List<BuildingData> get allBuildings => [
        derivationHouse,
        integrationHouse,
        trigonometryHouse,
        algebraHouse,
        geometryHouse,
        arithmeticHouse,
      ];

  // Backward compatibility aliases
  static const BuildingData grandHall = derivationHouse;
  static const BuildingData library = integrationHouse;
  static const BuildingData astronomyTower = trigonometryHouse;
  static const BuildingData arena = algebraHouse;
  static const BuildingData duelArena = algebraHouse;
  static const BuildingData potionLab = geometryHouse;
  static const BuildingData alchemyLab = geometryHouse;
  static const BuildingData scienceLab = geometryHouse;
  static const BuildingData codingTower = arithmeticHouse;
  static const BuildingData historyHall = arithmeticHouse;
  static const BuildingData mathHouse = derivationHouse;
}
