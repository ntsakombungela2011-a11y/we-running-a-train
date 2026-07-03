import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_angle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_batch_storage.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_opening.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_repository.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_service.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_storage.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_theme.dart';
import 'package:lichess_mobile/src/model/puzzle/storm.dart';
import 'package:lichess_mobile/src/network/http.dart';
import 'package:lichess_mobile/src/utils/riverpod.dart';

final nextPuzzleProvider = FutureProvider.autoDispose
    .family<PuzzleContext?, PuzzleAngle>((Ref ref, PuzzleAngle angle) async {
      final authUser = ref.watch(authControllerProvider);
      final puzzleService = await ref.watch(puzzleServiceProvider.future);
      return puzzleService.nextPuzzle(userId: authUser?.user.id, angle: angle);
    });

final puzzleProvider = FutureProvider.autoDispose.family<Puzzle, PuzzleId>((
  Ref ref,
  PuzzleId id,
) async {
  final puzzleService = await ref.watch(puzzleServiceProvider.future);
  final ctx = await puzzleService.nextPuzzle(userId: null);
  return ctx!.puzzle;
});

final dailyPuzzleProvider = FutureProvider.autoDispose<Puzzle>((Ref ref) async {
  final puzzleService = await ref.watch(puzzleServiceProvider.future);
  final ctx = await puzzleService.nextPuzzle(userId: null);
  return ctx!.puzzle;
});

final savedBatchesProvider =
    FutureProvider.autoDispose<IList<(PuzzleAngle, int)>>((Ref ref) async {
      return const IListConst([]);
    });

final savedThemeBatchesProvider =
    FutureProvider.autoDispose<IMap<PuzzleThemeKey, int>>((Ref ref) async {
      return const IMapConst({});
    });

final savedOpeningBatchesProvider =
    FutureProvider.autoDispose<IMap<String, int>>((Ref ref) async {
      return const IMapConst({});
    });

final puzzleDashboardProvider = FutureProvider.autoDispose
    .family<PuzzleDashboard?, int>((Ref ref, int days) {
      return null;
    });

final puzzleRecentActivityProvider =
    FutureProvider.autoDispose<IList<PuzzleHistoryEntry>?>((Ref ref) {
      return const IListConst([]);
    });

final puzzleThemesProvider =
    FutureProvider.autoDispose<IMap<PuzzleThemeKey, PuzzleThemeData>>((
      Ref ref,
    ) {
       return const IMapConst({});
    });

final puzzleOpeningsProvider = FutureProvider.autoDispose
    .family<IList<PuzzleOpeningFamily>, PuzzleOpeningSort>((
      Ref ref,
      PuzzleOpeningSort sort,
    ) {
      return const IListConst([]);
    });

final stormProvider = FutureProvider.autoDispose<PuzzleStormResponse>((Ref ref) async {
  final service = await ref.watch(puzzleServiceProvider.future);
  final puzzles = <LitePuzzle>[];
  for (var i = 0; i < 50; i++) {
    final ctx = await service.nextPuzzle(userId: null);
    puzzles.add(LitePuzzle(
      id: ctx!.puzzle.puzzle.id,
      fen: ctx.puzzle.preview.initialFen,
      solution: ctx.puzzle.puzzle.solution,
      rating: ctx.puzzle.puzzle.rating,
    ));
  }
  return PuzzleStormResponse(
    puzzles: puzzles.toIList(),
    key: 'local_storm',
    highscore: const PuzzleStormHighScore(allTime: 0, day: 0, month: 0, week: 0),
    timestamp: DateTime.now(),
  );
});
