import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/account/account_repository.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/widgets/platform.dart';
import 'package:lichess_mobile/src/widgets/list.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';

class AccountMenuScreen extends ConsumerWidget {
  const AccountMenuScreen({super.key});

  static Route<void> buildRoute(BuildContext context) {
    return buildScreenRoute(screen: const AccountMenuScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider).value;
    final authUser = ref.watch(authControllerProvider);
    final user = authUser?.user;

    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(context.l10n.mobileAccount)),
      body: ListView(
        children: [
          ListSection(
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(user?.name ?? context.l10n.signIn),
              ),
            ],
          ),
          ListSection(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(context.l10n.about),
                onTap: () {
                  _navigate(context, AboutScreen.buildRoute());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Route<dynamic> route) {
    Navigator.of(context).push(route);
  }
}

class AccountMenuButton extends ConsumerWidget {
  const AccountMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.account_circle_outlined),
      onPressed: () {
        Navigator.of(context).push(AccountMenuScreen.buildRoute(context));
      },
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  static Route<void> buildRoute() =>
      buildScreenRoute(screen: const AboutScreen());
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text('About')));
}
