import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the learning activity shown on the student dashboard.
class StudentProgress {
  const StudentProgress({
    this.quizzesCompleted = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.lastActivity,
    this.dailyActivity = const {},
  });

  final int quizzesCompleted;
  final int questionsAnswered;
  final int correctAnswers;
  final DateTime? lastActivity;
  final Map<String, int> dailyActivity;

  double get accuracy =>
      questionsAnswered == 0 ? 0 : correctAnswers / questionsAnswered;

  int get streak {
    if (dailyActivity.isEmpty) return 0;
    var day = _dateOnly(DateTime.now());
    var count = 0;
    while ((dailyActivity[_dayKey(day)] ?? 0) > 0) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  List<double> get lastSevenDays {
    final today = _dateOnly(DateTime.now());
    return List.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      return (((dailyActivity[_dayKey(day)] ?? 0) / 3).clamp(0.0, 1.0)).toDouble();
    });
  }

  static Future<StudentProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawActivity = prefs.getString('studentDailyActivity');
    final activity = <String, int>{};
    if (rawActivity != null) {
      final decoded = jsonDecode(rawActivity);
      if (decoded is Map) {
        decoded.forEach((key, value) {
          if (value is num) activity[key.toString()] = value.toInt();
        });
      }
    }
    final lastActivityMs = prefs.getInt('studentLastActivity');
    return StudentProgress(
      quizzesCompleted: prefs.getInt('studentQuizzesCompleted') ?? 0,
      questionsAnswered: prefs.getInt('studentQuestionsAnswered') ?? 0,
      correctAnswers: prefs.getInt('studentCorrectAnswers') ?? 0,
      lastActivity: lastActivityMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastActivityMs),
      dailyActivity: activity,
    );
  }

  static Future<void> recordQuiz({
    required int answered,
    required int correct,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final activity = <String, int>{};
    final rawActivity = prefs.getString('studentDailyActivity');
    if (rawActivity != null) {
      final decoded = jsonDecode(rawActivity);
      if (decoded is Map) {
        decoded.forEach((key, value) {
          if (value is num) activity[key.toString()] = value.toInt();
        });
      }
    }
    final today = _dateOnly(DateTime.now());
    final key = _dayKey(today);
    activity[key] = (activity[key] ?? 0) + answered;
    await Future.wait([
      prefs.setInt(
        'studentQuizzesCompleted',
        (prefs.getInt('studentQuizzesCompleted') ?? 0) + 1,
      ),
      prefs.setInt(
        'studentQuestionsAnswered',
        (prefs.getInt('studentQuestionsAnswered') ?? 0) + answered,
      ),
      prefs.setInt(
        'studentCorrectAnswers',
        (prefs.getInt('studentCorrectAnswers') ?? 0) + correct,
      ),
      prefs.setInt('studentLastActivity', DateTime.now().millisecondsSinceEpoch),
      prefs.setString('studentDailyActivity', jsonEncode(activity)),
    ]);
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
