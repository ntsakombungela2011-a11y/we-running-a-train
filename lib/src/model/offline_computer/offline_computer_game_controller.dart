import 'dart:async';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/common/speed.dart';
import 'package:lichess_mobile/src/model/common/perf.dart';
import 'package:lichess_mobile/src/model/game/game_status.dart';
import 'package:lichess_mobile/src/model/game/player.dart';
import 'package:lichess_mobile/src/model/game/offline_computer_game.dart';
import 'package:lichess_mobile/src/model/game/game.dart';

class OfflineComputerGameState {
  final OfflineComputerGame game;
  final int stepCursor;

  const OfflineComputerGameState({required this.game, this.stepCursor = 0});

  factory OfflineComputerGameState.initial({
    required StockfishLevel stockfishLevel,
    required Side playerSide,
  }) {
    final position = Variant.standard.initialPosition;
    return OfflineComputerGameState(
      game: OfflineComputerGame(
        id: StringId('local'),
        steps: [GameStep(position: position)].lock,
        status: GameStatus.started,
        meta: GameMeta(
          createdAt: DateTime.now(),
          rated: false,
          variant: Variant.standard,
          speed: Speed.classical,
          perf: Perf.bullet,
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
  }) {
    return OfflineComputerGameState(
      game: game ?? this.game,
      stepCursor: stepCursor ?? this.stepCursor,
    );
  }
}

final offlineComputerGameControllerProvider =
    NotifierProvider.autoDispose<
      OfflineComputerGameController,
      OfflineComputerGameState
    >(
      OfflineComputerGameController.new,
      name: 'OfflineComputerGameControllerProvider',
    );

class OfflineComputerGameController extends Notifier<OfflineComputerGameState> {
  @override
  OfflineComputerGameState build() {
    return OfflineComputerGameState.initial(
      stockfishLevel: StockfishLevel.level1,
      playerSide: Side.white,
    );
  }

  void makeMove(Move move) {
    if (state.turn != state.game.playerSide || !state.game.playable) return;
    final res = state.currentPosition.makeSan(move);
    final sanMove = SanMove(res.$2, move);
    final newStep = GameStep(position: res.$1, sanMove: sanMove);
    state = state.copyWith(
      game: state.game.copyWith(steps: state.game.steps.add(newStep)),
      stepCursor: state.stepCursor + 1,
    );
  }
}
