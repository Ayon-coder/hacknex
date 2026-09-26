# KnowledgeVerse SQLite Databases

This directory contains the central SQLite database files for the KnowledgeVerse ecosystem (FastAPI backend + Flutter frontend).

---

## Database File Locations

| Database | Primary Absolute Path | Size | Description |
| :--- | :--- | :--- | :--- |
| **`knowledgeverse.db`** | `C:\Users\Ayon\hacknex\database\knowledgeverse.db` | ~94 KB | Unified SQLite database with student RPG progression, parents, subjects, topics, recommendations, performance, quizzes & inventory |
| **`parent_dashboard.db`** | `C:\Users\Ayon\hacknex\database\parent_dashboard.db` | ~57 KB | Flutter desktop parent dashboard database (synced from `.dart_tool/sqflite_common_ffi/databases`) |

> **Backend Local Copy**: Also mirrored directly at `C:\Users\Ayon\hacknex\main_app_back\knowledgeverse.db` for backend CLI scripts and FastAPI services.

---

## Schema Overview (`knowledgeverse.db`)

1. **`parents`**:
   - `id`, `name`, `email`, `password_hash` (SHA-256), `phone`, `created_at`
   - Default login: `parent@learncraft.local` / `password123`

2. **`children`**:
   - `id`, `parent_id`, `name`, `grade`, `age`, `avatar`, `level`, `xp`, `max_xp`, `coins`, `gems`, `energy`, `max_energy`, `created_at`
   - Default accounts: Jamie Morgan (Grade 7, Lvl 12, 850 XP), Sam Morgan (Grade 4)

3. **`subjects`**:
   - `id`, `name`, `code`, `color`, `icon`, `description`
   - Mathematics, Science, Computer Science, English, History

4. **`topics`**:
   - `id`, `subject_id`, `name`, `difficulty`, `grade_level`, `description`, `position`

5. **`recommendations`**:
   - `id`, `child_id`, `topic_id`, `topic_name`, `difficulty`, `description`, `activities_json`, `created_at`
   - Ingested directly from `recommendations_class7_math.json`

6. **`child_performance` & `child_topic_performance`**:
   - Real test attempts and aggregated topic mastery percentages

7. **`learning_activity`**:
   - Activity logs, scores, completion timestamps, and duration

8. **`quiz_questions`**:
   - Interactive quiz questions with options JSON, correct answers, and explanations

9. **`inventory_items`**:
   - In-game RPG items, quantities, and categories

---

## Quick Usage

### Python (sqlite3)
```python
import sqlite3

conn = sqlite3.connect(r'C:\Users\Ayon\hacknex\database\knowledgeverse.db')
cursor = conn.cursor()
cursor.execute("SELECT name, grade, level, xp, coins, gems FROM children;")
print(cursor.fetchall())
```

### Python FastAPI Service (`main_app_back`)
```python
from services.database_service import get_student_profile, get_recommendations

student = get_student_profile(student_id=1)
recs = get_recommendations(student_id=1)
```

### Re-generating / Re-seeding the Database
To reset and re-seed all tables at any time, run:
```bash
python c:\Users\Ayon\hacknex\main_app_back\create_sqlite_db.py
```
