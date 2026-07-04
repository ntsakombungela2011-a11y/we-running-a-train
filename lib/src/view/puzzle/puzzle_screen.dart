import 'dart:math';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_angle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_controller.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_providers.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/widgets/board.dart';
import 'package:lichess_mobile/src/widgets/bottom_bar.dart';
import 'package:lichess_mobile/src/widgets/platform.dart';
import 'package:lichess_mobile/src/view/puzzle/puzzle_feedback_widget.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({
    required this.angle,
    this.puzzle,
    this.puzzleId,
    this.openCasual = false,
    this.replayDays,
    super.key,
  });

  final PuzzleAngle angle;
  final Puzzle? puzzle;
  final PuzzleId? puzzleId;
  final bool openCasual;
  final int? replayDays;

  static Route<dynamic> buildRoute({
    required PuzzleAngle angle,
    PuzzleId? puzzleId,
    Puzzle? puzzle,
    bool openCasual = false,
    int? replayDays,
  }) {
    return buildScreenRoute(
      screen: PuzzleScreen(
        angle: angle,
        puzzleId: puzzleId,
        puzzle: puzzle,
        openCasual: openCasual,
        replayDays: replayDays,
      ),
    );
  }

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  final _boardKey = GlobalKey(debugLabel: 'boardOnPuzzleScreen');

  @override
  Widget build(BuildContext context) {
    final puzzleAsync = widget.puzzle != null
        ? AsyncValue.data(PuzzleContext(puzzle: widget.puzzle!, angle: widget.angle, userId: null))
        : ref.watch(nextPuzzleProvider(widget.angle));

    return puzzleAsync.when(
      data: (ctx) {
        if (ctx == null) return const Center(child: Text('No puzzle found'));
        final puzzleState = ref.watch(puzzleControllerProvider(ctx));
        final boardPrefs = ref.watch(boardPreferencesProvider);

        return PlatformScaffold(
          appBar: PlatformAppBar(
            title: Text(context.l10n.puzzles),
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: BoardWidget(
                    boardKey: _boardKey,
                    size: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - 200),
                    onMove: (move, {viaDragAndDrop}) {
                      ref.read(puzzleControllerProvider(ctx).notifier).onUserMove(move);
                    },
                    orientation: puzzleState.pov,
                    settings: BoardSettings(
                      pieceSet: boardPrefs.pieceSet,
                      theme: boardPrefs.boardTheme,
                    ),
                    fen: puzzleState.root.position.fen,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PuzzleFeedbackWidget(
                  puzzle: ctx.puzzle,
                  state: puzzleState,
                  onStreak: false,
                ),
              ),
              _BottomBar(ctx: ctx),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.ctx});
  final PuzzleContext ctx;

  @override
  Widget build(BuildContext context) {
    return BottomBar(
      children: [
        BottomBarButton(
          icon: Icons.skip_next,
          label: context.l10n.next,
          onTap: () {
            // Load next puzzle
          },
        ),
      ],
    );
  }
}
