import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/db/database.dart';
import 'package:lichess_mobile/src/model/explorer/opening_explorer.dart';
import 'package:sqflite/sqflite.dart';

const kOpeningExplorerCacheTable = 'opening_explorer_cache';

final openingExplorerCacheStorageProvider = FutureProvider<OpeningExplorerCacheStorage>((Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return OpeningExplorerCacheStorage(db);
}, name: 'OpeningExplorerCacheStorageProvider');

class OpeningExplorerCacheStorage {
  const OpeningExplorerCacheStorage(this._db);

  final Database _db;

  Future<OpeningExplorerEntry?> fetch(String cacheKey) async {
    final rows = await _db.query(
      kOpeningExplorerCacheTable,
      columns: ['data'],
      where: 'cacheKey = ?',
      whereArgs: [cacheKey],
      limit: 1,
    );
    final data = rows.isEmpty ? null : rows.first['data'];
    if (data is! String) return null;
    final json = jsonDecode(data);
    if (json is! Map<String, dynamic>) return null;
    return OpeningExplorerEntry.fromJson(json);
  }

  Future<void> save(String cacheKey, OpeningExplorerEntry entry) async {
    await _db.insert(
      kOpeningExplorerCacheTable,
      {
        'cacheKey': cacheKey,
        'lastModified': DateTime.now().toIso8601String(),
        'data': jsonEncode(_entryToJson(entry)),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

Map<String, dynamic> _entryToJson(OpeningExplorerEntry entry) => {
  'white': entry.white,
  'draws': entry.draws,
  'black': entry.black,
  'moves': entry.moves.map(_moveToJson).toList(),
  if (entry.topGames != null) 'topGames': entry.topGames!.map(_gameToJson).toList(),
  if (entry.recentGames != null) 'recentGames': entry.recentGames!.map(_gameToJson).toList(),
  if (entry.opening != null) 'opening': entry.opening!.toJson(),
  if (entry.queuePosition != null) 'queuePosition': entry.queuePosition,
};

Map<String, dynamic> _moveToJson(OpeningMove move) => {
  'uci': move.uci,
  'san': move.san,
  'white': move.white,
  'draws': move.draws,
  'black': move.black,
  if (move.averageRating != null) 'averageRating': move.averageRating,
  if (move.averageOpponentRating != null) 'averageOpponentRating': move.averageOpponentRating,
  if (move.performance != null) 'performance': move.performance,
  if (move.game != null) 'game': _gameToJson(move.game!),
};

Map<String, dynamic> _gameToJson(OpeningExplorerGame game) => {
  'id': game.id.toString(),
  'white': {'name': game.white.name, 'rating': game.white.rating},
  'black': {'name': game.black.name, 'rating': game.black.rating},
  if (game.uci != null) 'uci': game.uci,
  if (game.winner != null) 'winner': game.winner,
  if (game.speed != null) 'speed': game.speed!.key,
  if (game.mode != null) 'mode': game.mode!.name,
  if (game.year != null) 'year': game.year,
  if (game.month != null) 'month': game.month,
};
