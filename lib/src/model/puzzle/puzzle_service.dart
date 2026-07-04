import 'dart:async';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_angle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_theme.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_generator.dart';
import 'package:lichess_mobile/src/model/engine/evaluation_service.dart';

part 'puzzle_service.freezed.dart';

const kPuzzleLocalQueueLength = 50;

@freezed
class PuzzleContext with _$PuzzleContext {
  const factory PuzzleContext({
    required Puzzle puzzle,
    required PuzzleAngle angle,
    required UserId? userId,
    PuzzleGlicko? glicko,
    IList<PuzzleRound>? rounds,
    bool? casual,
    bool? isPuzzleStreak,
    IList<PuzzleId>? replayRemaining,
  }) = _PuzzleContext;
}

final puzzleServiceProvider = FutureProvider<PuzzleService>((Ref ref) async {
  return PuzzleService(
    ref,
    generator: PuzzleGenerator(ref.read(evaluationServiceProvider)),
  );
});

final puzzleServiceFactoryProvider = Provider<PuzzleServiceFactory>((Ref ref) {
  return PuzzleServiceFactory(ref);
});

class PuzzleServiceFactory {
  PuzzleServiceFactory(this._ref);
  final Ref _ref;

  Future<PuzzleService> call({required int queueLength}) async {
    return PuzzleService(
      _ref,
      generator: PuzzleGenerator(_ref.read(evaluationServiceProvider)),
    );
  }
}

class PuzzleService {
  PuzzleService(this._ref, {required this.generator});
  final Ref _ref;
  final PuzzleGenerator generator;

  Future<PuzzleContext?> nextPuzzle({
    required UserId? userId,
    PuzzleAngle angle = const PuzzleTheme(PuzzleThemeKey.mix),
  }) async {
    final themeKey = angle is PuzzleTheme ? angle.themeKey : PuzzleThemeKey.mix;
    final puzzle = await generator.generate(theme: themeKey);
    return PuzzleContext(puzzle: puzzle, angle: angle, userId: userId);
  }

  Future<PuzzleContext?> solve({
    required UserId? userId,
    required PuzzleSolution solution,
    required Puzzle puzzle,
    PuzzleAngle angle = const PuzzleTheme(PuzzleThemeKey.mix),
  }) async {
    return nextPuzzle(userId: userId, angle: angle);
  }

  Future<PuzzleContext?> resetBatch({
    required UserId? userId,
    PuzzleAngle angle = const PuzzleTheme(PuzzleThemeKey.mix),
  }) async {
    return nextPuzzle(userId: userId, angle: angle);
  }

  Future<void> deleteBatch({
    required UserId? userId,
    required PuzzleAngle angle,
  }) async {}
}
