import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/common/service/sound_service.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_providers.dart';

part 'puzzle_streak.freezed.dart';
part 'puzzle_streak.g.dart';

typedef Streak = IList<PuzzleId>;

@Freezed(fromJson: true, toJson: true)
sealed class PuzzleStreak with _$PuzzleStreak {
  const PuzzleStreak._();

  const factory PuzzleStreak({
    required Streak streak,
    required int index,
    required bool hasSkipped,
    required bool finished,
    required DateTime timestamp,
  }) = _PuzzleStreak;

  PuzzleId? get nextId => streak.getOrNull(index + 1);

  factory PuzzleStreak.fromJson(Map<String, dynamic> json) => _$PuzzleStreakFromJson(json);
}

/// [PuzzleStreak] with its current [Puzzle].
typedef StreakState = ({PuzzleStreak streak, Puzzle puzzle, Puzzle? nextPuzzle});

final puzzleStreakControllerProvider =
    AsyncNotifierProvider.autoDispose<PuzzleStreakController, StreakState>(
      PuzzleStreakController.new,
      name: 'PuzzleStreakControllerProvider',
    );

class PuzzleStreakController extends AsyncNotifier<StreakState> {
  @override
  Future<StreakState> build() async {
    final service = await ref.watch(localStreakServiceProvider.future);
    final puzzle = await service.nextPuzzle();
    final nextPuzzle = await service.nextPuzzle();

    return (
      streak: PuzzleStreak(
        streak: IList([puzzle.puzzle.id, nextPuzzle.puzzle.id]),
        index: service.current,
        hasSkipped: false,
        finished: false,
        timestamp: DateTime.now(),
      ),
      puzzle: puzzle,
      nextPuzzle: nextPuzzle,
    );
  }

  void skipMove() {
    if (!state.hasValue) return;

    state = AsyncData((
      streak: state.requireValue.streak.copyWith(hasSkipped: true),
      puzzle: state.requireValue.puzzle,
      nextPuzzle: state.requireValue.nextPuzzle,
    ));
  }

  /// Advance the streak to the next puzzle.
  Future<void> next() async {
    if (!state.hasValue || state.requireValue.nextPuzzle == null) {
      return;
    }
    ref.read(soundServiceProvider).play(Sound.confirmation);

    final service = await ref.read(localStreakServiceProvider.future);
    await service.onCorrect();

    state = AsyncData((
      streak: state.requireValue.streak.copyWith(index: service.current),
      puzzle: state.requireValue.nextPuzzle!,
      nextPuzzle: null,
    ));

    final nextPuzzle = await service.nextPuzzle();
    state = AsyncData((
      streak: state.requireValue.streak.copyWith(
        streak: IList([state.requireValue.puzzle.puzzle.id, nextPuzzle.puzzle.id]),
      ),
      puzzle: state.requireValue.puzzle,
      nextPuzzle: nextPuzzle,
    ));
  }

  Future<void> gameOver() async {
    if (!state.hasValue) return;

    final service = await ref.read(localStreakServiceProvider.future);
    await service.onFail();

    state = AsyncData((
      streak: state.requireValue.streak.copyWith(finished: true),
      puzzle: state.requireValue.puzzle,
      nextPuzzle: state.requireValue.nextPuzzle,
    ));
  }
}
