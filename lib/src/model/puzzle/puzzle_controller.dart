import 'dart:async';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/common/node.dart';
import 'package:lichess_mobile/src/model/common/service/sound_service.dart';
import 'package:lichess_mobile/src/model/common/uci.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_service.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_session.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_difficulty.dart';
import 'package:lichess_mobile/src/view/analysis/analysis_screen.dart';

part 'puzzle_controller.freezed.dart';

@freezed
class PuzzleState with _$PuzzleState {
  const PuzzleState._();
  const factory PuzzleState({
    required Puzzle puzzle,
    required PuzzleMode mode,
    required ViewNode root,
    required Position initialPosition,
    required UciPath initialPath,
    required UciPath currentPath,
    required ViewNode node,
    required Side pov,
    PuzzleGlicko? glicko,
    PuzzleResult? result,
    PuzzleFeedback? feedback,
    PuzzleContext? nextContext,
    @Default(false) bool isChangingDifficulty,
  }) = _PuzzleState;

  Position get currentPosition => node.position;
  Move? get lastMove => node.sanMove?.move;
  Square? get hintSquare => null;
  bool get canGoNext => false;
  bool get canGoBack => false;
  bool get shouldBlinkNextArrow => false;

  AnalysisOptions makeAnalysisOptions({required int initialMoveCursor}) {
    return AnalysisOptions.pgn(
      id: puzzle.puzzle.id,
      orientation: pov,
      pgn: '',
      isComputerAnalysisAllowed: true,
      variant: Variant.standard,
      initialMoveCursor: initialMoveCursor,
    );
  }
}

enum PuzzleMode { load, play, view }
enum PuzzleResult { win, lose }
enum PuzzleFeedback { none, good, bad }

final puzzleControllerProvider = NotifierProvider.autoDispose
    .family<PuzzleController, PuzzleState, PuzzleContext>(
  PuzzleController.new,
  name: 'PuzzleControllerProvider',
);

class PuzzleController extends Notifier<PuzzleState> {
  PuzzleController(this.initialContext);
  final PuzzleContext initialContext;

  @override
  PuzzleState build() {
    return _loadNewContext(initialContext);
  }

  PuzzleState _loadNewContext(PuzzleContext context) {
    final setup = Setup.parseFen(context.puzzle.preview.initialFen);
    final position = Position.setupPosition(Variant.standard.rule, setup);
    final root = ViewRoot(position: position, children: const IListConst([]));

    return PuzzleState(
      puzzle: context.puzzle,
      mode: PuzzleMode.play,
      root: root,
      initialPosition: position,
      initialPath: UciPath.empty,
      currentPath: UciPath.empty,
      node: root,
      pov: context.puzzle.puzzle.sideToMove,
    );
  }

  void onUserMove(Move move) {
    final res = state.node.position.makeSan(move);
    if (initialContext.puzzle.testSolution([res.$2])) {
       ref.read(soundServiceProvider).play(Sound.move);
    } else {
       ref.read(soundServiceProvider).play(Sound.error);
    }
  }

  void toggleHint() {}
  void viewSolution() {}
  void onLoadPuzzle(PuzzleContext context) {
    state = _loadNewContext(context);
  }
  void changeDifficulty(PuzzleDifficulty difficulty) {}
  void skipMove() {}
  void userPrevious() {}
  void userNext() {}
  String makePgn() => '';
}
