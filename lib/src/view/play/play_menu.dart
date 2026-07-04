import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/view/offline_computer/offline_computer_game_screen.dart';
import 'package:lichess_mobile/src/view/over_the_board/over_the_board_screen.dart';
import 'package:lichess_mobile/src/view/play/create_game_widget.dart';
import 'package:lichess_mobile/src/widgets/list.dart';

class PlayMenu extends ConsumerWidget {
  const PlayMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: CreateGameWidget(),
        ),
        _Section(
          children: [
            ListTile(
              onTap: () {
                Navigator.of(
                  context,
                ).popUntil((route) => route is! ModalBottomSheetRoute);
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).push(OfflineComputerGameScreen.buildRoute());
              },
              leading: const Icon(Icons.memory),
              title: Text(context.l10n.playAgainstComputer),
            ),
            ListTile(
              onTap: () {
                Navigator.of(
                  context,
                ).popUntil((route) => route is! ModalBottomSheetRoute);
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).push(OverTheBoardScreen.buildRoute());
              },
              leading: const Icon(Icons.table_restaurant_outlined),
              title: Text(context.l10n.mobileOverTheBoard),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListSection(
      hasLeading: true,
      materialFilledCard: true,
      children: children,
    );
  }
}
