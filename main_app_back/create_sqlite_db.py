"""Creation and Seeding Script for KnowledgeVerse SQLite Database.

Creates a production-ready SQLite database with complete schemas for:
- Parents & Authentication (SHA-256 hashed)
- Children / Students & RPG Progression (XP, Level, Coins, Gems, Energy)
- Subjects (Mathematics, Science, English, History, Computer Science)
- Topics (with difficulty, grade levels, and positions)
- Recommendations (parsed from recommendations_class7_math.json)
- Student Performance & Topic Mastery
- Learning Activity & Quiz History
- Quiz Questions with options and explanations
- Student Inventory items

Outputs the database to:
1. c:\\Users\\Ayon\\hacknex\\database\\knowledgeverse.db
2. c:\\Users\\Ayon\\hacknex\\main_app_back\\database\\knowledgeverse.db
3. c:\\Users\\Ayon\\hacknex\\main_app_back\\knowledgeverse.db
"""

import os
import json
import sqlite3
import hashlib
from datetime import datetime, timedelta

def get_hash(text: str) -> str:
    return hashlib.sha256(text.encode('utf-8')).hexdigest()

def create_and_seed_db(db_path: str):
    os.makedirs(os.path.dirname(os.path.abspath(db_path)), exist_ok=True)
    if os.path.exists(db_path):
        try:
            os.remove(db_path)
        except Exception:
            pass

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Enable WAL mode and foreign keys for high performance and integrity
    cursor.execute("PRAGMA journal_mode = WAL;")
    cursor.execute("PRAGMA foreign_keys = ON;")

    # 1. Parents Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS parents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL COLLATE NOCASE,
        password_hash TEXT NOT NULL,
        phone TEXT,
        created_at TEXT NOT NULL
    );
    """)

    # 2. Children / Students Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS children (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        grade TEXT NOT NULL,
        age INTEGER NOT NULL DEFAULT 12,
        avatar TEXT DEFAULT 'arcanist',
        level INTEGER NOT NULL DEFAULT 12,
        xp INTEGER NOT NULL DEFAULT 850,
        max_xp INTEGER NOT NULL DEFAULT 1500,
        coins INTEGER NOT NULL DEFAULT 2450,
        gems INTEGER NOT NULL DEFAULT 340,
        energy INTEGER NOT NULL DEFAULT 120,
        max_energy INTEGER NOT NULL DEFAULT 120,
        created_at TEXT NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES parents(id) ON DELETE CASCADE
    );
    """)

    # 3. Subjects Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        code TEXT UNIQUE NOT NULL,
        color TEXT NOT NULL,
        icon TEXT,
        description TEXT
    );
    """)

    # 4. Topics Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'Intermediate',
        grade_level INTEGER NOT NULL DEFAULT 7,
        description TEXT,
        position INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
    );
    """)

    # 5. Recommendations Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS recommendations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER,
        topic_id INTEGER,
        topic_name TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        description TEXT NOT NULL,
        activities_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE SET NULL
    );
    """)

    # 6. Child Performance Table (Raw test attempts)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS child_performance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        topic_id INTEGER NOT NULL,
        score REAL NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 1,
        recorded_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
    );
    """)

    # 7. Child Topic Performance (Aggregated Mastery Summary)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS child_topic_performance (
        child_id INTEGER NOT NULL,
        topic_id INTEGER NOT NULL,
        best_score REAL NOT NULL DEFAULT 0,
        mastery REAL NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        PRIMARY KEY (child_id, topic_id),
        FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
    );
    """)

    # 8. Learning Activity Log Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS learning_activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        topic_id INTEGER,
        activity_type TEXT NOT NULL,
        score REAL,
        duration_seconds INTEGER DEFAULT 180,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE SET NULL
    );
    """)

    # 9. Quiz Questions Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS quiz_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        options_json TEXT NOT NULL,
        correct_index INTEGER NOT NULL,
        explanation TEXT NOT NULL,
        difficulty TEXT DEFAULT 'Intermediate',
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
    );
    """)

    # 10. Student Inventory Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS inventory_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        item_type TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        icon TEXT,
        acquired_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE
    );
    """)

    # Indexes for fast querying
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_topics_subject ON topics(subject_id);")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_perf_child ON child_performance(child_id);")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_perf_topic ON child_performance(topic_id);")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_activity_child ON learning_activity(child_id);")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_recommendations_child ON recommendations(child_id);")

    # ─── SEEDING DATA ──────────────────────────────────────────────────────────
    now = datetime.now()
    created_str = (now - timedelta(days=60)).isoformat()

    # 1. Seed Parent
    cursor.execute("""
        INSERT INTO parents (name, email, password_hash, phone, created_at)
        VALUES (?, ?, ?, ?, ?);
    """, (
        'Alex Morgan',
        'parent@learncraft.local',
        get_hash('password123'),
        '+1 (555) 234-5678',
        created_str
    ))
    parent_id = cursor.lastrowid

    # 2. Seed Children
    cursor.execute("""
        INSERT INTO children (parent_id, name, grade, age, avatar, level, xp, max_xp, coins, gems, energy, max_energy, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """, (
        parent_id, 'Jamie Morgan', 'Grade 7', 12, 'arcanist', 12, 850, 1500, 2450, 340, 120, 120, created_str
    ))
    jamie_id = cursor.lastrowid

    cursor.execute("""
        INSERT INTO children (parent_id, name, grade, age, avatar, level, xp, max_xp, coins, gems, energy, max_energy, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """, (
        parent_id, 'Sam Morgan', 'Grade 4', 9, 'scholar', 8, 420, 1000, 1200, 150, 100, 100, created_str
    ))
    sam_id = cursor.lastrowid

    # 3. Seed Subjects
    subject_definitions = [
        ('Mathematics', 'MATH', '#4F46E5', 'calculate_rounded', 'Arithmetic, algebra, calculus, geometry, and number theory.'),
        ('Science', 'SCI', '#059669', 'science_rounded', 'Physics, chemistry, biology, optics, and experimental discovery.'),
        ('Computer Science', 'CS', '#7C3AED', 'computer_rounded', 'Programming logic, algorithms, Dart, Python, and data structures.'),
        ('English', 'ENG', '#D97706', 'menu_book_rounded', 'Grammar, vocabulary, creative writing, and literature comprehension.'),
        ('History', 'HIST', '#DC2626', 'account_balance_rounded', 'Ancient civilizations, world history, and monumental epochs.')
    ]
    subject_map = {}
    for name, code, color, icon, desc in subject_definitions:
        cursor.execute("""
            INSERT INTO subjects (name, code, color, icon, description)
            VALUES (?, ?, ?, ?, ?);
        """, (name, code, color, icon, desc))
        subject_map[name] = cursor.lastrowid

    # 4. Seed Topics
    topic_data = {
        'Mathematics': [
            ('Integers', 'Intermediate', 'Understanding addition, subtraction, multiplication, and division of negative and positive integers.'),
            ('Fractions and Decimals', 'Advanced', 'Mastering multiplication and division of fractions and decimals with recipe models.'),
            ('Simple Equations', 'Beginner', 'Introduction to variables, balancing linear equations, and solving for x.'),
            ('Lines and Angles', 'Intermediate', 'Identifying complementary, supplementary, parallel, and transversal angles.'),
            ('Data Handling', 'Beginner', 'Learning mean, median, mode, probability, and interpreting bar graphs.'),
            ('Algebraic Expressions', 'Intermediate', 'Formulating expressions, terms, coefficients, and like/unlike variables.'),
            ('Geometry', 'Intermediate', 'Properties of triangles, congruence, perimeter, and area calculation.'),
            ('Number Theory', 'Advanced', 'Prime factorization, greatest common divisor, and modular arithmetic.')
        ],
        'Computer Science': [
            ('Intro to Algorithms', 'Beginner', 'Step-by-step problem-solving, flowcharts, and algorithmic thinking.'),
            ('Binary & Logic Gates', 'Intermediate', 'Binary numeral system, AND/OR/NOT logic gates, and boolean truth tables.'),
            ('Variables & Data Types', 'Beginner', 'Understanding integers, floats, strings, booleans, and memory allocation.'),
            ('Conditionals & Loops', 'Intermediate', 'If-else statements, while loops, for loops, and nested control flow.'),
            ('Data Structures', 'Advanced', 'Arrays, lists, stacks, queues, and dictionary hash maps.')
        ],
        'Science': [
            ('Light and Optics', 'Intermediate', 'Reflection, refraction, lenses, and the visible light spectrum.'),
            ('Force and Motion', 'Intermediate', "Newton's laws of motion, gravity, friction, and velocity."),
            ('Acids, Bases & Salts', 'Intermediate', 'pH scale, chemical indicators, neutralization, and practical salts.'),
            ('Plant Biology', 'Beginner', 'Photosynthesis, cellular respiration, stomata, and xylem transport.'),
            ('The Solar System', 'Beginner', 'Planetary orbits, Keplerian mechanics, and astronomical scale.')
        ],
        'English': [
            ('Grammar Essentials', 'Beginner', 'Parts of speech, sentence clauses, subject-verb agreement, and punctuation.'),
            ('Creative Writing', 'Intermediate', 'Narrative arcs, character development, imagery, and poetic metaphors.'),
            ('Reading Comprehension', 'Intermediate', 'Inference, contextual analysis, and identifying thematic cores.')
        ],
        'History': [
            ('Ancient Civilizations', 'Beginner', 'Mesopotamia, Indus Valley, Ancient Egypt, and bronze age technologies.'),
            ('The Renaissance', 'Intermediate', 'Scientific awakening, artistic mastery, printing press, and humanism.')
        ]
    }

    topic_map = {}
    for sub_name, topics in topic_data.items():
        s_id = subject_map[sub_name]
        for pos, (t_name, diff, desc) in enumerate(topics):
            cursor.execute("""
                INSERT INTO topics (subject_id, name, difficulty, grade_level, description, position)
                VALUES (?, ?, ?, ?, ?, ?);
            """, (s_id, t_name, diff, 7, desc, pos))
            topic_map[t_name] = cursor.lastrowid

    # 5. Ingest Recommendations from JSON
    json_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'recommendations_class7_math.json')
    if os.path.exists(json_path):
        with open(json_path, 'r', encoding='utf-8') as f:
            rec_data = json.load(f)
        for item in rec_data.get('recommendations', []):
            t_name = item.get('topic')
            t_id = topic_map.get(t_name)
            activities = json.dumps(item.get('activities', []))
            cursor.execute("""
                INSERT INTO recommendations (child_id, topic_id, topic_name, difficulty, description, activities_json, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?);
            """, (
                jamie_id,
                t_id,
                t_name,
                item.get('difficulty', 'Intermediate'),
                item.get('description', ''),
                activities,
                now.isoformat()
            ))

    # 6. Seed Performance & Topic Mastery for Jamie & Sam
    math_scores = {
        'Integers': (88.0, 3, 0.90),
        'Fractions and Decimals': (92.5, 4, 0.95),
        'Simple Equations': (76.0, 2, 0.78),
        'Lines and Angles': (84.0, 3, 0.85),
        'Data Handling': (95.0, 4, 0.98),
        'Algebraic Expressions': (68.0, 2, 0.70),
        'Geometry': (72.0, 2, 0.72),
        'Number Theory': (64.0, 1, 0.65),
    }

    for t_name, (score, attempts, mastery) in math_scores.items():
        if t_name in topic_map:
            t_id = topic_map[t_name]
            # Raw performance
            cursor.execute("""
                INSERT INTO child_performance (child_id, topic_id, score, attempts, recorded_at)
                VALUES (?, ?, ?, ?, ?);
            """, (jamie_id, t_id, score, attempts, (now - timedelta(days=5)).isoformat()))
            # Summary mastery
            cursor.execute("""
                INSERT INTO child_topic_performance (child_id, topic_id, best_score, mastery, updated_at)
                VALUES (?, ?, ?, ?, ?);
            """, (jamie_id, t_id, score, mastery, now.isoformat()))

    # CS & Science scores
    other_scores = {
        'Intro to Algorithms': (96.0, 3, 0.96),
        'Binary & Logic Gates': (82.0, 2, 0.82),
        'Light and Optics': (89.0, 3, 0.89),
        'Force and Motion': (75.0, 2, 0.75),
    }
    for t_name, (score, attempts, mastery) in other_scores.items():
        if t_name in topic_map:
            t_id = topic_map[t_name]
            cursor.execute("""
                INSERT INTO child_performance (child_id, topic_id, score, attempts, recorded_at)
                VALUES (?, ?, ?, ?, ?);
            """, (jamie_id, t_id, score, attempts, (now - timedelta(days=3)).isoformat()))
            cursor.execute("""
                INSERT INTO child_topic_performance (child_id, topic_id, best_score, mastery, updated_at)
                VALUES (?, ?, ?, ?, ?);
            """, (jamie_id, t_id, score, mastery, now.isoformat()))

    # 7. Seed Learning Activity Logs
    activity_samples = [
        ('Integers', 'Interactive Quiz', 92.0, 140, 1),
        ('Fractions and Decimals', 'Recipe Multiplier Puzzle', 95.0, 220, 2),
        ('Intro to Algorithms', 'Logic Tower Challenge', 100.0, 180, 3),
        ('Lines and Angles', 'Transversal Angle Match', 84.0, 200, 4),
        ('Binary & Logic Gates', 'Logic Gate Circuit Builder', 88.0, 310, 5),
        ('Data Handling', 'Sports Statistics Grapher', 98.0, 160, 6),
        ('Simple Equations', 'Balance Scale Duel', 76.0, 250, 7),
        ('Force and Motion', 'Kinetic Ramp Experiment', 80.0, 190, 8),
    ]

    for t_name, act_type, score, duration, days_ago in activity_samples:
        t_id = topic_map.get(t_name)
        cursor.execute("""
            INSERT INTO learning_activity (child_id, topic_id, activity_type, score, duration_seconds, completed_at)
            VALUES (?, ?, ?, ?, ?, ?);
        """, (
            jamie_id,
            t_id,
            act_type,
            score,
            duration,
            (now - timedelta(days=days_ago, hours=2)).isoformat()
        ))

    # 8. Seed Sample Quiz Questions
    quiz_data = [
        (
            'Integers',
            'What is the result of (-15) + (-8)?',
            ['23', '-23', '-7', '7'],
            1,
            'Adding two negative integers yields a negative integer with their absolute values combined: -15 + -8 = -23.'
        ),
        (
            'Fractions and Decimals',
            'Calculate 3/4 multiplied by 2/5 in simplest form.',
            ['6/20', '3/10', '5/9', '6/9'],
            1,
            'Multiply numerators (3 * 2 = 6) and denominators (4 * 5 = 20). 6/20 simplifies to 3/10 by dividing both by 2.'
        ),
        (
            'Simple Equations',
            'Solve for x: 3x + 7 = 28',
            ['x = 5', 'x = 7', 'x = 9', 'x = 8'],
            1,
            'Subtract 7 from both sides: 3x = 21. Divide by 3: x = 7.'
        ),
        (
            'Binary & Logic Gates',
            'In digital logic, an AND gate outputs 1 only when:',
            ['At least one input is 1', 'Both inputs are 1', 'Both inputs are 0', 'One input is 0'],
            1,
            'An AND gate requires all of its inputs to be high (1) to produce an output of 1.'
        ),
        (
            'Lines and Angles',
            'Two angles are complementary if their sum equals:',
            ['180 degrees', '90 degrees', '360 degrees', '45 degrees'],
            1,
            'Complementary angles add up to 90 degrees; supplementary angles add up to 180 degrees.'
        )
    ]

    for t_name, q_text, options, correct_idx, expl in quiz_data:
        t_id = topic_map.get(t_name)
        if t_id:
            cursor.execute("""
                INSERT INTO quiz_questions (topic_id, question, options_json, correct_index, explanation)
                VALUES (?, ?, ?, ?, ?);
            """, (t_id, q_text, json.dumps(options), correct_idx, expl))

    # 9. Seed Inventory Items for Jamie
    inventory = [
        ('Arcane Compass', 'Artifact', 1, 'explore'),
        ('Focus Crystal', 'Consumable', 15, 'diamond'),
        ('Golden Quill', 'Tool', 1, 'edit'),
        ('Spell Scroll: Linear Equations', 'Scroll', 3, 'auto_stories'),
        ('Academy Shield of Valor', 'Armor', 1, 'shield')
    ]
    for name, itype, qty, icon in inventory:
        cursor.execute("""
            INSERT INTO inventory_items (child_id, item_name, item_type, quantity, icon, acquired_at)
            VALUES (?, ?, ?, ?, ?, ?);
        """, (jamie_id, name, itype, qty, icon, created_str))

    conn.commit()
    conn.close()

if __name__ == '__main__':
    # Build database at main locations
    locations = [
        r"C:\Users\Ayon\hacknex\database\knowledgeverse.db",
        r"C:\Users\Ayon\hacknex\main_app_back\database\knowledgeverse.db",
        r"C:\Users\Ayon\hacknex\main_app_back\knowledgeverse.db"
    ]
    for loc in locations:
        create_and_seed_db(loc)
        size = os.path.getsize(loc)
        print(f"[SUCCESS] Created database at: {loc} ({size:,} bytes)")
