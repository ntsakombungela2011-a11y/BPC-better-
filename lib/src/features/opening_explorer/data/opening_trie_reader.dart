import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class OpeningExplorerResult {
  const OpeningExplorerResult({required this.name, required this.moves});

  final String? name;
  final List<OpeningMove> moves;
}

class OpeningMove {
  const OpeningMove({required this.uci, this.name});

  final String uci;
  final String? name;
}

class OpeningTrieReader {
  final _OpeningTrieNode _root = _OpeningTrieNode();
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;

    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, 'bpc_openings.db');
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      await Directory(databasesPath).create(recursive: true);
      final bytes = await rootBundle.load('assets/openings/openings.db');
      await dbFile.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    }

    final db = await openDatabase(dbPath, readOnly: true, singleInstance: true);
    try {
      final rows = await db.query('openings', columns: ['eco', 'name', 'moves']);
      for (final row in rows) {
        final eco = row['eco']! as String;
        final name = row['name']! as String;
        final moves = (row['moves']! as String).split(' ').where((move) => move.isNotEmpty);
        _insert(moves, '$eco $name');
      }
      _loaded = true;
    } finally {
      await db.close();
    }
  }

  OpeningExplorerResult? query(List<String> uciMoves) {
    var node = _root;
    String? bestName;
    for (final move in uciMoves) {
      final next = node.children[move];
      if (next == null) return null;
      node = next;
      bestName = node.name ?? bestName;
    }

    final moves = node.children.entries
        .map((entry) => OpeningMove(uci: entry.key, name: entry.value.name))
        .toList(growable: false);
    return OpeningExplorerResult(name: bestName, moves: moves);
  }

  void _insert(Iterable<String> moves, String name) {
    var node = _root;
    for (final move in moves) {
      node = node.children.putIfAbsent(move, _OpeningTrieNode.new);
    }
    node.name = name;
  }
}

class _OpeningTrieNode {
  final Map<String, _OpeningTrieNode> children = <String, _OpeningTrieNode>{};
  String? name;
}
