import 'dart:async';
import 'dart:math';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/common/perf.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_theme.dart';
import 'package:lichess_mobile/src/model/engine/engine.dart';
import 'package:lichess_mobile/src/model/engine/evaluation_service.dart';
import 'package:lichess_mobile/src/model/common/uci.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';

class PuzzleGenerator {
  final EvaluationService _evaluationService;
  final Random _random = Random();

  PuzzleGenerator(this._evaluationService);

  Future<Puzzle> generate({
    PuzzleThemeKey theme = PuzzleThemeKey.mix,
    int targetRating = 1500,
  }) async {
    final seed = _getSeedForTheme(theme);
    return seed;
  }

  Puzzle _getSeedForTheme(PuzzleThemeKey theme) {
    switch (theme) {
      case PuzzleThemeKey.fork:
        return _seedFork();
      case PuzzleThemeKey.pin:
        return _seedPin();
      case PuzzleThemeKey.skewer:
        return _seedSkewer();
      case PuzzleThemeKey.discoveredAttack:
        return _seedDiscovered();
      case PuzzleThemeKey.backRankMate:
        return _seedBackRank();
      case PuzzleThemeKey.smotheredMate:
        return _seedSmothered();
      case PuzzleThemeKey.mateIn2:
        return _seedMateIn2();
      case PuzzleThemeKey.mateIn3:
        return _seedMateIn3();
      default:
        const themes = [
          PuzzleThemeKey.fork,
          PuzzleThemeKey.pin,
          PuzzleThemeKey.skewer,
          PuzzleThemeKey.discoveredAttack,
          PuzzleThemeKey.backRankMate,
          PuzzleThemeKey.smotheredMate,
          PuzzleThemeKey.mateIn2,
          PuzzleThemeKey.mateIn3,
        ];
        return _getSeedForTheme(themes[_random.nextInt(themes.length)]);
    }
  }

  Puzzle _seedFork() {
    return _createPuzzle(
      id: 'fork_${_random.nextInt(1000)}',
      fen:
          'r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1',
      solution: ['e5g6'],
      themes: ['fork'],
    );
  }

  Puzzle _seedPin() {
    return _createPuzzle(
      id: 'pin_${_random.nextInt(1000)}',
      fen: '4k3/4r3/8/4R3/8/8/4K3/8 w - - 0 1',
      solution: ['e2d3'],
      themes: ['pin'],
    );
  }

  Puzzle _seedSkewer() {
    return _createPuzzle(
      id: 'skewer_${_random.nextInt(1000)}',
      fen: '4k3/8/8/8/Q7/8/8/4K2r w - - 0 1',
      solution: ['a4h4'],
      themes: ['skewer'],
    );
  }

  Puzzle _seedDiscovered() {
    return _createPuzzle(
      id: 'discovered_${_random.nextInt(1000)}',
      fen: 'rn1qkbnr/ppp1pppp/8/3p1b2/3P4/2N5/PPP1PPPP/R1BQKBNR w KQkq - 2 3',
      solution: ['e2e4'],
      themes: ['discoveredAttack'],
    );
  }

  Puzzle _seedBackRank() {
    return _createPuzzle(
      id: 'backrank_${_random.nextInt(1000)}',
      fen: '6k1/5ppp/8/8/8/8/5PPP/3R2K1 w - - 0 1',
      solution: ['d1d8'],
      themes: ['backRankMate'],
    );
  }

  Puzzle _seedSmothered() {
    return _createPuzzle(
      id: 'smothered_${_random.nextInt(1000)}',
      fen: '6rk/5Npp/8/8/8/8/8/7K b - - 0 1',
      solution: ['f7h6'],
      themes: ['smotheredMate'],
    );
  }

  Puzzle _seedMateIn2() {
    return _createPuzzle(
      id: 'mate2_${_random.nextInt(1000)}',
      fen:
          'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4',
      solution: ['h5f7'],
      themes: ['mateIn2'],
    );
  }

  Puzzle _seedMateIn3() {
    return _createPuzzle(
      id: 'mate3_${_random.nextInt(1000)}',
      fen: 'r5rk/5ppp/5P2/6P1/8/8/8/6RK w - - 0 1',
      solution: ['g5g6', 'f7g6', 'f6f7'],
      themes: ['mateIn3'],
    );
  }

  Puzzle _createPuzzle({
    required String id,
    required String fen,
    required List<String> solution,
    required List<String> themes,
  }) {
    return Puzzle(
      puzzle: PuzzleData(
        id: PuzzleId(id),
        rating: 1500,
        plays: 0,
        initialPly: 0,
        solution: IList(solution.map((s) => s as UCIMove)),
        themes: ISet(themes),
      ),
      game: PuzzleGame(
        id: const GameId('localgam'),
        perf: Perf.bullet,
        rated: false,
        white: const PuzzleGamePlayer(side: Side.white, name: 'Local'),
        black: const PuzzleGamePlayer(side: Side.black, name: 'Local'),
        pgn: '',
      ),
    );
  }
}
