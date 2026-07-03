import 'dart:async';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/common/node.dart';
import 'package:lichess_mobile/src/model/common/service/move_feedback.dart';
import 'package:lichess_mobile/src/model/common/service/sound_service.dart';
import 'package:lichess_mobile/src/model/common/uci.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_service.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_session.dart';

part 'puzzle_controller.freezed.dart';

final puzzleControllerProvider = NotifierProvider.autoDispose
    .family<PuzzleController, PuzzleState, PuzzleContext>(
      PuzzleController.new,
      name: 'PuzzleControllerProvider',
    );

class PuzzleController extends Notifier<PuzzleState> {
  PuzzleController(this.initialContext);
  final PuzzleContext initialContext;

  late Branch _gameTree;
  Timer? _firstMoveTimer;
  Timer? _viewSolutionTimer;

  @override
  PuzzleState build() {
    ref.onDispose(() {
      _firstMoveTimer?.cancel();
      _viewSolutionTimer?.cancel();
    });
    return _loadNewContext(initialContext);
  }

  PuzzleState _loadNewContext(PuzzleContext context) {
    // Reconstruct the game tree from FEN and solution
    final root = Root.fromSetup(Setup.parseFen(context.puzzle.preview.initialFen));
    _gameTree = root as Branch; // Simplified for this implementation

    // In a real implementation, we'd apply the solution moves to the tree.
    // ponytail: simplified tree handling for now.

    return PuzzleState(
      puzzle: context.puzzle,
      mode: PuzzleMode.play,
      root: root.view,
      initialPosition: root.position,
      initialPath: UciPath.empty,
      currentPath: UciPath.empty,
      node: root.view,
      pov: context.puzzle.puzzle.sideToMove,
    );
  }

  void onUserMove(Move move) {
    // Verify move against solution
    if (initialContext.puzzle.testSolution([state.node.position.makeSan(move).])) {
       // Correct move logic
       ref.read(soundServiceProvider).play(Sound.move);
    } else {
       // Wrong move
       ref.read(soundServiceProvider).play(Sound.error);
    }
  }

  void skipMove() {}
  void userPrevious() {}
  void userNext() {}
  String makePgn() => '';
}

@freezed
sealed class PuzzleState with _$PuzzleState {
  const factory PuzzleState({
    required Puzzle puzzle,
    required PuzzleMode mode,
    required NodeView root,
    required Position initialPosition,
    required UciPath initialPath,
    required UciPath currentPath,
    required NodeView node,
    required Side pov,
    PuzzleGlicko? glicko,
    PuzzleResult? result,
    PuzzleFeedback? feedback,
  }) = _PuzzleState;
}

enum PuzzleMode { load, play, view }
enum PuzzleResult { win, lose }
enum PuzzleFeedback { none, good, bad }
