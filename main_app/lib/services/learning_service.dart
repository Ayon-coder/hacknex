import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/learning_models.dart';
import 'api_config.dart';
import 'api_service.dart';

/// Centralized service handling AI content fetching and ElevenLabs TTS integration.
class LearningService {
  LearningService._();

  static const Duration _timeout = Duration(seconds: 60);

  /// Cache for fetched learning content
  static final Map<String, LearningContentResponse> _cache = {};

  /// Fetches AI-generated learning explanation and 4 MCQs for a given subject building.
  static Future<LearningContentResponse> fetchLearningContent(LearningRequest request) async {
    final cacheKey = '${request.buildingId}_${request.subject}_${request.studentLevel}';
    if (_cache.containsKey(cacheKey)) {
      debugPrint('📦 [LearningService]: Returning cached content for $cacheKey');
      return _cache[cacheKey]!;
    }

    final base = ApiConfig.baseUrl;

    try {
      final response = await ApiService.post(
        '/api/learning/content',
        body: request.toJson(),
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final result = LearningContentResponse.fromJson(data, base);
        _cache[cacheKey] = result;
        return result;
      }
      debugPrint('❌ [LearningService]: Backend error ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ [LearningService]: Exception fetching AI content: $e');
    }

    // Offline / fallback fallback path
    final fallback = _createOfflineContent(request);
    _cache[cacheKey] = fallback;
    return fallback;
  }

  /// Synthesizes speech for custom text (e.g., question reading, how-to-play tutorial).
  static Future<String?> fetchTTSAudioUrl(String text) async {
    if (text.trim().isEmpty) return null;
    try {
      final response = await ApiService.post(
        '/api/tts',
        body: {'text': text},
        timeout: const Duration(seconds: 12),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final rawPath = data['audio_url'] as String?;
        if (rawPath != null && rawPath.isNotEmpty) {
          final base = ApiConfig.baseUrl;
          return rawPath.startsWith('http') ? rawPath : '$base$rawPath';
        }
      }
    } catch (e) {
      debugPrint('❌ [LearningService]: Exception fetching TTS audio: $e');
    }
    return null;
  }

