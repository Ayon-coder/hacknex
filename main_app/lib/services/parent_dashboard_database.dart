import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ParentAccount {
  const ParentAccount({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;
}

class ChildSummary {
  const ChildSummary({
    required this.id,
    required this.name,
    required this.grade,
    this.avatar = '',
  });

  final int id;
  final String name;
  final String grade;
  final String avatar;
}

class SubjectPerformance {
  const SubjectPerformance({
    required this.subjectId,
    required this.name,
    required this.color,
    required this.averageScore,
    required this.completedTopics,
    required this.totalTopics,
  });

  final int subjectId;
  final String name;
  final String color;
  final double averageScore;
  final int completedTopics;
  final int totalTopics;
}

class TopicPerformance {
  const TopicPerformance({
    required this.topicId,
    required this.subjectId,
    required this.name,
    required this.score,
    required this.attempts,
  });

  final int topicId;
  final int subjectId;
  final String name;
  final double score;
  final int attempts;
}

class RecentActivity {
  const RecentActivity({
    required this.id,
    required this.title,
    required this.activityType,
    required this.score,
    required this.completedAt,
  });

  final int id;
  final String title;
  final String activityType;
  final double score;
  final DateTime completedAt;
}

class TrendPoint {
  const TrendPoint({required this.date, required this.score});

  final DateTime date;
  final double score;
}

class ParentDashboardDatabase {
  ParentDashboardDatabase._();

  static final instance = ParentDashboardDatabase._();
  Database? _database;

  Future<Database> initialize() async {
    if (_database != null) return _database!;

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = '${await getDatabasesPath()}/parent_dashboard.db';
    _database = await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await _createSchema(db);
        await _seedIfEmpty(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Drop all tables and recreate with enriched seed data
        for (final table in [
          'learning_activity',
          'child_topic_performance',
          'child_performance',
          'topics',
          'subjects',
          'children',
          'parents',
        ]) {
          await db.execute('DROP TABLE IF EXISTS $table');
        }
        await _createSchema(db);
        await _seedIfEmpty(db);
      },
    );
    await _seedIfEmpty(_database!);
    return _database!;
  }

  Future<Database> get database => initialize();

  Future<ParentAccount?> loginParent(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'parents',
      columns: ['id', 'name', 'email'],
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email.trim().toLowerCase(), _hash(password)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return ParentAccount(
      id: row['id']! as int,
      name: row['name']! as String,
      email: row['email']! as String,
    );
  }

  Future<List<ChildSummary>> getChildren(int parentId) async {
    final rows = await (await database).query(
      'children',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'name',
    );
    return rows
        .map(
          (row) => ChildSummary(
            id: row['id']! as int,
            name: row['name']! as String,
            grade: row['grade']! as String,
            avatar: row['avatar'] as String? ?? '',
          ),
        )
        .toList();
  }

  Future<List<SubjectPerformance>> getSubjectPerformance(int childId) async {
    final rows = await (await database).rawQuery(
      '''
      SELECT s.id AS subject_id, s.name, s.color,
             COALESCE(ROUND(AVG(cp.score), 1), 0) AS average_score,
             COUNT(DISTINCT CASE WHEN cp.score >= 70 THEN cp.topic_id END)
               AS completed_topics,
             COUNT(DISTINCT t.id) AS total_topics
      FROM subjects s
      LEFT JOIN topics t ON t.subject_id = s.id
      LEFT JOIN child_performance cp
        ON cp.topic_id = t.id AND cp.child_id = ?
      GROUP BY s.id
      ORDER BY s.name
    ''',
      [childId],
    );
    return rows
        .map(
          (row) => SubjectPerformance(
            subjectId: row['subject_id']! as int,
            name: row['name']! as String,
            color: row['color']! as String,
            averageScore: (row['average_score'] as num?)?.toDouble() ?? 0,
            completedTopics: row['completed_topics']! as int,
            totalTopics: row['total_topics']! as int,
          ),
        )
        .toList();
  }

  Future<List<TopicPerformance>> getTopicPerformance(int childId) async {
    final rows = await (await database).rawQuery(
      '''
      SELECT t.id AS topic_id, t.subject_id, t.name,
             COALESCE(ROUND(AVG(cp.score), 1), 0) AS score,
             COALESCE(SUM(cp.attempts), 0) AS attempts
      FROM topics t
      LEFT JOIN child_performance cp
        ON cp.topic_id = t.id AND cp.child_id = ?
      GROUP BY t.id
      ORDER BY t.subject_id, t.position
    ''',
      [childId],
    );
    return rows
        .map(
          (row) => TopicPerformance(
            topicId: row['topic_id']! as int,
            subjectId: row['subject_id']! as int,
            name: row['name']! as String,
            score: (row['score'] as num?)?.toDouble() ?? 0,
            attempts: (row['attempts'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
  }

  Future<List<RecentActivity>> getRecentActivity(
    int childId, {
    int limit = 10,
  }) async {
    final rows = await (await database).rawQuery(
      '''
      SELECT la.id, la.activity_type, la.score, la.completed_at,
             t.name AS title
      FROM learning_activity la
      LEFT JOIN topics t ON t.id = la.topic_id
      WHERE la.child_id = ?
      ORDER BY la.completed_at DESC
      LIMIT ?
    ''',
      [childId, limit],
    );
    return rows
        .map(
          (row) => RecentActivity(
            id: row['id']! as int,
            title: row['title'] as String? ?? 'Learning activity',
            activityType: row['activity_type']! as String,
            score: (row['score'] as num?)?.toDouble() ?? 0,
            completedAt: DateTime.parse(row['completed_at']! as String),
          ),
        )
        .toList();
  }

  Future<List<TrendPoint>> getPerformanceTrend(
    int childId, {
    int days = 7,
  }) async {
    final rows = await (await database).rawQuery(
      '''
      SELECT DATE(recorded_at) AS day, ROUND(AVG(score), 1) AS score
      FROM child_performance
      WHERE child_id = ? AND recorded_at >= DATE('now', ?)
      GROUP BY DATE(recorded_at)
      ORDER BY day
    ''',
      [childId, '-$days days'],
    );
    return rows
        .map(
          (row) => TrendPoint(
            date: DateTime.parse(row['day']! as String),
            score: (row['score'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE parents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE children (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        grade TEXT NOT NULL,
        avatar TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (parent_id) REFERENCES parents(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        position INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE child_performance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        topic_id INTEGER NOT NULL,
        score REAL NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 1,
        recorded_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE child_topic_performance (
        child_id INTEGER NOT NULL,
        topic_id INTEGER NOT NULL,
        best_score REAL NOT NULL DEFAULT 0,
        mastery REAL NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        PRIMARY KEY (child_id, topic_id),
        FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE learning_activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        topic_id INTEGER,
        activity_type TEXT NOT NULL,
        score REAL,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> _seedIfEmpty(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM parents'),
    );
    if (count != 0) return;

    await db.transaction((txn) async {
      // ── Parent account ──────────────────────────────────────────────────
      final parentId = await txn.insert('parents', {
        'name': 'Alex Morgan',
        'email': 'parent@learncraft.local',
        'password_hash': _hash('password123'),
      });

      // ── Children ────────────────────────────────────────────────────────
      final jamieId = await txn.insert('children', {
        'parent_id': parentId,
        'name': 'Jamie Morgan',
        'grade': 'Grade 7',
        'avatar': 'jamie',
      });
      final samId = await txn.insert('children', {
        'parent_id': parentId,
        'name': 'Sam Morgan',
        'grade': 'Grade 4',
        'avatar': 'sam',
      });

      // ── Subjects ────────────────────────────────────────────────────────
      final subjects = <String, _SubjectSeed>{
        'Mathematics': _SubjectSeed(color: '#4F46E5', topics: [
          'Fractions and Decimals',
          'Algebraic Expressions',
          'Geometry',
          'Statistics',
          'Ratios and Proportions',
          'Number Theory',
        ]),
        'Science': _SubjectSeed(color: '#059669', topics: [
          'Light and Optics',
          'Acids, Bases & Salts',
          'Force and Motion',
          'Plant Biology',
          'The Solar System',
        ]),
        'English': _SubjectSeed(color: '#D97706', topics: [
          'Grammar Essentials',
          'Creative Writing',
          'Reading Comprehension',
          'Vocabulary Builder',
          'Poetry Analysis',
        ]),
        'History': _SubjectSeed(color: '#DC2626', topics: [
          'Ancient Civilizations',
          'Medieval World',
          'The Renaissance',
          'Modern History',
        ]),
        'Computer Science': _SubjectSeed(color: '#7C3AED', topics: [
          'Intro to Algorithms',
          'Binary & Logic Gates',
          'Scratch Programming',
          'Internet Safety',
          'Data Representation',
        ]),
      };

      final allTopicIds = <int>[];
      final subjectIds = <String, int>{};

      for (final entry in subjects.entries) {
        final sId = await txn.insert('subjects', {
          'name': entry.key,
          'color': entry.value.color,
        });
        subjectIds[entry.key] = sId;
        for (var i = 0; i < entry.value.topics.length; i++) {
          final tId = await txn.insert('topics', {
            'subject_id': sId,
            'name': entry.value.topics[i],
            'position': i,
          });
          allTopicIds.add(tId);
        }
      }

      // ── Jamie's performance (varied, realistic) ─────────────────────────
      final now = DateTime.now();
      // Scores that hit different mastery bands
      final jamieScores = <double>[
        // Math
        86, 74, 91, 68, 82, 79,
        // Science
        93, 72, 85, 60, 88,
        // English
        78, 95, 70, 84, 67,
        // History
        90, 55, 83, 76,
        // CS
        97, 88, 92, 75, 81,
      ];

      final activityTypes = [
        'Quiz completed',
        'Practice session',
        'Flashcard drill',
        'Interactive lesson',
        'Challenge mode',
      ];

      for (var i = 0; i < allTopicIds.length; i++) {
        final recordedAt =
            now.subtract(Duration(days: allTopicIds.length - i, hours: i * 2));
        final score = jamieScores[i % jamieScores.length];
        final attempts = 2 + (i % 4);

        await txn.insert('child_performance', {
          'child_id': jamieId,
          'topic_id': allTopicIds[i],
          'score': score,
          'attempts': attempts,
          'recorded_at': recordedAt.toIso8601String(),
        });
        await txn.insert('child_topic_performance', {
          'child_id': jamieId,
          'topic_id': allTopicIds[i],
          'best_score': score,
          'mastery': score / 100,
          'updated_at': recordedAt.toIso8601String(),
        });
        await txn.insert('learning_activity', {
          'child_id': jamieId,
          'topic_id': allTopicIds[i],
          'activity_type': activityTypes[i % activityTypes.length],
          'score': score,
          'completed_at': recordedAt.toIso8601String(),
        });
      }

      // Add extra recent activities for Jamie to fill the activity feed
      for (var d = 0; d < 8; d++) {
        final at = now.subtract(Duration(hours: 6 + d * 7));
        await txn.insert('learning_activity', {
          'child_id': jamieId,
          'topic_id': allTopicIds[d % allTopicIds.length],
          'activity_type': activityTypes[d % activityTypes.length],
          'score': 65.0 + (d * 4.5),
          'completed_at': at.toIso8601String(),
        });
      }

      // 30-day trend data for Jamie
      for (var d = 30; d >= 0; d--) {
        final date = now.subtract(Duration(days: d));
        // Scores that slowly improve from ~65 to ~85
        final trendScore = 65.0 + (30 - d) * 0.68 + (d.isEven ? 2.5 : -1.2);
        await txn.insert('child_performance', {
          'child_id': jamieId,
          'topic_id': allTopicIds[d % allTopicIds.length],
          'score': trendScore.clamp(40, 100),
          'attempts': 1,
          'recorded_at': date.toIso8601String(),
        });
      }

      // ── Sam's performance (younger child, different profile) ────────────
      final samScores = <double>[
        72, 65, 80, 58, 71, 68,
        82, 60, 74, 55, 77,
        70, 88, 62, 75, 59,
        78, 50, 72, 66,
        90, 80, 85, 65, 73,
      ];

      for (var i = 0; i < allTopicIds.length; i++) {
        final recordedAt =
            now.subtract(Duration(days: allTopicIds.length - i, hours: i * 3));
        final score = samScores[i % samScores.length];
        await txn.insert('child_performance', {
          'child_id': samId,
          'topic_id': allTopicIds[i],
          'score': score,
          'attempts': 1 + (i % 3),
          'recorded_at': recordedAt.toIso8601String(),
        });
        await txn.insert('child_topic_performance', {
          'child_id': samId,
          'topic_id': allTopicIds[i],
          'best_score': score,
          'mastery': score / 100,
          'updated_at': recordedAt.toIso8601String(),
        });
        await txn.insert('learning_activity', {
          'child_id': samId,
          'topic_id': allTopicIds[i],
          'activity_type': activityTypes[(i + 1) % activityTypes.length],
          'score': score,
          'completed_at': recordedAt.toIso8601String(),
        });
      }

      // 30-day trend data for Sam
      for (var d = 30; d >= 0; d--) {
        final date = now.subtract(Duration(days: d));
        final trendScore = 55.0 + (30 - d) * 0.55 + (d.isOdd ? 3.0 : -2.0);
        await txn.insert('child_performance', {
          'child_id': samId,
          'topic_id': allTopicIds[d % allTopicIds.length],
          'score': trendScore.clamp(40, 100),
          'attempts': 1,
          'recorded_at': date.toIso8601String(),
        });
      }
    });
  }

  static String _hash(String value) =>
      sha256.convert(utf8.encode(value)).toString();
}

class _SubjectSeed {
  const _SubjectSeed({required this.color, required this.topics});
  final String color;
  final List<String> topics;
}
