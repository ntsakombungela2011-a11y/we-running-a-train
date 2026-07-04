import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/common/service/sound_service.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_service.dart';

part 'puzzle_streak.freezed.dart';
part 'puzzle_streak.g.dart';

typedef Streak = IList<PuzzleId>;

@Freezed(fromJson: true, toJson: true)
class PuzzleStreak with _$PuzzleStreak {
  const PuzzleStreak._();

  const factory PuzzleStreak({
    required Streak streak,
    required int index,
    required bool hasSkipped,
    required bool finished,
    required DateTime timestamp,
  }) = _PuzzleStreak;

  PuzzleId? get nextId => index < 1000 ? const PuzzleId('streak_next') : null;

  factory PuzzleStreak.fromJson(Map<String, dynamic> json) =>
      _$PuzzleStreakFromJson(json);
}

typedef StreakState = ({
  PuzzleStreak streak,
  Puzzle puzzle,
  Puzzle? nextPuzzle,
});

final puzzleStreakControllerProvider =
    AsyncNotifierProvider.autoDispose<PuzzleStreakController, StreakState>(
  PuzzleStreakController.new,
  name: 'PuzzleStreakControllerProvider',
);

class PuzzleStreakController extends AsyncNotifier<StreakState> {
  @override
  Future<StreakState> build() async {
    final service = await ref.watch(puzzleServiceProvider.future);
    final ctx = await service.nextPuzzle(userId: null);
    final nextCtx = await service.nextPuzzle(userId: null);

    return (
      streak: PuzzleStreak(
        streak: IList([ctx!.puzzle.puzzle.id]),
        index: 0,
        hasSkipped: false,
        finished: false,
        timestamp: DateTime.now(),
      ),
      puzzle: ctx.puzzle,
      nextPuzzle: nextCtx?.puzzle,
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

  Future<void> next() async {
    if (!state.hasValue || state.requireValue.nextPuzzle == null) {
      return;
    }
    ref.read(soundServiceProvider).play(Sound.confirmation);

    final service = await ref.read(puzzleServiceProvider.future);
    final nextNextCtx = await service.nextPuzzle(userId: null);

    state = AsyncData((
      streak: state.requireValue.streak.copyWith(
        index: state.requireValue.streak.index + 1,
      ),
      puzzle: state.requireValue.nextPuzzle!,
      nextPuzzle: nextNextCtx?.puzzle,
    ));
  }

  Future<void> gameOver() async {
    if (!state.hasValue) return;
    state = AsyncData((
      streak: state.requireValue.streak.copyWith(finished: true),
      puzzle: state.requireValue.puzzle,
      nextPuzzle: state.requireValue.nextPuzzle,
    ));
  }
}
