import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class OfflinePuzzleDb {
  OfflinePuzzleDb._();

  static Database? _database;

  static Future<Database> get database async {
    final open = _database;
    if (open != null && open.isOpen) return open;

    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, 'bpc_puzzles.db');
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      await Directory(databasesPath).create(recursive: true);
      final bytes = await rootBundle.load('assets/puzzles.db');
      await dbFile.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    }

    _database = await openDatabase(dbPath, readOnly: true, singleInstance: true);
    return _database!;
  }
}