  /// Generates offline default content if backend is completely offline.
  static LearningContentResponse _createOfflineContent(LearningRequest req) {
    final subj = req.subject.toLowerCase();
    String topic = 'Core Principles of ${req.subject}';
    String explanation =
        'Mastery requires understanding core principles. Break down complex ideas into manageable parts, use practical real-world analogies, and verify your knowledge through active practice.';

    List<MCQuestion> questions = [];

    final lvl = req.studentLevel;

    if (subj.contains('code') || subj.contains('program')) {
      if (lvl <= 1) {
        topic = 'Programming: Variables, Flow & Basic Logic';
        explanation =
            'Programming is giving step-by-step instructions to a computer. Variables store data values in memory, print statements output text to the screen, and conditional if-else statements make decisions based on whether a condition is true or false.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is the primary purpose of a variable in code?',
            options: ['Store data for later use', 'Print graphics on screen', 'Increase Internet speed', 'Encrypt user password'],
            correctIndex: 0,
            explanation: 'Variables hold values that can be referenced and modified throughout a program.',
          ),
          MCQuestion(
            id: 2,
            question: 'Which construct allows a program to make decisions based on conditions?',
            options: ['If-Else Statements', 'Variables', 'Arrays', 'Comments'],
            correctIndex: 0,
            explanation: 'If-else statements evaluate conditions and branch execution accordingly.',
          ),
          MCQuestion(
            id: 3,
            question: 'What is the primary function of a loop in code?',
            options: ['Repeat a block of code multiple times', 'Store a single number', 'Style the visual layout', 'Terminate the app'],
            correctIndex: 0,
            explanation: 'Loops allow repeated execution of code without duplication.',
          ),
          MCQuestion(
            id: 4,
            question: 'What data type represents a binary True or False value?',
            options: ['Boolean', 'Integer', 'String', 'Float'],
            correctIndex: 0,
            explanation: 'Booleans represent true or false values in computer science.',
          ),
        ];
      } else if (lvl == 2) {
        topic = 'Programming: Loop Tracing, Arrays & Function Returns';
        explanation =
            'Level 2 Programming requires tracing loop execution, understanding zero-indexed arrays, calculating remainders with the modulo operator (%), and tracking function return values across nested calls.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is the output of this loop: count = 0; for i in range(1, 5): count += i?',
            options: ['10', '15', '5', '6'],
            correctIndex: 0,
            explanation: 'range(1, 5) iterates over 1, 2, 3, 4. The sum is 1 + 2 + 3 + 4 = 10.',
          ),
          MCQuestion(
            id: 2,
            question: 'In a zero-indexed array arr = [10, 20, 30, 40, 50], what is the value of arr[3]?',
            options: ['40', '30', '50', '20'],
            correctIndex: 0,
            explanation: 'arr[0]=10, arr[1]=20, arr[2]=30, and arr[3]=40.',
          ),
          MCQuestion(
            id: 3,
            question: 'What is the exact result of the modulo operation: 17 % 5?',
            options: ['2', '3', '3.4', '1'],
            correctIndex: 0,
            explanation: '17 divided by 5 is 3 with a remainder of 2. % returns the remainder 2.',
          ),
          MCQuestion(
            id: 4,
            question: 'Given def add(a, b): return a + b, what is the value of add(add(2, 3), 4)?',
            options: ['9', '7', '5', '10'],
            correctIndex: 0,
            explanation: 'Inner add(2, 3) returns 5. Outer add(5, 4) returns 9.',
          ),
        ];
      } else {
        topic = 'Advanced Computer Science: Algorithms, Stacks & OOP';
        explanation =
            'Advanced programming analyzes algorithm efficiency with Big-O notation, Last-In-First-Out (LIFO) stack structures, recursive base cases, and Object-Oriented polymorphism.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is the worst-case time complexity of binary search on a sorted array of n elements?',
            options: ['O(log n)', 'O(n)', 'O(n²)', 'O(1)'],
            correctIndex: 0,
            explanation: 'Binary search halves the search space at each step, running in O(log n) time.',
          ),
          MCQuestion(
            id: 2,
            question: 'Which data structure follows a Last-In, First-Out (LIFO) protocol?',
            options: ['Stack', 'Queue', 'Linked List', 'Binary Heap'],
            correctIndex: 0,
            explanation: 'A Stack operates strictly as Last-In, First-Out.',
          ),
          MCQuestion(
            id: 3,
            question: 'What happens if a recursive function does not define a proper base case?',
            options: ['Causes a stack overflow error', 'Finishes instantly', 'Compiles to faster loop', 'Returns null'],
            correctIndex: 0,
            explanation: 'Without a terminating base case, recursive calls consume all stack memory.',
          ),
          MCQuestion(
            id: 4,
            question: 'In OOP, when a child class provides a specific implementation of a parent method, what is this called?',
            options: ['Method Overriding (Polymorphism)', 'Encapsulation', 'Multiple Inheritance', 'Static Casting'],
            correctIndex: 0,
            explanation: 'Method overriding allows a subclass to provide a specific implementation of an inherited method.',
          ),
        ];
      }
    } else if (subj.contains('derivat')) {
      if (lvl <= 1) {
        topic = 'Differential Calculus: Fundamentals & Rates of Change';
        explanation =
            'Derivatives measure the instantaneous rate of change and the slope of a line at any moment. For constant functions like f(x) = 15, the derivative is always 0 because constants never change. For a linear motion function like s(t) = 8t + 3, the derivative s\'(t) represents constant velocity. Geometrically, the derivative at any point is the slope of the tangent line touching the curve at that exact coordinate.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is the derivative d/dx of the constant function f(x) = 15?',
            options: ['15', '0', '1', '15x'],
            correctIndex: 1,
            explanation: 'The derivative of any constant value is always 0.',
          ),
          MCQuestion(
            id: 2,
            question: 'For a linear motion function s(t) = 8t + 3, what is the velocity derivative s\'(t)?',
            options: ['8', '8t', '11', '3'],
            correctIndex: 0,
            explanation: 'The derivative of linear 8t + 3 with respect to t is 8.',
          ),
          MCQuestion(
            id: 3,
            question: 'Geometrically, what does the derivative of a function at a single point represent?',
            options: ['Area under the curve', 'Slope of the tangent line at that point', 'Distance to origin', 'Maximum height of graph'],
            correctIndex: 1,
            explanation: 'The derivative at a point equals the slope of the tangent line touching the curve at that point.',
          ),
          MCQuestion(
            id: 4,
            question: 'Using the power rule d/dx[xⁿ] = n·xⁿ⁻¹, what is d/dx[x²]?',
            options: ['x', '2x', '2x²', 'x³ / 3'],
            correctIndex: 1,
            explanation: 'Multiply by exponent 2 and decrease power to 1, yielding 2x.',
          ),
        ];
      } else if (lvl == 2) {
        topic = 'Differential Calculus: Power Rule & Tangent Slopes';
        explanation =
            'Level 2 Derivation dives into multi-step polynomial differentiation and instantaneous rates of change. By combining the power rule d/dx[a·xⁿ] = a·n·xⁿ⁻¹ with the sum rule, we differentiate complex polynomials term-by-term. To find the exact slope of a curve at a specific point x = x₀, we first compute the derivative function f\'(x), and then substitute x₀ into f\'(x). We also introduce fundamental trigonometric derivatives like d/dx[sin(x)] = cos(x).';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Using the power rule with coefficients, what is the derivative d/dx[5x³ − 4x² + 7]?',
            options: ['15x² − 8x', '15x³ − 8x²', '5x² − 4x', '15x² − 8x + 7'],
            correctIndex: 0,
            explanation: 'd/dx[5x³] = 15x², d/dx[−4x²] = −8x, and d/dx[7] = 0, giving 15x² − 8x.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the numerical slope of the curve y = 2x² + 3x − 1 at the specific point x = 3?',
            options: ['12', '15', '18', '21'],
            correctIndex: 1,
            explanation: "The derivative is y' = 4x + 3. Evaluating at x = 3 gives y'(3) = 4(3) + 3 = 15.",
          ),
          MCQuestion(
            id: 3,
            question: 'A particle moves with position s(t) = 4t³ − 6t² + 20 meters. What is its instantaneous velocity v(t) = s\'(t) at t = 2 seconds?',
            options: ['16 m/s', '24 m/s', '36 m/s', '48 m/s'],
            correctIndex: 1,
            explanation: "Velocity v(t) = s'(t) = 12t² − 12t. At t = 2: 12(4) − 12(2) = 48 − 24 = 24 m/s.",
          ),
          MCQuestion(
            id: 4,
            question: 'What is the derivative of the trigonometric expression f(x) = 3·sin(x) − 4·cos(x)?',
            options: ['3·cos(x) − 4·sin(x)', '3·cos(x) + 4·sin(x)', '−3·cos(x) − 4·sin(x)', '3·sin(x) + 4·cos(x)'],
            correctIndex: 1,
            explanation: 'd/dx[3·sin(x)] = 3·cos(x) and d/dx[−4·cos(x)] = −4·(−sin(x)) = +4·sin(x).',
          ),
        ];
      } else {
        topic = 'Differential Calculus: Product, Chain Rules & Critical Points';
        explanation =
            'Advanced calculus analyzes composite and multiplied functions using the product rule (u·v)\' = u\'·v + u·v\' and the chain rule d/dx[f(g(x))] = f\'(g(x))·g\'(x). Critical points occur where the derivative f\'(x) equals 0 or is undefined, identifying local maxima, minima, and optimization points on functional curves.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Using the chain rule, what is the derivative of f(x) = (3x − 2)⁴?',
            options: ['4(3x − 2)³', '12(3x − 2)³', '12(3x − 2)⁴', '3(3x − 2)³'],
            correctIndex: 1,
            explanation: 'Outer derivative 4(3x−2)³ multiplied by inner derivative 3 gives 12(3x−2)³.',
          ),
          MCQuestion(
            id: 2,
            question: 'Using the product rule, evaluate d/dx[x² · cos(x)].',
            options: ['2x·cos(x) − x²·sin(x)', '2x·cos(x) + x²·sin(x)', '−2x·sin(x)', 'x²·cos(x) − 2x·sin(x)'],
            correctIndex: 0,
            explanation: 'd/dx[x²]·cos(x) + x²·d/dx[cos(x)] = 2x·cos(x) − x²·sin(x).',
          ),
          MCQuestion(
            id: 3,
            question: 'Find the critical points (where f\'(x) = 0) of the function f(x) = 2x³ − 6x + 5.',
            options: ['x = 1 and x = −1', 'x = 0 and x = 3', 'x = 2 and x = −2', 'x = √3'],
            correctIndex: 0,
            explanation: "f'(x) = 6x² − 6 = 0 => 6(x² − 1) = 0 => x = 1, −1.",
          ),
          MCQuestion(
            id: 4,
            question: 'Using the quotient rule, find the derivative of y = x / (x + 1).',
            options: ['1 / (x + 1)²', '−1 / (x + 1)²', '1 / (x + 1)', '(2x + 1) / (x + 1)²'],
            correctIndex: 0,
            explanation: '[(1)(x+1) − (x)(1)] / (x+1)² = (x + 1 − x) / (x+1)² = 1 / (x + 1)²',
          ),
        ];
      }
    } else if (subj.contains('integrat')) {
      if (lvl <= 1) {
        topic = 'Integral Calculus: Fundamentals & Accumulation';
        explanation =
            'Integration accumulates continuous quantities to calculate total displacement and the exact area under curves. By the reverse power rule, the integral of a constant k with respect to x is kx + C, where C is the arbitrary constant of integration. Integrating velocity over time gives total distance traveled.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is the indefinite integral of the constant function f(x) = 4 with respect to x?',
            options: ['4x + C', '0', '4 + C', 'x⁴ + C'],
            correctIndex: 0,
            explanation: 'The antiderivative of any constant k is kx + C.',
          ),
          MCQuestion(
            id: 2,
            question: 'Using the reverse power rule, evaluate the indefinite integral: ∫ 3x² dx.',
            options: ['6x + C', 'x³ + C', '3x³ + C', 'x² + C'],
            correctIndex: 1,
            explanation: '∫ 3x² dx = 3 · (x³ / 3) + C = x³ + C.',
          ),
          MCQuestion(
            id: 3,
            question: 'What is the antiderivative of cos(x)?',
            options: ['−sin(x) + C', 'sin(x) + C', '−cos(x) + C', 'tan(x) + C'],
            correctIndex: 1,
            explanation: 'Since d/dx[sin(x)] = cos(x), the integral of cos(x) is sin(x) + C.',
          ),
          MCQuestion(
            id: 4,
            question: 'Evaluate the definite integral from x = 0 to x = 2 of the function 2x dx.',
            options: ['2', '4', '6', '8'],
            correctIndex: 1,
            explanation: 'Antiderivative is x². Evaluating at 2 and 0 gives 2² − 0² = 4.',
          ),
        ];
      } else if (lvl == 2) {
        topic = 'Integral Calculus: Reverse Power Rule & Definite Areas';
        explanation =
            'Level 2 Integration tackles multi-term polynomial integration and computing bounded area under curves via definite integrals. We integrate polynomial expressions term by term using the reverse power rule ∫ a·xⁿ dx = a · (xⁿ⁺¹/(n+1)) + C. The Fundamental Theorem of Calculus allows us to evaluate definite integrals F(b) − F(a) without needing the constant C.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Using the reverse power rule with coefficients, evaluate: ∫ (6x² − 8x + 5) dx.',
            options: ['2x³ − 4x² + 5x + C', '3x³ − 8x² + 5x + C', '12x − 8 + C', '2x³ − 8x² + C'],
            correctIndex: 0,
            explanation: '6(x³/3) − 8(x²/2) + 5x + C = 2x³ − 4x² + 5x + C.',
          ),
          MCQuestion(
            id: 2,
            question: 'Evaluate the definite integral from x = 1 to x = 3 of (3x²) dx.',
            options: ['24', '26', '27', '18'],
            correctIndex: 1,
            explanation: 'Antiderivative is x³. Evaluating at 3 and 1: 3³ − 1³ = 27 − 1 = 26.',
          ),
          MCQuestion(
            id: 3,
            question: 'What is the indefinite integral of f(x) = 4·cos(x) + 2·sin(x) dx?',
            options: ['4·sin(x) − 2·cos(x) + C', '−4·sin(x) + 2·cos(x) + C', '4·sin(x) + 2·cos(x) + C', '4·cos(x) − 2·sin(x) + C'],
            correctIndex: 0,
            explanation: '∫ cos(x) dx = sin(x), and ∫ sin(x) dx = −cos(x), giving 4·sin(x) − 2·cos(x) + C.',
          ),
          MCQuestion(
            id: 4,
            question: 'What is the exact area bounded by the line y = 2x + 1, the x-axis, from x = 0 to x = 4?',
            options: ['16', '20', '24', '18'],
            correctIndex: 1,
            explanation: '∫ from 0 to 4 of (2x + 1) dx = [x² + x] from 0 to 4 = (16 + 4) − 0 = 20.',
          ),
        ];
      } else {
        topic = 'Integral Calculus: Substitution & Integration by Parts';
        explanation =
            'Advanced integration resolves complex products and composite functions using u-substitution (variable change) and integration by parts (∫ u dv = uv − ∫ v du). These techniques enable solving areas between intersecting curves and computing physical centers of mass.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Using u-substitution with u = x² + 1, evaluate: ∫ 2x · (x² + 1)³ dx.',
            options: ['(x² + 1)⁴ / 4 + C', '(x² + 1)⁴ + C', '2(x² + 1)⁴ + C', '(x² + 1)³ / 3 + C'],
            correctIndex: 0,
            explanation: 'du = 2x dx, so ∫ u³ du = u⁴ / 4 + C = (x² + 1)⁴ / 4 + C.',
          ),
          MCQuestion(
            id: 2,
            question: 'Using integration by parts, evaluate: ∫ x · eˣ dx.',
            options: ['x·eˣ − eˣ + C', 'x·eˣ + eˣ + C', 'eˣ + C', 'x² · eˣ / 2 + C'],
            correctIndex: 0,
            explanation: 'u = x, dv = eˣ dx => du = dx, v = eˣ. uv − ∫ v du = x·eˣ − eˣ + C.',
          ),
          MCQuestion(
            id: 3,
            question: 'What is the total area bounded between the two curves y = 4 and y = x²?',
            options: ['16/3', '32/3', '8', '64/3'],
            correctIndex: 1,
            explanation: 'Intersection at x = −2, 2. ∫ from −2 to 2 of (4 − x²) dx = 2 · [4(2) − 8/3] = 32/3.',
          ),
          MCQuestion(
            id: 4,
            question: 'Evaluate the definite integral from 0 to π of sin(x) dx.',
            options: ['0', '1', '2', '−1'],
            correctIndex: 2,
            explanation: '[−cos(x)] from 0 to π = −cos(π) − (−cos(0)) = −(−1) − (−1) = 1 + 1 = 2.',
          ),
        ];
      }
    } else if (subj.contains('trig')) {
      if (lvl <= 1) {
        topic = 'Trigonometric Ratios & Right Triangles';
        explanation =
            'Trigonometry explores the relationships between triangle side lengths and angles. For any acute angle in a right triangle, sine is opposite over hypotenuse, cosine is adjacent over hypotenuse, and tangent is opposite over adjacent (SOH-CAH-TOA). The Pythagorean theorem relates the sides via a² + b² = c².';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'In a right triangle, which trigonometric ratio is defined as Opposite / Hypotenuse?',
            options: ['Cosine', 'Sine', 'Tangent', 'Secant'],
            correctIndex: 1,
            explanation: 'By SOH-CAH-TOA, Sine = Opposite / Hypotenuse.',
          ),
          MCQuestion(
            id: 2,
            question: 'In a right triangle with opposite side = 3 and adjacent side = 4, what is tan(θ)?',
            options: ['3/5', '4/5', '3/4', '4/3'],
            correctIndex: 2,
            explanation: 'Tangent = Opposite / Adjacent = 3/4.',
          ),
          MCQuestion(
            id: 3,
            question: 'In a right triangle with legs of length 3 and 4, what is the length of the hypotenuse?',
            options: ['5', '6', '7', '25'],
            correctIndex: 0,
            explanation: '√(3² + 4²) = √(9 + 16) = √25 = 5.',
          ),
          MCQuestion(
            id: 4,
            question: 'What is the exact value of sin(90°) or sin(π/2 radians)?',
            options: ['0', '1', '0.5', 'undefined'],
            correctIndex: 1,
            explanation: 'At 90 degrees on the unit circle, the y-coordinate is 1.',
          ),
        ];
      } else if (lvl == 2) {
        topic = 'Trigonometry: Standard Angles, Radians & Pythagorean Identities';
        explanation =
            'Level 2 Trigonometry focuses on unit circle coordinates, converting angles to radians (π = 180°), standard angle exact values (30°, 45°, 60°), and the fundamental identity sin²(θ) + cos²(θ) = 1. These mathematical relationships enable calculating exact side lengths without a calculator.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'In a right triangle where angle θ = 30° and the hypotenuse is 12, what is the length of the opposite side?',
            options: ['6', '6√3', '8', '4'],
            correctIndex: 0,
            explanation: 'sin(30°) = 1/2. Opposite = 12 · sin(30°) = 12 · 1/2 = 6.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the exact value of cos(60°)?',
            options: ['0.5', '√3/2', '√2/2', '1'],
            correctIndex: 0,
            explanation: 'cos(60°) = 1/2 = 0.5.',
          ),
          MCQuestion(
            id: 3,
            question: 'Convert an angle of 150° into radians in terms of π.',
            options: ['5π / 6', '3π / 4', '2π / 3', '7π / 6'],
            correctIndex: 0,
            explanation: '150 · (π / 180) = 15/18 π = 5π / 6 radians.',
          ),
          MCQuestion(
            id: 4,
            question: 'If sin(θ) = 3/5 for an acute angle θ, use sin²(θ) + cos²(θ) = 1 to find cos(θ).',
            options: ['4/5', '3/4', '5/4', '2/5'],
            correctIndex: 0,
            explanation: 'cos²(θ) = 1 − (3/5)² = 1 − 9/25 = 16/25 => cos(θ) = 4/5.',
          ),
        ];
      } else {
        topic = 'Advanced Trigonometry: Laws of Sines/Cosines & Identities';
        explanation =
            'Advanced trigonometry analyzes arbitrary non-right triangles using the Law of Sines and the Law of Cosines (c² = a² + b² − 2ab·cos(C)), double-angle formulas like sin(2A) = 2·sin(A)·cos(A), and reciprocal functions (sec, csc, cot).';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Given sin(A) = 3/5 and cos(A) = 4/5, what is the value of sin(2A) using the double angle identity?',
            options: ['24/25', '7/25', '12/25', '6/5'],
            correctIndex: 0,
            explanation: 'sin(2A) = 2 · sin(A) · cos(A) = 2 · (3/5) · (4/5) = 24/25.',
          ),
          MCQuestion(
            id: 2,
            question: 'In a triangle with sides a = 5, b = 7, and angle C = 60°, what is c² by the Law of Cosines?',
            options: ['39', '49', '74', '35'],
            correctIndex: 0,
            explanation: 'c² = 5² + 7² − 2(5)(7)·cos(60°) = 25 + 49 − 70(0.5) = 74 − 35 = 39.',
          ),
          MCQuestion(
            id: 3,
            question: 'Which reciprocal trigonometric function is defined as 1 / cos(θ)?',
            options: ['Secant (sec)', 'Cosecant (csc)', 'Cotangent (cot)', 'Tangent (tan)'],
            correctIndex: 0,
            explanation: 'sec(θ) = 1 / cos(θ) by definition.',
          ),
          MCQuestion(
            id: 4,
            question: 'Solve for θ in the interval [0, 2π) such that 2·sin(θ) − 1 = 0.',
            options: ['π/6 and 5π/6', 'π/3 and 2π/3', 'π/4 and 3π/4', 'π/2 only'],
            correctIndex: 0,
            explanation: 'sin(θ) = 1/2. In [0, 2π), sin is 1/2 at θ = π/6 and θ = 5π/6.',
          ),
        ];
      }
    } else if (subj.contains('algebra')) {
      if (lvl <= 1) {
        topic = 'Algebra: 1-Step Equations & Expressions';
        explanation =
            'Algebra uses letters to represent unknown numbers. Solving an equation means finding values that balance the scale. In 1-step equations, we perform inverse operations: subtracting a number to undo addition, or dividing to undo multiplication.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Solve for x in the 1-step linear equation: x + 9 = 23.',
            options: ['x = 14', 'x = 12', 'x = 32', 'x = 16'],
            correctIndex: 0,
            explanation: 'Subtract 9 from both sides: x = 23 − 9 = 14.',
          ),
          MCQuestion(
            id: 2,
            question: 'Solve for x in the equation: 5x = 45.',
            options: ['x = 9', 'x = 8', 'x = 40', 'x = 7'],
            correctIndex: 0,
            explanation: 'Divide both sides by 5: x = 45 / 5 = 9.',
          ),
          MCQuestion(
            id: 3,
            question: 'Simplify the algebraic expression by combining like terms: 4x + 7x − 3x.',
            options: ['8x', '11x', '8', '14x'],
            correctIndex: 0,
            explanation: '(4 + 7 − 3)x = 8x.',
          ),
          MCQuestion(
            id: 4,
            question: 'If a = 4 and b = 3, evaluate the expression 2a + 3b.',
            options: ['17', '14', '24', '11'],
            correctIndex: 0,
            explanation: '2(4) + 3(3) = 8 + 9 = 17.',
          ),
        ];
      } else if (lvl == 2) {
        topic = 'Algebra: 2-Step Equations & Quadratic Factoring';
        explanation =
            'Level 2 Algebra introduces multi-step equations with variables on both sides, factoring quadratic trinomials into binomials, and slope-intercept linear equations (y = mx + b). These core skills form the backbone of intermediate mathematical problem-solving.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Solve for x in the 2-step equation: 4x − 11 = 25.',
            options: ['x = 9', 'x = 8', 'x = 7', 'x = 10'],
            correctIndex: 0,
            explanation: 'Add 11 to both sides: 4x = 36. Then divide by 4: x = 9.',
          ),
          MCQuestion(
            id: 2,
            question: 'Solve the equation with variables on both sides: 7x − 5 = 3x + 19.',
            options: ['x = 6', 'x = 5', 'x = 4', 'x = 7'],
            correctIndex: 0,
            explanation: 'Subtract 3x: 4x − 5 = 19. Add 5: 4x = 24. Divide by 4: x = 6.',
          ),
          MCQuestion(
            id: 3,
            question: 'Factor the quadratic trinomial into two binomials: x² − 7x + 10.',
            options: ['(x − 2)(x − 5)', '(x + 2)(x + 5)', '(x − 1)(x − 10)', '(x + 1)(x − 10)'],
            correctIndex: 0,
            explanation: '−2 and −5 multiply to 10 and add to −7.',
          ),
          MCQuestion(
            id: 4,
            question: 'What is the slope (m) and y-intercept (b) of the linear equation 3x + 2y = 12?',
            options: ['m = −3/2, b = 6', 'm = 3/2, b = 12', 'm = −3, b = 6', 'm = 2, b = 4'],
            correctIndex: 0,
            explanation: '2y = −3x + 12 => y = (−3/2)x + 6. Slope is −3/2, y-intercept is 6.',
          ),
        ];
      } else {
        topic = 'Advanced Algebra: Systems & Quadratic Formula';
        explanation =
            'Advanced algebra covers systems of simultaneous equations, the quadratic formula x = (−b ± √(b² − 4ac)) / (2a), the discriminant, and rational exponents.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Solve the linear system: 2x + y = 11 and x − y = 1.',
            options: ['x = 4, y = 3', 'x = 5, y = 1', 'x = 3, y = 5', 'x = 6, y = −1'],
            correctIndex: 0,
            explanation: 'Add equations: 3x = 12 => x = 4, then y = 4 − 1 = 3.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the discriminant of 2x² − 4x + 5 = 0, and what does it indicate?',
            options: ['−24, indicating two complex conjugate roots', '24, indicating two distinct real roots', '0, indicating one repeated root', '−16, indicating complex roots'],
            correctIndex: 0,
            explanation: 'b² − 4ac = (−4)² − 4(2)(5) = 16 − 40 = −24 (negative means complex roots).',
          ),
          MCQuestion(
            id: 3,
            question: 'Find the roots of the quadratic equation 2x² + 5x − 3 = 0 using factoring or the quadratic formula.',
            options: ['x = 0.5 and x = −3', 'x = −0.5 and x = 3', 'x = 1 and x = −3', 'x = 2 and x = −1'],
            correctIndex: 0,
            explanation: '(2x − 1)(x + 3) = 0 => x = 1/2 = 0.5 or x = −3.',
          ),
          MCQuestion(
            id: 4,
            question: 'Simplify the exponential expression: (2x³ · y²)³ / (4x⁴ · y).',
            options: ['2x⁵ · y⁵', '2x⁴ · y⁵', '4x⁵ · y⁶', '8x⁵ · y⁵'],
            correctIndex: 0,
            explanation: '[8x⁹ · y⁶] / [4x⁴ · y] = (8/4) · x^(9−4) · y^(6−1) = 2x⁵ · y⁵.',
          ),
        ];
      }
    } else if (subj.contains('geometry')) {
      if (lvl <= 1) {
        topic = 'Geometry: 2D Shapes, Angles & Perimeter';
        explanation =
            'Geometry investigates the properties and measurements of shapes, angles, and lines. In Euclidean geometry, the interior angles of any triangle always add up to 180 degrees. Perimeter measures the boundary length around a figure, while area measures the surface inside.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is the perimeter of a rectangle with length 7 cm and width 4 cm?',
            options: ['22 cm', '28 cm', '11 cm', '18 cm'],
            correctIndex: 0,
            explanation: 'Perimeter = 2 · (length + width) = 2 · (7 + 4) = 22 cm.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the area of a square with side length 6 meters?',
            options: ['36 m²', '24 m²', '12 m²', '30 m²'],
            correctIndex: 0,
            explanation: 'Area = side · side = 6 · 6 = 36 m².',
          ),
          MCQuestion(
            id: 3,
            question: 'What is the sum of interior angles in any two-dimensional triangle?',
            options: ['180°', '90°', '270°', '360°'],
            correctIndex: 0,
            explanation: 'The interior angles of any triangle in Euclidean space always sum to 180 degrees.',
          ),
          MCQuestion(
            id: 4,
            question: 'How many degrees are in a perfect right angle?',
            options: ['90°', '45°', '180°', '60°'],
            correctIndex: 0,
            explanation: 'A right angle is exactly 90 degrees.',
          ),
        ];
      } else if (lvl == 2) {
        topic = 'Geometry: Circles, Coordinates & Pythagorean Theorem';
        explanation =
            'Level 2 Geometry advances into circle formulas (circumference = 2·π·r, area = π·r²), the 2D coordinate distance formula d = √((x₂−x₁)² + (y₂−y₁)²), and transversal angle relationships on parallel lines.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is the area of a circle with radius r = 7 cm (using π = 22/7)?',
            options: ['154 cm²', '44 cm²', '88 cm²', '196 cm²'],
            correctIndex: 0,
            explanation: 'Area = π · r² = (22/7) · 7 · 7 = 22 · 7 = 154 cm².',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the area of a triangle with base 14 cm and perpendicular height 9 cm?',
            options: ['63 cm²', '126 cm²', '46 cm²', '54 cm²'],
            correctIndex: 0,
            explanation: 'Area = 1/2 · base · height = 1/2 · 14 · 9 = 7 · 9 = 63 cm².',
          ),
          MCQuestion(
            id: 3,
            question: 'Find the distance between the two points A(1, 2) and B(5, 5) on the Cartesian coordinate plane.',
            options: ['5', '7', '4', '√17'],
            correctIndex: 0,
            explanation: 'd = √((5−1)² + (5−2)²) = √(4² + 3²) = √(16 + 9) = √25 = 5.',
          ),
          MCQuestion(
            id: 4,
            question: 'Two parallel lines are intersected by a transversal. If one interior angle is 65°, what is the alternate interior angle?',
            options: ['65°', '115°', '90°', '25°'],
            correctIndex: 0,
            explanation: 'Alternate interior angles created by parallel lines and a transversal are equal: 65°.',
          ),
        ];
      } else {
        topic = 'Advanced Geometry: 3D Solids, Vectors & Circle Equations';
        explanation =
            'Advanced geometry explores 3D volume and surface area, 2D/3D vector magnitudes, and standard coordinate equations of circles (x−h)² + (y−k)² = r².';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is the volume of a cylinder with radius 3 cm and height 10 cm in terms of π?',
            options: ['90π cm³', '60π cm³', '30π cm³', '100π cm³'],
            correctIndex: 0,
            explanation: 'Volume = π · r² · h = π · (3²) · 10 = 90π cm³.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the length of the 3D space diagonal of a box with dimensions 3 × 4 × 12?',
            options: ['13', '15', '17', '12'],
            correctIndex: 0,
            explanation: 'Diagonal = √(3² + 4² + 12²) = √(9 + 16 + 144) = √169 = 13.',
          ),
          MCQuestion(
            id: 3,
            question: 'What is the center and radius of the circle defined by (x − 4)² + (y + 2)² = 49?',
            options: ['Center (4, −2), radius 7', 'Center (−4, 2), radius 7', 'Center (4, −2), radius 49', 'Center (−4, 2), radius 49'],
            correctIndex: 0,
            explanation: 'Standard form (x−h)² + (y−k)² = r² yields center (4, −2) and radius √49 = 7.',
          ),
          MCQuestion(
            id: 4,
            question: 'What is the magnitude of the 2D vector v = [5, 12]?',
            options: ['13', '17', '7', '25'],
            correctIndex: 0,
            explanation: 'Magnitude = √(5² + 12²) = √(25 + 144) = √169 = 13.',
          ),
        ];
      }
    } else if (subj.contains('arithmetic') || subj.contains('number')) {
      if (lvl <= 1) {
        topic = 'Arithmetic: Mental Math & Multiplication Tables';
        explanation =
            'Arithmetic is the fundamental branch of math dealing with addition, subtraction, multiplication, and division. Mastering multiplication tables 1 through 12 and recognizing even and odd number patterns creates the foundation for all quantitative reasoning.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is 7 × 8?',
            options: ['56', '54', '48', '64'],
            correctIndex: 0,
            explanation: '7 × 8 = 56, a fundamental times-table fact.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is 144 ÷ 12?',
            options: ['12', '11', '13', '14'],
            correctIndex: 0,
            explanation: '144 divided by 12 equals 12.',
          ),
          MCQuestion(
            id: 3,
            question: 'Which of the following numbers is an even number?',
            options: ['28', '35', '19', '47'],
            correctIndex: 0,
            explanation: '28 ends in 8 and is evenly divisible by 2.',
          ),
          MCQuestion(
            id: 4,
            question: 'What is 45 + 78?',
            options: ['123', '113', '133', '125'],
            correctIndex: 0,
            explanation: '45 + 78 = 123.',
          ),
        ];
      } else if (lvl == 2) {
        topic = 'Arithmetic: Order of Operations, GCF/LCM & Unlike Fractions';
        explanation =
            'Level 2 Arithmetic challenges you with multi-step calculations using the proper order of operations (PEMDAS/BODMAS: Parentheses, Exponents, Multiplication & Division left-to-right, Addition & Subtraction left-to-right), finding the Greatest Common Factor (GCF) and Least Common Multiple (LCM), and adding fractions with unlike denominators.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Evaluate using the proper order of operations (PEMDAS): 18 − 3 × (4 + 2) ÷ 2.',
            options: ['9', '45', '12', '15'],
            correctIndex: 0,
            explanation: 'Brackets first: (4+2)=6. Then multiply and divide left to right: 3×6=18, 18÷2=9. Finally subtract: 18 − 9 = 9.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the Greatest Common Factor (GCF) of 48 and 72?',
            options: ['24', '12', '16', '8'],
            correctIndex: 0,
            explanation: '24 is the largest integer dividing both 48 (24×2) and 72 (24×3).',
          ),
          MCQuestion(
            id: 3,
            question: 'Add the two fractions with unlike denominators: 2/3 + 3/4.',
            options: ['17/12', '5/7', '11/12', '5/12'],
            correctIndex: 0,
            explanation: 'Common denominator is 12: 8/12 + 9/12 = 17/12 (or 1 and 5/12).',
          ),
          MCQuestion(
            id: 4,
            question: 'What is the prime factorization of 360?',
            options: ['2³ × 3² × 5', '2² × 3³ × 5', '2⁴ × 3 × 5', '2³ × 3 × 15'],
            correctIndex: 0,
            explanation: '360 = 8 × 9 × 5 = 2³ × 3² × 5.',
          ),
        ];
      } else {
        topic = 'Advanced Arithmetic: Exponent Laws, Roots & Scientific Notation';
        explanation =
            'Advanced arithmetic covers powers and exponent rules, square and cube roots, Least Common Multiples (LCM), percentages, and scientific notation.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Evaluate the expression: 2⁵ · 2⁻² + 3³.',
            options: ['35', '19', '43', '27'],
            correctIndex: 0,
            explanation: '2^(5−2) + 27 = 2³ + 27 = 8 + 27 = 35.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the Least Common Multiple (LCM) of 12, 18, and 30?',
            options: ['180', '90', '360', '60'],
            correctIndex: 0,
            explanation: '12 = 2² × 3, 18 = 2 × 3², 30 = 2 × 3 × 5. LCM = 2² × 3² × 5 = 180.',
          ),
          MCQuestion(
            id: 3,
            question: 'If 35% of a number is 140, what is 60% of that same number?',
            options: ['240', '210', '280', '200'],
            correctIndex: 0,
            explanation: 'Number is 140 / 0.35 = 400. 60% of 400 = 0.60 × 400 = 240.',
          ),
          MCQuestion(
            id: 4,
            question: 'Simplify in scientific notation: (4.0 × 10⁵) × (3.0 × 10³).',
            options: ['1.2 × 10⁹', '12 × 10⁸', '1.2 × 10⁸', '7.0 × 10⁸'],
            correctIndex: 0,
            explanation: '12.0 × 10⁸ = 1.2 × 10⁹ in proper scientific notation.',
          ),
        ];
      }
    } else if (subj.contains('math')) {
      if (lvl <= 1) {
        topic = 'Multiplication & Division Fundamentals';
        explanation =
            'Multiplication is repeated addition: 3 × 4 means adding four 3s to reach 12. Division is the exact inverse: sharing 12 magic crystals among 4 apprentices gives 3 crystals each. Mastering your times tables up to 12 unlocks mental math superpowers across every realm in the Academy!';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is 7 × 8?',
            options: ['56', '54', '48', '64'],
            correctIndex: 0,
            explanation: '7 × 8 = 56, a fundamental times-table fact.',
          ),
          MCQuestion(
            id: 2,
            question: 'Which operation is the inverse (opposite) of multiplication?',
            options: ['Division', 'Addition', 'Subtraction', 'Squaring'],
            correctIndex: 0,
            explanation: 'Division directly undoes multiplication.',
          ),
          MCQuestion(
            id: 3,
            question: 'If 36 ÷ 6 = 6, which multiplication confirms this?',
            options: ['6 × 6 = 36', '6 + 6 = 12', '6 − 6 = 0', '36 × 1 = 36'],
            correctIndex: 0,
            explanation: '6 × 6 = 36 confirms that 36 ÷ 6 = 6.',
          ),
          MCQuestion(
            id: 4,
            question: 'A wizard arranges 9 trays of 8 magic potions each. How many potions in total?',
            options: ['72', '64', '81', '17'],
            correctIndex: 0,
            explanation: '9 groups of 8 potions = 9 × 8 = 72 potions.',
          ),
        ];
      } else if (lvl == 2) {
        topic = 'Pre-Algebra & Order of Operations (Level 2)';
        explanation =
            'Level 2 Mathematics advances beyond simple times tables to multi-step operations using PEMDAS/BODMAS, solving two-step algebraic equations, calculating percentages, and adding fractions with unlike denominators.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'Evaluate using the order of operations (PEMDAS): 14 + 6 × (8 − 5) ÷ 2.',
            options: ['23', '30', '19', '25'],
            correctIndex: 0,
            explanation: '(8-5)=3. Then 6×3=18. Then 18÷2=9. Finally 14+9 = 23.',
          ),
          MCQuestion(
            id: 2,
            question: 'Solve for x in the two-step equation: 3x + 7 = 25.',
            options: ['x = 6', 'x = 5', 'x = 8', 'x = 4'],
            correctIndex: 0,
            explanation: 'Subtract 7: 3x = 18. Divide by 3: x = 6.',
          ),
          MCQuestion(
            id: 3,
            question: 'What is 2/5 + 1/3 as a single fraction?',
            options: ['11/15', '3/8', '3/15', '7/15'],
            correctIndex: 0,
            explanation: 'Common denominator is 15: 6/15 + 5/15 = 11/15.',
          ),
          MCQuestion(
            id: 4,
            question: 'A merchant discounts a 60 coin spell book by 25%. What is the new price?',
            options: ['45 coins', '50 coins', '40 coins', '48 coins'],
            correctIndex: 0,
            explanation: '25% of 60 is 15. The discounted price is 60 − 15 = 45 coins.',
          ),
        ];
      } else if (lvl <= 4) {
        topic = 'Ratios & Solving for Unknowns';
        explanation =
            'A ratio compares two quantities, such as 2 parts red to 3 parts blue (2:3). A proportion states two ratios are equal: a/b = c/d. Cross-multiplying gives a × d = b × c. Proportions allow you to scale spells, read ancient maps, and calculate speeds with precision.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'A map uses a scale of 1 cm : 5 km. What real-world distance does 4 cm represent?',
            options: ['9 km', '20 km', '4 km', '5 km'],
            correctIndex: 1,
            explanation: '4 cm × 5 km/cm = 20 km.',
          ),
          MCQuestion(
            id: 2,
            question: 'Solve for x in the equation: 2x + 6 = 14',
            options: ['x = 3', 'x = 4', 'x = 5', 'x = 2'],
            correctIndex: 1,
            explanation: '2x = 8, so x = 4.',
          ),
          MCQuestion(
            id: 3,
            question: 'Solve the proportion for x: 3 / 5 = x / 20',
            options: ['x = 10', 'x = 12', 'x = 15', 'x = 9'],
            correctIndex: 1,
            explanation: 'Cross-multiply: 5x = 60, therefore x = 12.',
          ),
          MCQuestion(
            id: 4,
            question: 'A flying carriage travels 150 km in 3 hours. How far does it travel in 5 hours at the same speed?',
            options: ['200 km', '250 km', '300 km', '180 km'],
            correctIndex: 1,
            explanation: 'Speed = 50 km/h, distance in 5 hours = 250 km.',
          ),
        ];
      } else if (lvl <= 6) {
        topic = 'Quadratic Equations & Geometry';
        explanation =
            'A quadratic equation has the form ax² + bx + c = 0. Its roots are given by x = (−b ± √(b² − 4ac)) / (2a). The discriminant b² − 4ac reveals whether the roots are distinct real numbers, a single repeated root, or complex numbers.';
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is the maximum number of real roots a quadratic equation can have?',
            options: ['1', '2', '3', 'Infinite'],
            correctIndex: 1,
            explanation: 'A second-degree polynomial has at most 2 roots.',
          ),
          MCQuestion(
            id: 2,
            question: 'What does a discriminant of b² − 4ac = 0 indicate?',
            options: ['Two distinct real roots', 'Exactly one repeated real root', 'No real roots', 'Infinite solutions'],
            correctIndex: 1,
            explanation: 'Discriminant = 0 means the parabola touches the x-axis at one point.',
          ),
          MCQuestion(
            id: 3,
            question: 'What are the roots of x² − 5x + 6 = 0?',
            options: ['x = 2 and x = 3', 'x = −2 and x = −3', 'x = 1 and x = 6', 'x = 5 and x = 1'],
            correctIndex: 0,
            explanation: 'Factor into (x − 2)(x − 3) = 0, giving x = 2 and x = 3.',
          ),
          MCQuestion(
            id: 4,
            question: 'In a right triangle with legs of length 6 and 8, what is the hypotenuse?',
            options: ['10', '12', '14', '9'],
            correctIndex: 0,
            explanation: 'Pythagorean theorem: c = √(36 + 64) = √100 = 10.',
          ),
        ];
      } else {
        topic = 'Calculus & Rates of Change';
        explanation =
            "Derivatives measure instantaneous change. By the power rule, d/dx[xⁿ] = n·xⁿ⁻¹. For composite functions, the chain rule states [f(g(x))]' = f'(g(x)) · g'(x). This rule enables optimization across physics, engineering, and artificial intelligence.";
        questions = const [
          MCQuestion(
            id: 1,
            question: 'What is the derivative d/dx[x³] using the power rule?',
            options: ['x²', '3x²', '3x³', 'x⁴ / 4'],
            correctIndex: 1,
            explanation: 'By the power rule d/dx[xⁿ] = n·xⁿ⁻¹, d/dx[x³] = 3x².',
          ),
          MCQuestion(
            id: 2,
            question: 'Which rule differentiates a composite function f(g(x))?',
            options: ['Product Rule', 'Quotient Rule', 'Chain Rule', "L'Hôpital's Rule"],
            correctIndex: 2,
            explanation: "The chain rule differentiates composite functions.",
          ),
          MCQuestion(
            id: 3,
            question: 'Evaluate d/dx[(3x + 1)⁵].',
            options: ['5(3x + 1)⁴', '15(3x + 1)⁴', '5(3x + 1)⁵', '3(3x + 1)⁵'],
            correctIndex: 1,
            explanation: 'Outer: 5(3x+1)⁴, inner: 3. Product = 15(3x + 1)⁴.',
          ),
          MCQuestion(
            id: 4,
            question: 'Why does neural network backpropagation rely on the chain rule?',
            options: ['Networks are linear', 'Networks are compositions of layered functions', 'Weights are always constant', 'Loss is always zero'],
            correctIndex: 1,
            explanation: 'Backpropagation computes error gradients across composed layers using the chain rule.',
          ),
        ];
      }
    } else {
      questions = [
        MCQuestion(
          id: 1,
          question: 'What is the best way to master ${req.subject}?',
          options: ['Rote memorization', 'Conceptual understanding & practice', 'Skipping basics', 'Random guessing'],
          correctIndex: 1,
          explanation: 'Active problem solving and concept mastery produce lasting understanding.',
        ),
        MCQuestion(
          id: 2,
          question: 'Why break topics into smaller components?',
          options: ['Simplifies understanding', 'Wastes study time', 'Makes memory hard', 'Disables logic'],
          correctIndex: 0,
          explanation: 'Deconstructing topics makes learning manageable and clear.',
        ),
        MCQuestion(
          id: 3,
          question: 'What solidifies learning in memory?',
          options: ['Passive reading', 'Active practice & answering questions', 'Ignoring errors', 'No sleep'],
          correctIndex: 1,
          explanation: 'Applying knowledge through quiz questions reinforces recall.',
        ),
        MCQuestion(
          id: 4,
          question: 'How should learning mistakes be viewed?',
          options: ['As failure', 'As valuable learning feedback', 'As irrelevant', 'As reason to quit'],
          correctIndex: 1,
          explanation: 'Mistakes pinpoint exact concepts to review and improve.',
        ),
      ];
    }

    return LearningContentResponse(
      buildingId: req.buildingId,
      buildingName: req.buildingName,
      subject: req.subject,
      topic: topic,
      explanation: explanation,
      questions: questions,
      explanationAudioUrl: null,
      audioAvailable: false,
      source: 'offline',
      cacheKey: 'offline_${req.buildingId}',
    );
  }
}
