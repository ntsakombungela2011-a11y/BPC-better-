#!/bin/bash
set -e

PUZZLE_CSV_URL="https://database.lichess.org/lichess_db_puzzle.csv.zst"
OUTPUT_CSV="assets/puzzles.csv"
OUTPUT_DB="assets/puzzles.db"

echo "Downloading Lichess puzzles CSV..."
curl -L $PUZZLE_CSV_URL -o assets/puzzles.csv.zst

echo "Decompressing CSV..."
zstd -d assets/puzzles.csv.zst -o $OUTPUT_CSV

echo "Generating SQLite database..."
python3 scripts/generate_puzzles_db.py $OUTPUT_CSV $OUTPUT_DB

echo "Cleaning up..."
rm assets/puzzles.csv.zst $OUTPUT_CSV
