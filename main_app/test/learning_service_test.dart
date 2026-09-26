import 'package:flutter_test/flutter_test.dart';
import 'package:hexafalls/models/learning_models.dart';
import 'package:hexafalls/services/learning_service.dart';

void main() {
  const levelOneMathHouses = [
    ('derivation_house', 'Derivation House', 'Mathematics - Derivation'),
    ('integration_house', 'Integration House', 'Mathematics - Integration'),
    ('trigonometry_house', 'Trigonometry House', 'Mathematics - Trigonometry'),
    ('algebra_house', 'Algebra House', 'Mathematics - Algebra'),
    ('geometry_house', 'Geometry House', 'Mathematics - Geometry'),
    ('arithmetic_house', 'Arithmetic House', 'Mathematics - Arithmetic'),
  ];

  for (final house in levelOneMathHouses) {
    test('${house.$2} fallback provides a complete local Level 1 quiz', () {
      final fallback = LearningService.levelOneMathematicsFallback(
        LearningRequest(
          buildingId: house.$1,
          buildingName: house.$2,
          subject: house.$3,
          studentLevel: 1,
        ),
      );

      expect(fallback.source, 'fallback');
      expect(fallback.questions, hasLength(4));
      expect(fallback.questions.every((question) => question.options.length == 4), isTrue);
      expect(fallback.questions.every((question) => question.correctIndex >= 0 && question.correctIndex < 4), isTrue);
    });
  }
}
