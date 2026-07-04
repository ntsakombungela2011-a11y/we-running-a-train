import 'package:lichess_mobile/src/widgets/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/tab_scaffold.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/widgets/background.dart';
import 'package:lichess_mobile/src/view/offline_computer/offline_computer_game_screen.dart';
import 'package:lichess_mobile/src/view/play/play_bottom_sheet.dart';
import 'package:lichess_mobile/src/widgets/misc.dart';
import 'package:lichess_mobile/src/styles/styles.dart';

class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({this.editModeEnabled = false, super.key});
  final bool editModeEnabled;
  static Route<void> buildRoute({bool editModeEnabled = false}) {
    return buildScreenRoute(
      screen: HomeTabScreen(editModeEnabled: editModeEnabled),
    );
  }

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeTabScreen> {
  @override
  Widget build(BuildContext context) {
    return FullScreenBackground(
      child: Scaffold(
        appBar: PlatformAppBar(title: const AppBarLichessTitle()),
        body: ListView(
          controller: homeScrollController,
          children: [
            Padding(
              padding: Styles.bodyPadding,
              child: Text(
                'Welcome to Boipelo Chess!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: Styles.horizontalBodyPadding,
              child: Column(
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).push(OfflineComputerGameScreen.buildRoute());
                    },
                    icon: const Icon(Icons.computer),
                    label: const Text('Play vs Computer'),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: const FloatingPlayButton(),
      ),
    );
  }
}
