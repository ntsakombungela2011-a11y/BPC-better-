import 'package:lichess_mobile/src/features/puzzle/data/offline_puzzle_repository.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStreakService {
  LocalStreakService(this._prefs, this._repository);

  static const _currentKey = 'offline_puzzle_streak.current';
  static const _bestKey = 'offline_puzzle_streak.best';

  final SharedPreferences _prefs;
  final OfflinePuzzleRepository _repository;

  int get current => _prefs.getInt(_currentKey) ?? 0;
  int get best => _prefs.getInt(_bestKey) ?? 0;

  Future<Puzzle> nextPuzzle({String? theme}) {
    final targetRating = (1200 + current * 20).clamp(800, 2400).toInt();
    return _repository.nextPuzzle(theme: theme, targetRating: targetRating);
  }

  Future<void> onCorrect() async {
    final next = current + 1;
    await _prefs.setInt(_currentKey, next);
    if (next > best) await _prefs.setInt(_bestKey, next);
  }

  Future<void> onFail() => _prefs.setInt(_currentKey, 0);

  Future<void> reset() async {
    await _prefs.setInt(_currentKey, 0);
    await _prefs.setInt(_bestKey, 0);
  }
}
