import json
import sqlite3
import sys
import os

def generate_openings_db(json_path, db_path):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE openings (
            eco TEXT,
            name TEXT,
            moves TEXT
        )
    ''')

    with open(json_path, 'r') as f:
        openings = json.load(f)

    batch = []
    for opening in openings:
        batch.append((opening['eco'], opening['name'], ' '.join(opening['moves'])))

    cur.executemany('INSERT INTO openings VALUES (?, ?, ?)', batch)
    conn.commit()
    conn.close()

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python generate_openings_db.py <json_path> <db_path>")
        sys.exit(1)
    generate_openings_db(sys.argv[1], sys.argv[2])
