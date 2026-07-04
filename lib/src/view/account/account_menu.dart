import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/account/account_providers.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/widgets/platform.dart';
import 'package:lichess_mobile/src/widgets/misc.dart';
import 'package:lichess_mobile/src/styles/lichess_icons.dart';
import 'package:lichess_mobile/src/model/common/preloaded_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/network/http.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:lichess_mobile/src/widgets/list_section.dart';

class AccountMenuScreen extends ConsumerStatefulWidget {
  const AccountMenuScreen({super.key});

  static Route<void> buildRoute(BuildContext context) {
    return buildScreenRoute(screen: const AccountMenuScreen());
  }

  @override
  ConsumerState<AccountMenuScreen> createState() => _AccountMenuScreenState();
}

class _AccountMenuScreenState extends ConsumerState<AccountMenuScreen>
    with WidgetsBindingObserver {
  bool _pendingKidModeRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pendingKidModeRefresh) {
      _pendingKidModeRefresh = false;
      ref.invalidate(accountProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(onlineStatusProvider).value ?? false;
    final signInState = ref.watch(signInMutation);

    ref.listen(signInMutation, (prev, next) {});

    final account = ref.watch(accountProvider);
    final authUser = ref.watch(authControllerProvider);
    final user = authUser?.user;
    final kidMode = account.value?.kid ?? false;
    final unreadMessages = ref.watch(unreadMessagesProvider).value?.unread ?? 0;

    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(context.l10n.mobileAccount)),
      body: ListView(
        children: [
          ListSection(
            children: [
              ListTile(
                leading: switch (account) {
                  AsyncData(:final value) =>
                    value == null
                        ? const Icon(Icons.account_circle_outlined)
                        : CircleAvatar(radius: 16, child: Text(value.initials)),
                  _ => const Icon(Icons.account_circle_outlined),
                },
                title: Text(user?.name ?? context.l10n.signIn),
                onTap: user == null
                    ? () {
                        if (isOnline) {
                          signInMutation.run(ref, (tsx) async {
                            await tsx
                                .get(authControllerProvider.notifier)
                                .signIn();
                          });
                        }
                      }
                    : null,
              ),
              if (user != null)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(context.l10n.logOut),
                  onTap: () => _showSignOutConfirmDialog(context, ref),
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
          if (user != null && account.hasValue && !kidMode)
            ListTile(
              leading: Badge.count(
                count: unreadMessages,
                isLabelVisible: unreadMessages > 0,
                child: const Icon(Icons.mail_outline),
              ),
              title: Text(context.l10n.emails),
              onTap: () {
                // Navigate to emails
              },
            ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Route<dynamic> route) {
    Navigator.of(context).push(route);
  }

  void _showSignOutConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.logOut),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await signOutMutation.run(ref, (tsx) async {
                  await tsx.get(authControllerProvider.notifier).signOut();
                });
              },
              child: Text(context.l10n.mobileOkButton),
            ),
          ],
        );
      },
    );
  }
}

class AccountMenuButton extends ConsumerStatefulWidget {
  const AccountMenuButton({super.key});

  @override
  ConsumerState<AccountMenuButton> createState() => _AccountMenuButtonState();
}

class _AccountMenuButtonState extends ConsumerState<AccountMenuButton> {
  @override
  Widget build(BuildContext context) {
    final unreadMessages = ref.watch(unreadMessagesProvider).value?.unread ?? 0;

    return IconButton(
      icon: Badge.count(
        count: unreadMessages,
        isLabelVisible: unreadMessages > 0,
        child: const Icon(Icons.account_circle_outlined),
      ),
      onPressed: () {
        Navigator.of(context).push(AccountMenuScreen.buildRoute(context));
      },
    );
  }
}

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static Route<void> buildRoute() {
    return buildScreenRoute(screen: const AboutScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref
        .read(preloadedDataProvider)
        .requireValue
        .packageInfo;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.about)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Boipelo Chess v${packageInfo.version}'),
          ),
        ],
      ),
    );
  }
}
