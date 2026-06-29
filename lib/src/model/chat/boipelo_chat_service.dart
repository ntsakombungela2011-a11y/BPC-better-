import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/db/database.dart';
import 'package:lichess_mobile/src/model/chat/boipelo_chat_model.dart';
import 'package:sqflite/sqflite.dart';

const _kBoipeloUserId = 'boipelo';

final boipeloChatServiceProvider = Provider<BoipeloChatService>((ref) {
  final dbAsync = ref.watch(databaseProvider.future);
  return BoipeloChatService(dbAsync);
});

class BoipeloChatService {
  BoipeloChatService(this._dbAsync);

  final Future<Database> _dbAsync;

  Future<void> _ensureTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS boipelo_chat_messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderId TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'sent'
      )
    ''');
  }

  Future<void> saveMessage(BoipeloChatMessage message) async {
    final db = await _dbAsync;
    await _ensureTable(db);
    await db.insert('boipelo_chat_messages', message.toDbRow());
  }

  Future<void> updateMessageStatus(int messageId, MessageStatus status) async {
    final db = await _dbAsync;
    await db.update(
      'boipelo_chat_messages',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<List<BoipeloChatMessage>> loadMessages({int limit = 50, int? offset}) async {
    final db = await _dbAsync;
    await _ensureTable(db);
    final rows = await db.query(
      'boipelo_chat_messages',
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
    return rows.reversed.map((row) => BoipeloChatMessage.fromDbRow(row)).toList();
  }

  Future<int> getUnreadCount() async {
    final db = await _dbAsync;
    try {
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM boipelo_chat_messages
        WHERE senderId = ? AND status != 'read'
      ''', [_kBoipeloUserId]);
      return (result.first['count'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markAllAsRead() async {
    final db = await _dbAsync;
    try {
      await db.update(
        'boipelo_chat_messages',
        {'status': 'read'},
        where: 'senderId = ? AND status != ?',
        whereArgs: [_kBoipeloUserId, 'read'],
      );
    } catch (_) {}
  }

  Future<List<BoipeloChatMessage>> loadAllMessages() async {
    final db = await _dbAsync;
    await _ensureTable(db);
    final rows = await db.query(
      'boipelo_chat_messages',
      orderBy: 'timestamp ASC',
    );
    return rows.map((row) => BoipeloChatMessage.fromDbRow(row)).toList();
  }

  Future<int> getMessageCount() async {
    final db = await _dbAsync;
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM boipelo_chat_messages');
      return (result.first['count'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
