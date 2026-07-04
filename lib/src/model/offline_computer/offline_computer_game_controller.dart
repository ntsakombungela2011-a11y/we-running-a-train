import 'dart:async';
import 'dart:math';

import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/common/eval.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/common/node.dart';
import 'package:lichess_mobile/src/model/common/service/move_feedback.dart';
import 'package:lichess_mobile/src/model/common/service/sound_service.dart';
import 'package:lichess_mobile/src/model/common/uci.dart';
import 'package:lichess_mobile/src/model/engine/evaluation_service.dart';
import 'package:lichess_mobile/src/model/game/game.dart';
import 'package:lichess_mobile/src/model/game/game_status.dart';
import 'package:lichess_mobile/src/model/game/player.dart';
import 'package:lichess_mobile/src/model/game/offline_computer_game.dart';
import 'package:lichess_mobile/src/model/offline_computer/practice_comment.dart';
import 'package:logging/logging.dart';

final _logger = Logger('OfflineComputerGameController');
final _random = Random();

const _kComputerStockfishFlavor = StockfishFlavor.nnue;
const _kHintsMaxSearchTime = Duration(milliseconds: 1000);
const _kHintsEvalMinDepth = 15;
const kGoodMoveThreshold = 0.1;

class OfflineComputerGameState {
  final OfflineComputerGame game;
  final int stepCursor;
  final bool isEngineThinking;
  final bool isLoadingHint;

  const OfflineComputerGameState({
    required this.game,
    this.stepCursor = 0,
    this.isEngineThinking = false,
    this.isLoadingHint = false,
  });

  factory OfflineComputerGameState.initial({
    required StockfishLevel stockfishLevel,
    required Side playerSide,
    Variant variant = Variant.standard,
    String? initialFen,
  }) {
    final Position position;
    if (initialFen != null) {
      position = Position.setupPosition(variant.rule, Setup.parseFen(initialFen));
    } else {
      position = variant.initialPosition;
    }

    return OfflineComputerGameState(
      game: OfflineComputerGame(
        id: StringId('local'),
        steps: [GameStep(position: position)].lock,
        status: GameStatus.started,
        initialFen: initialFen,
        meta: GameMeta(
          createdAt: DateTime.now(),
          rated: false,
          variant: variant,
          speed: Speed.classical,
          perf: Perf.fromVariantAndSpeed(variant, Speed.classical),
        ),
        playerSide: playerSide,
        stockfishLevel: stockfishLevel,
        humanPlayer: const Player(onGame: true),
        enginePlayer: stockfishPlayer(),
      ),
    );
  }

  Position get currentPosition => game.steps[stepCursor].position;
  Side get turn => currentPosition.turn;

  OfflineComputerGameState copyWith({
    OfflineComputerGame? game,
    int? stepCursor,
    bool? isEngineThinking,
    bool? isLoadingHint,
  }) {
    return OfflineComputerGameState(
      game: game ?? this.game,
      stepCursor: stepCursor ?? this.stepCursor,
      isEngineThinking: isEngineThinking ?? this.isEngineThinking,
      isLoadingHint: isLoadingHint ?? this.isLoadingHint,
    );
  }
}

final offlineComputerGameControllerProvider = StateNotifierProvider.autoDispose<
    OfflineComputerGameController, OfflineComputerGameState>((ref) {
  return OfflineComputerGameController(ref);
});

class OfflineComputerGameController
    extends StateNotifier<OfflineComputerGameState> {
  OfflineComputerGameController(this.ref)
      : super(OfflineComputerGameState.initial(
          stockfishLevel: StockfishLevel.level1,
          playerSide: Side.white,
        ));

  final Ref ref;

  Future<void> makeMove(Move move) async {
    if (state.turn != state.game.playerSide || !state.game.playable) return;

    final res = state.currentPosition.makeSan(move);
    final sanMove = SanMove(res.$2, move);

    final newStep = GameStep(
      position: res.$1,
      sanMove: sanMove,
    );

    state = state.copyWith(
      game: state.game.copyWith(
        steps: state.game.steps.add(newStep),
      ),
      stepCursor: state.stepCursor + 1,
    );

    if (state.game.playable) {
      await _playEngineMove();
    }
  }

  Future<void> _playEngineMove() async {
    state = state.copyWith(isEngineThinking: true);
    // engine move logic
    state = state.copyWith(isEngineThinking: false);
  }

  void newGame({
    required StockfishLevel stockfishLevel,
    required Side playerSide,
    Variant variant = Variant.standard,
    String? fen,
  }) {
    state = OfflineComputerGameState.initial(
      stockfishLevel: stockfishLevel,
      playerSide: playerSide,
      variant: variant,
      initialFen: fen,
    );
  }
}
