import 'dart:math';

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/offline_computer/offline_computer_game_controller.dart';
import 'package:lichess_mobile/src/model/offline_computer/offline_computer_game_preferences.dart';
import 'package:lichess_mobile/src/model/offline_computer/practice_comment.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/utils/gestures_exclusion.dart';
import 'package:lichess_mobile/src/utils/immersive_mode.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/view/analysis/analysis_screen.dart';
import 'package:lichess_mobile/src/view/offline_computer/computer_analysis.dart';
import 'package:lichess_mobile/src/widgets/board.dart';
import 'package:lichess_mobile/src/widgets/bottom_bar.dart';
import 'package:lichess_mobile/src/widgets/list.dart';
import 'package:lichess_mobile/src/widgets/platform.dart';
import 'package:lichess_mobile/src/widgets/settings.dart';

extension _MoveVerdictDisplay on MoveVerdict {
  IconData get icon => switch (this) {
    MoveVerdict.brilliant => Icons.auto_awesome,
    MoveVerdict.greatMove => Icons.stars,
    MoveVerdict.bestMove => Icons.check_circle,
    MoveVerdict.bookMove => Icons.book,
    MoveVerdict.blunder => Icons.cancel,
    MoveVerdict.mistake => Icons.error,
    MoveVerdict.inaccuracy => Icons.help,
    MoveVerdict.notBest => Icons.info,
    MoveVerdict.goodMove => Icons.check,
  };

  Color get color => switch (this) {
    MoveVerdict.brilliant => Colors.cyan,
    MoveVerdict.greatMove => Colors.blue,
    MoveVerdict.bestMove => Colors.green,
    MoveVerdict.bookMove => Colors.brown,
    MoveVerdict.blunder => Colors.red,
    MoveVerdict.mistake => Colors.orange,
    MoveVerdict.inaccuracy => Colors.yellow,
    MoveVerdict.notBest => Colors.grey,
    MoveVerdict.goodMove => Colors.lightGreen,
  };
}

class OfflineComputerGameScreen extends ConsumerStatefulWidget {
  const OfflineComputerGameScreen({
    this.initialVariant = Variant.standard,
    this.initialFen,
    super.key,
  });

  final Variant initialVariant;
  final String? initialFen;

  static Route<void> buildRoute({
    Variant initialVariant = Variant.standard,
    String? initialFen,
  }) {
    return buildScreenRoute(
      screen: OfflineComputerGameScreen(
        initialVariant: initialVariant,
        initialFen: initialFen,
      ),
    );
  }

  @override
  ConsumerState<OfflineComputerGameScreen> createState() =>
      _OfflineComputerGameScreenState();
}

class _OfflineComputerGameScreenState
    extends ConsumerState<OfflineComputerGameScreen> {
  final _boardKey = GlobalKey(debugLabel: 'boardOnOfflineComputerGameScreen');

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(offlineComputerGameControllerProvider);
    final boardPrefs = ref.watch(boardPreferencesProvider);

    final content = PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(context.l10n.playAgainstComputer),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: BoardWidget(
                boardKey: _boardKey,
                size: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - 200),
                onMove: (move, {viaDragAndDrop}) {
                  ref.read(offlineComputerGameControllerProvider.notifier).makeMove(move);
                },
                orientation: gameState.game.playerSide,
                settings: BoardSettings(
                  pieceSet: boardPrefs.pieceSet,
                  theme: boardPrefs.boardTheme,
                ),
                fen: gameState.currentPosition.fen,
              ),
            ),
          ),
          _BottomBar(gameState: gameState),
        ],
      ),
    );

    return content;
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.gameState});
  final OfflineComputerGameState gameState;

  @override
  Widget build(BuildContext context) {
    return BottomBar(
      children: [
        BottomBarButton(
          icon: Icons.refresh,
          label: 'New Game',
          onTap: () {
             // Show new game dialog
          },
        ),
      ],
    );
  }
}
