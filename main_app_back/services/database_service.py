"""SQLite Database Service for KnowledgeVerse Backend.

Provides connection management and CRUD operations for:
- Student profiles and RPG stats
- Parent accounts & Child performance tracking
- Subjects, Topics, and AI Recommendations
- Learning activity logging & Quiz questions
"""

import os
import sqlite3
import json
from typing import List, Dict, Any, Optional

DB_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'knowledgeverse.db'))
FALLBACK_DB_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'database', 'knowledgeverse.db'))

def get_db_path() -> str:
    if os.path.exists(DB_PATH):
        return DB_PATH
    if os.path.exists(FALLBACK_DB_PATH):
        return FALLBACK_DB_PATH
    return DB_PATH

def get_connection() -> sqlite3.Connection:
    conn = sqlite3.connect(get_db_path())
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn

def get_student_profile(student_id: int = 1) -> Optional[Dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM children WHERE id = ?;", (student_id,))
        row = cursor.fetchone()
        return dict(row) if row else None

def get_recommendations(student_id: int = 1) -> List[Dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT r.*, t.name as topic_title, s.name as subject_name
            FROM recommendations r
            LEFT JOIN topics t ON t.id = r.topic_id
            LEFT JOIN subjects s ON s.id = t.subject_id
            WHERE r.child_id = ?
            ORDER BY r.id ASC;
        """, (student_id,))
        results = []
        for r in cursor.fetchall():
            item = dict(r)
            try:
                item['activities'] = json.loads(item.get('activities_json', '[]'))
            except Exception:
                item['activities'] = []
            results.append(item)
        return results

def get_subjects_with_progress(student_id: int = 1) -> List[Dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT s.id, s.name, s.code, s.color, s.icon, s.description,
                   COALESCE(ROUND(AVG(cp.score), 1), 0) AS average_score,
                   COUNT(DISTINCT CASE WHEN cp.score >= 70 THEN cp.topic_id END) AS completed_topics,
                   COUNT(DISTINCT t.id) AS total_topics
            FROM subjects s
            LEFT JOIN topics t ON t.subject_id = s.id
            LEFT JOIN child_performance cp ON cp.topic_id = t.id AND cp.child_id = ?
            GROUP BY s.id
            ORDER BY s.id ASC;
        """, (student_id,))
        return [dict(row) for row in cursor.fetchall()]

def get_recent_activities(student_id: int = 1, limit: int = 10) -> List[Dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT la.id, la.activity_type, la.score, la.duration_seconds, la.completed_at,
                   t.name AS topic_name, s.name AS subject_name, s.color AS subject_color
            FROM learning_activity la
            LEFT JOIN topics t ON t.id = la.topic_id
            LEFT JOIN subjects s ON s.id = t.subject_id
            WHERE la.child_id = ?
            ORDER BY la.completed_at DESC
            LIMIT ?;
        """, (student_id, limit))
        return [dict(row) for row in cursor.fetchall()]

def record_activity(student_id: int, topic_id: Optional[int], activity_type: str, score: float, duration_seconds: int = 180) -> int:
    from datetime import datetime
    now_str = datetime.now().isoformat()
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO learning_activity (child_id, topic_id, activity_type, score, duration_seconds, completed_at)
            VALUES (?, ?, ?, ?, ?, ?);
        """, (student_id, topic_id, activity_type, score, duration_seconds, now_str))
        conn.commit()
        return cursor.lastrowid

def get_quiz_questions(topic_id: int) -> List[Dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM quiz_questions WHERE topic_id = ?;", (topic_id,))
        rows = []
        for r in cursor.fetchall():
            q = dict(r)
            try:
                q['options'] = json.loads(q.get('options_json', '[]'))
            except Exception:
                q['options'] = []
            rows.append(q)
        return rows
