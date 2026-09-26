import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Everything the player chooses during onboarding.
///
/// Persisted as a single JSON blob under [_prefsKey]. `selectedSubjects` is
/// mirrored to its own list key because [WorldScreen], [MapListScreen] and
/// [ProfileScreen] already read that key directly.
class PlayerProfile {
  const PlayerProfile({
    this.name = '',
    this.grade = '',
    this.curriculum = '',
    this.subjects = const [],
    this.difficulty = '',
    this.worldTheme = '',
    this.learningGoal = '',
    this.avatarIndex = 0,
  });

  final String name;
  final String grade;
  final String curriculum;
  final List<String> subjects;
  final String difficulty;
  final String worldTheme;
  final String learningGoal;
  final int avatarIndex;

  static const String _prefsKey = 'playerProfile';
  static const String subjectsKey = 'selectedSubjects';
  static const String onboardedKey = 'hasOnboarded';

  PlayerProfile copyWith({
    String? name,
    String? grade,
    String? curriculum,
    List<String>? subjects,
    String? difficulty,
    String? worldTheme,
    String? learningGoal,
    int? avatarIndex,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      grade: grade ?? this.grade,
      curriculum: curriculum ?? this.curriculum,
      subjects: subjects ?? this.subjects,
      difficulty: difficulty ?? this.difficulty,
      worldTheme: worldTheme ?? this.worldTheme,
      learningGoal: learningGoal ?? this.learningGoal,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'grade': grade,
        'curriculum': curriculum,
        'subjects': subjects,
        'difficulty': difficulty,
        'world_theme': worldTheme,
        'learning_goal': learningGoal,
        'avatar_index': avatarIndex,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      name: json['name'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      curriculum: json['curriculum'] as String? ?? '',
      subjects:
          (json['subjects'] as List?)?.map((e) => e.toString()).toList() ?? [],
      difficulty: json['difficulty'] as String? ?? '',
      worldTheme: json['world_theme'] as String? ?? '',
      learningGoal: json['learning_goal'] as String? ?? '',
      avatarIndex: json['avatar_index'] as int? ?? 0,
    );
  }

  /// Payload for POST /api/intro — avatar index is client-only.
  Map<String, dynamic> toIntroRequest() {
    final json = toJson()..remove('avatar_index');
    return json;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(toJson()));
    await prefs.setStringList(subjectsKey, subjects);
    await prefs.setBool(onboardedKey, true);
  }

  static Future<PlayerProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return null;
    try {
      return PlayerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }
}
