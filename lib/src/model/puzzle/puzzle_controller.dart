import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/common/node.dart';
import 'package:lichess_mobile/src/model/common/service/sound_service.dart';
import 'package:lichess_mobile/src/model/common/uci.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_service.dart';

class PuzzleState {
  final Puzzle puzzle;
  final PuzzleMode mode;
  final ViewNode root;
  final ViewNode node;
  final Side pov;

  const PuzzleState({
    required this.puzzle,
    required this.mode,
    required this.root,
    required this.node,
    required this.pov,
  });

  PuzzleState copyWith({
    Puzzle? puzzle,
    PuzzleMode? mode,
    ViewNode? root,
    ViewNode? node,
    Side? pov,
  }) {
    return PuzzleState(
      puzzle: puzzle ?? this.puzzle,
      mode: mode ?? this.mode,
      root: root ?? this.root,
      node: node ?? this.node,
      pov: pov ?? this.pov,
    );
  }
}

enum PuzzleMode { load, play, view }

final puzzleControllerProvider = NotifierProvider.autoDispose
    .family<PuzzleController, PuzzleState, PuzzleContext>(
      PuzzleController.new,
      name: 'PuzzleControllerProvider',
    );

class PuzzleController extends Notifier<PuzzleState> {
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
      node: root,
      pov: context.puzzle.puzzle.sideToMove,
    );
  }

  void onUserMove(Move move) {
    final res = state.node.position.makeSan(move);
    final sanMove = SanMove(res.$2, move);
    if (state.puzzle.testSolution([sanMove])) {
      ref.read(soundServiceProvider).play(Sound.move);
    } else {
      ref.read(soundServiceProvider).play(Sound.error);
    }
  }

  void onLoadPuzzle(PuzzleContext context) {
    state = _loadNewContext(context);
  }
}
