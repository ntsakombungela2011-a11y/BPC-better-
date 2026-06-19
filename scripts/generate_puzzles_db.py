import csv
import sqlite3
import sys

def generate_puzzles_db(csv_path, db_path):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute('DROP TABLE IF EXISTS puzzles')
    cur.execute('''
        CREATE TABLE puzzles (
            id TEXT PRIMARY KEY,
            fen TEXT,
            moves TEXT,
            rating INTEGER,
            rating_dev INTEGER,
            themes TEXT,
            opening_tags TEXT
        )
    ''')

    with open(csv_path, 'r') as f:
        reader = csv.reader(f)
        header = next(reader) # Skip header

        batch = []
        for row in reader:
            if not row: continue
            # id, fen, moves, rating, rating_dev, themes, opening_tags
            # 0, 1, 2, 3, 4, 7, 9
            batch.append((row[0], row[1], row[2], int(row[3]), int(row[4]), row[7], row[9] if len(row) > 9 else None))
            if len(batch) >= 10000:
                cur.executemany('INSERT INTO puzzles VALUES (?, ?, ?, ?, ?, ?, ?)', batch)
                batch = []
        if batch:
            cur.executemany('INSERT INTO puzzles VALUES (?, ?, ?, ?, ?, ?, ?)', batch)

    conn.commit()
    conn.close()

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python generate_puzzles_db.py <csv_path> <db_path>")
        sys.exit(1)
    generate_puzzles_db(sys.argv[1], sys.argv[2])
