import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:lichess_mobile/src/features/puzzle/data/offline_puzzle_db.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/common/perf.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';

class OfflinePuzzleRepository {
  final Set<String> _servedIds = <String>{};
  Future<Puzzle> nextPuzzle({String? theme, required int targetRating}) async {
    for (final window in const [150, 300, 450]) {
      final puzzle = await _query(theme: theme, targetRating: targetRating, window: window);
      if (puzzle != null) return puzzle;
    }
    _servedIds.clear();
    final puzzle = await _query(theme: theme, targetRating: targetRating, window: 150);
    if (puzzle != null) return puzzle;
    throw StateError('No offline puzzles available for the requested filters.');
  }

  Future<List<Puzzle>> batch({required int count, String? theme, required int targetRating}) async {
    final puzzles = <Puzzle>[];
    for (var i = 0; i < count; i++) {
      puzzles.add(await nextPuzzle(theme: theme, targetRating: targetRating));
    }
    return puzzles;
  }

  Future<Puzzle?> _query({String? theme, required int targetRating, required int window}) async {
    final db = await OfflinePuzzleDb.database;
    final args = <Object?>[targetRating - window, targetRating + window];
    final where = StringBuffer('rating BETWEEN ? AND ?');
    if (theme != null && theme != 'mix') {
      where.write(" AND (' ' || themes || ' ') LIKE ?");
      args.add('% $theme %');
    }
    if (_servedIds.isNotEmpty) {
      where.write(' AND id NOT IN (${List.filled(_servedIds.length, '?').join(',')})');
      args.addAll(_servedIds);
    }
    final rows = await db.query(
      'puzzles',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'RANDOM()',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final puzzle = _fromRow(rows.single);
    _servedIds.add(puzzle.puzzle.id.value);
    return puzzle;
  }

  Puzzle _fromRow(Map<String, Object?> row) {
    final id = row['id']! as String;
    final fen = row['fen']! as String;
    final moves = (row['moves']! as String).split(' ').where((m) => m.isNotEmpty).toList();
    final themes = (row['themes'] as String? ?? '').split(' ').where((t) => t.isNotEmpty).toSet();
    final sanMoves = _sanMovesFromFen(fen, moves);
    final initialPly = Chess.fromSetup(Setup.parseFen(fen)).ply;
    return Puzzle(
      puzzle: PuzzleData(
        id: PuzzleId(id),
        rating: row['rating']! as int,
        plays: 0,
        initialPly: initialPly,
        solution: moves.lock,
        themes: themes.lock,
      ),
      game: PuzzleGame(
        id: GameId(_gameId(id)),
        perf: Perf.puzzle,
        rated: false,
        white: const PuzzleGamePlayer(side: Side.white, name: 'Offline'),
        black: const PuzzleGamePlayer(side: Side.black, name: 'Puzzle'),
        pgn: '__fen__ $fen __moves__ ${sanMoves.join(' ')}',
      ),
    );
  }

  String _gameId(String id) {
    final normalized = id.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), 'x');
    return normalized.padRight(8, 'x').substring(0, 8);
  }

  List<String> _sanMovesFromFen(String fen, List<String> uciMoves) {
    Position position = Chess.fromSetup(Setup.parseFen(fen));
    final sanMoves = <String>[];
    for (final uci in uciMoves) {
      final move = Move.parse(uci)!;
      final san = position.makeSanUnchecked(move).$2;
      sanMoves.add(san);
      position = position.playUnchecked(move);
    }
    return sanMoves;
  }
}
