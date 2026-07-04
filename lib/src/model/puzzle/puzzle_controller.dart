import 'dart:async';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/common/node.dart';
import 'package:lichess_mobile/src/model/common/service/sound_service.dart';
import 'package:lichess_mobile/src/model/common/uci.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_service.dart';

class PuzzleState {
  final Puzzle puzzle;
  final PuzzleMode mode;
  final ViewNode root;
  final Position initialPosition;
  final UciPath initialPath;
  final UciPath currentPath;
  final ViewNode node;
  final Side pov;
  final PuzzleGlicko? glicko;
  final PuzzleResult? result;
  final PuzzleFeedback? feedback;
  final PuzzleContext? nextContext;
  final bool isChangingDifficulty;

  const PuzzleState({
    required this.puzzle,
    required this.mode,
    required this.root,
    required this.initialPosition,
    required this.initialPath,
    required this.currentPath,
    required this.node,
    required this.pov,
    this.glicko,
    this.result,
    this.feedback,
    this.nextContext,
    this.isChangingDifficulty = false,
  });

  Position get currentPosition => node.position;
  Move? get lastMove => node.sanMove?.move;
  Square? get hintSquare => null;
  bool get canGoNext => false;
  bool get canGoBack => false;
  bool get shouldBlinkNextArrow => false;

  PuzzleState copyWith({
    Puzzle? puzzle,
    PuzzleMode? mode,
    ViewNode? root,
    Position? initialPosition,
    UciPath? initialPath,
    UciPath? currentPath,
    ViewNode? node,
    Side? pov,
    PuzzleGlicko? glicko,
    PuzzleResult? result,
    PuzzleFeedback? feedback,
    PuzzleContext? nextContext,
    bool? isChangingDifficulty,
  }) {
    return PuzzleState(
      puzzle: puzzle ?? this.puzzle,
      mode: mode ?? this.mode,
      root: root ?? this.root,
      initialPosition: initialPosition ?? this.initialPosition,
      initialPath: initialPath ?? this.initialPath,
      currentPath: currentPath ?? this.currentPath,
      node: node ?? this.node,
      pov: pov ?? this.pov,
      glicko: glicko ?? this.glicko,
      result: result ?? this.result,
      feedback: feedback ?? this.feedback,
      nextContext: nextContext ?? this.nextContext,
      isChangingDifficulty: isChangingDifficulty ?? this.isChangingDifficulty,
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

class PuzzleController extends AutoDisposeNotifier<PuzzleState> {
  PuzzleController(this.arg);
  final PuzzleContext arg;

  @override
  PuzzleState build() {
    return _loadNewContext(arg);
  }

  PuzzleState _loadNewContext(PuzzleContext context) {
    final preview = PuzzlePreview.fromPuzzle(context.puzzle);
    final setup = Setup.parseFen(preview.initialFen);
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
    final sanMove = SanMove(res.$2, move);
    if (arg.puzzle.testSolution([sanMove])) {
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

  void changeDifficulty(dynamic difficulty) {}
  void skipMove() {}
  void userPrevious() {}
  void userNext() {}
  String makePgn() => '';
}
