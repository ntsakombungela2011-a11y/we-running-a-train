import 'dart:math';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_angle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_controller.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_providers.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/widgets/board.dart';
import 'package:lichess_mobile/src/widgets/platform.dart';

class PuzzleScreen extends ConsumerWidget {
  const PuzzleScreen({required this.angle, this.puzzle, super.key});
  final PuzzleAngle angle;
  final Puzzle? puzzle;

  static Route<dynamic> buildRoute({
    required PuzzleAngle angle,
    Puzzle? puzzle,
  }) {
    return buildScreenRoute(
      screen: PuzzleScreen(angle: angle, puzzle: puzzle),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleAsync = ref.watch(nextPuzzleProvider(angle));

    return puzzleAsync.when(
      data: (ctx) {
        if (ctx == null) return const Center(child: Text('No puzzle found'));
        final puzzleState = ref.watch(puzzleControllerProvider(ctx));
        final boardPrefs = ref.watch(boardPreferencesProvider);

        return PlatformScaffold(
          appBar: PlatformAppBar(title: Text(context.l10n.puzzles)),
          body: Center(
            child: BoardWidget(
              size: min(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height - 200,
              ),
              orientation: puzzleState.pov,
              settings: ChessboardSettings(
                pieceAssets: boardPrefs.pieceSet.assets,
                colorScheme: boardPrefs.boardTheme.colors,
              ),
              controller: ChessboardController(
                game: buildGameData(
                  fen: puzzleState.node.position.fen,
                  variant: Variant.standard,
                  position: puzzleState.node.position,
                  playerSide: PlayerSide.none,
                  castlingMethod: boardPrefs.castlingMethod,
                  boardHighlights: boardPrefs.boardHighlights,
                ),
              ),
              onMove: (move, {viaDragAndDrop}) {
                ref
                    .read(puzzleControllerProvider(ctx).notifier)
                    .onUserMove(move);
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}
