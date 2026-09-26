"""KnowledgeVerse SQLite Database Viewer.

Usage:
    python view.py              -> Displays all tables and summary data
    python view.py <table_name> -> Displays all rows from a specific table
    python view.py tables       -> Lists all tables and column schemas
"""

import sys
import sqlite3
import json

DB_PATH = r"C:\Users\Ayon\hacknex\database\knowledgeverse.db"

def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def print_separator(title="", width=80):
    if title:
        print(f"\n{'=' * 4} [ {title} ] {'=' * max(2, width - len(title) - 10)}")
    else:
        print("=" * width)

def list_tables(conn):
    cursor = conn.cursor()
    cursor.execute("""
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name NOT LIKE 'sqlite_%' 
        ORDER BY name;
    """)
    tables = [row['name'] for row in cursor.fetchall()]
    return tables

def show_table_overview(conn):
    tables = list_tables(conn)
    print_separator("DATABASE OVERVIEW: knowledgeverse.db")
    print(f"File Location: {DB_PATH}")
    print(f"{'Table Name':<28} | {'Row Count':<10} | Columns")
    print("-" * 80)
    
    cursor = conn.cursor()
    for table in tables:
        cursor.execute(f"SELECT COUNT(*) as count FROM {table};")
        count = cursor.fetchone()['count']
        cursor.execute(f"PRAGMA table_info({table});")
        cols = [col['name'] for col in cursor.fetchall()]
        cols_preview = ", ".join(cols[:5]) + ("..." if len(cols) > 5 else "")
        print(f"{table:<28} | {count:<10} | {cols_preview}")

def print_table_data(conn, table_name, limit=15):
    cursor = conn.cursor()
    try:
        cursor.execute(f"SELECT * FROM {table_name} LIMIT {limit};")
        rows = cursor.fetchall()
        if not rows:
            print(f"Table '{table_name}' is currently empty.")
            return

        cols = rows[0].keys()
        print_separator(f"TABLE: {table_name} (Showing up to {limit} rows)")
        
        # Format columns dynamically
        header = " | ".join(f"{col:<18}" for col in cols)
        print(header)
        print("-" * len(header))
        for row in rows:
            row_vals = []
            for col in cols:
                val = row[col]
                if isinstance(val, str) and (val.startswith('[') or val.startswith('{')):
                    try:
                        parsed = json.loads(val)
                        val_str = json.dumps(parsed)[:15] + ".."
                    except Exception:
                        val_str = str(val)[:15]
                else:
                    val_str = str(val)[:18] if val is not None else "NULL"
                row_vals.append(f"{val_str:<18}")
            print(" | ".join(row_vals))
    except sqlite3.OperationalError as e:
        print(f"Error querying '{table_name}': {e}")

def main():
    conn = get_connection()
    tables = list_tables(conn)

    if len(sys.argv) > 1:
        arg = sys.argv[1].lower()
        if arg == 'tables':
            show_table_overview(conn)
        elif arg in [t.lower() for t in tables]:
            # Find exact casing
            target = next(t for t in tables if t.lower() == arg)
            print_table_data(conn, target, limit=50)
        else:
            print(f"Unknown table '{sys.argv[1]}'. Available tables:")
            print(", ".join(tables))
    else:
        # Default run: Show summary and key samples
        show_table_overview(conn)
        print_table_data(conn, 'children', limit=5)
        print_table_data(conn, 'recommendations', limit=5)
        print_table_data(conn, 'subjects', limit=5)
        print_table_data(conn, 'topics', limit=6)
        print("\nTip: Run `python view.py <table_name>` to view specific tables (e.g. `python view.py quiz_questions`)")

    conn.close()

if __name__ == '__main__':
    main()
