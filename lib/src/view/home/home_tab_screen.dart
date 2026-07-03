import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/binding.dart';
import 'package:lichess_mobile/src/model/account/account_repository.dart';
import 'package:lichess_mobile/src/model/account/home_preferences.dart';
import 'package:lichess_mobile/src/model/account/home_widgets.dart';
import 'package:lichess_mobile/src/model/account/ongoing_game.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
import 'package:lichess_mobile/src/model/blog/blog.dart';
import 'package:lichess_mobile/src/model/blog/blog_repository.dart';
import 'package:lichess_mobile/src/model/challenge/challenges.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/correspondence/correspondence_game_storage.dart';
import 'package:lichess_mobile/src/model/correspondence/offline_correspondence_game.dart';
import 'package:lichess_mobile/src/model/engine/evaluation_preferences.dart';
import 'package:lichess_mobile/src/model/engine/nnue_service.dart';
import 'package:lichess_mobile/src/model/game/game_history.dart';
import 'package:lichess_mobile/src/model/message/message_repository.dart';
import 'package:lichess_mobile/src/model/relation/following_user.dart';
import 'package:lichess_mobile/src/model/tournament/tournament.dart';
import 'package:lichess_mobile/src/model/tournament/tournament_providers.dart';
import 'package:lichess_mobile/src/model/user/user.dart';
import 'package:lichess_mobile/src/network/connectivity.dart';
import 'package:lichess_mobile/src/styles/lichess_icons.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/tab_scaffold.dart';
import 'package:lichess_mobile/src/utils/focus_detector.dart';
import 'package:lichess_mobile/src/utils/image.dart';
import 'package:lichess_mobile/src/utils/l10n.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/utils/screen.dart';
import 'package:lichess_mobile/src/view/account/account_menu.dart';
import 'package:lichess_mobile/src/view/account/profile_screen.dart';
import 'package:lichess_mobile/src/view/correspondence/offline_correspondence_game_screen.dart';
import 'package:lichess_mobile/src/view/game/game_screen.dart';
import 'package:lichess_mobile/src/view/game/game_screen_providers.dart';
import 'package:lichess_mobile/src/view/game/offline_correspondence_games_screen.dart';
import 'package:lichess_mobile/src/view/home/blog_carousel.dart';
import 'package:lichess_mobile/src/view/home/following_carousel.dart';
import 'package:lichess_mobile/src/view/home/games_carousel.dart';
import 'package:lichess_mobile/src/view/message/conversation_screen.dart';
import 'package:lichess_mobile/src/view/play/ongoing_games_screen.dart';
import 'package:lichess_mobile/src/view/play/play_bottom_sheet.dart';
import 'package:lichess_mobile/src/view/play/play_menu.dart';
import 'package:lichess_mobile/src/view/play/quick_game_matrix.dart';
import 'package:lichess_mobile/src/view/settings/engine_settings_screen.dart';
import 'package:lichess_mobile/src/view/tournament/tournament_list_screen.dart';
import 'package:lichess_mobile/src/view/user/challenge_requests_screen.dart';
import 'package:lichess_mobile/src/view/user/recent_games.dart';
import 'package:lichess_mobile/src/widgets/buttons.dart';
import 'package:lichess_mobile/src/widgets/feedback.dart';
import 'package:lichess_mobile/src/widgets/haptic_refresh_indicator.dart';
import 'package:lichess_mobile/src/widgets/list.dart';
import 'package:lichess_mobile/src/widgets/misc.dart';
import 'package:lichess_mobile/src/widgets/platform.dart';
import 'package:lichess_mobile/src/widgets/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Number of cold app starts before hiding the home customization tip.
const kColdAppStartsHideCustomizationTipThreshold = 5;

class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key, this.editModeEnabled = false});

  final bool editModeEnabled;

  static Route<dynamic> buildRoute({bool editModeEnabled = false}) {
    return buildScreenRoute(
      screen: HomeTabScreen(editModeEnabled: editModeEnabled),
    );
  }

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeScreenState();
}

class _IsEditingHome extends InheritedWidget {
  const _IsEditingHome({required super.child, required this.isEditingWidgets});

  final bool isEditingWidgets;

  @override
  bool updateShouldNotify(_IsEditingHome oldWidget) {
    return isEditingWidgets != oldWidget.isEditingWidgets;
  }

  static _IsEditingHome? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_IsEditingHome>();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<bool>('isEditingWidgets', isEditingWidgets),
    );
  }
}

const String kWelcomeMessageShownKey = 'app_welcome_message_shown';
const String kHideHomeWidgetCustomizationTip =
    'app_hide_home_widget_customization_tip';

class _HomeScreenState extends ConsumerState<HomeTabScreen> {
  ImageColorWorker? _worker;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  DateTime? _focusLostAt;

  bool wasOnline = true;
  bool hasRefreshed = false;

  @override
  void initState() {
    super.initState();
    _loadImageWorker();
  }

  Future<void> _loadImageWorker() async {
    final worker = await ref.read(imageWorkerFactoryProvider).spawn();
    if (mounted) {
      setState(() {
        _worker = worker;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectivityChangesProvider, (_, connectivity) {
      // Refresh the data only once if it was offline and is now online
      if (!connectivity.isRefreshing && connectivity.hasValue) {
        final isNowOnline = connectivity.value!.isOnline;

        if (!hasRefreshed && !wasOnline && isNowOnline) {
          hasRefreshed = true;
          _refreshData(isOnline: isNowOnline);
        }

        wasOnline = isNowOnline;
      }
    });

    final isOnlineAsync = ref.watch(onlineStatusProvider);

    return isOnlineAsync.when(
      skipLoadingOnReload: true,
      data: (isOnline) {
        final authUser = ref.watch(authControllerProvider);
        final unreadLichessMessage =
            ref.watch(unreadMessagesProvider).value?.lichess == true;
        final ongoingGames = ref.watch(ongoingGamesProvider);
        final offlineCorresGames = ref.watch(
          offlineOngoingCorrespondenceGamesProvider,
        );
        final recentGames = ref.watch(myRecentGamesProvider);
        final nbOfGames = ref.watch(userNumberOfGamesProvider(null)).value ?? 0;
        final isTablet = isTabletOrLarger(context);
        final featuredTournaments = isOnline
            ? ref.watch(featuredTournamentsProvider)
            : const AsyncValue.data(IListConst<LightTournament>([]));
        final blogPosts = isOnline
            ? ref.watch(blogCarouselProvider)
            : const AsyncValue.data(IListConst<BlogPost>([]));
        final followingAsync = authUser != null && isOnline
            ? ref.watch(followingCarouselProvider)
            : const AsyncValue.data(IListConst<FollowingUser>([]));

        final isKidMode = ref.watch(kidModeProvider).value ?? false;

        // Show the welcome screen if not logged in and there are no recent games and no stored games
        // (i.e. first installation, or the user has never played a game)
        final shouldShowWelcomeScreen =
            authUser == null &&
            recentGames.maybeWhen(
              data: (data) => data.isEmpty,
              orElse: () => false,
            );

        List<Widget> widgets;

        if (shouldShowWelcomeScreen) {
          final welcomeWidgets = [
                  shouldShow: false,
                  child: _BlogCarouselWidget(blogPosts, _worker!),
                ),
            ],
          ];
        } else if (isTablet) {
          widgets = [
                          shouldShow: false,
                          child: _BlogCarouselWidget(blogPosts, _worker!),
                        ),
                      RecentGamesWidget(
                        recentGames: recentGames,
                        nbOfGames: nbOfGames,
                        user: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        } else {
          final hasOngoingGames =
              (isOnline &&
                  ongoingGames.maybeWhen(
                    data: (data) => data.isNotEmpty,
                    orElse: () => false,
                  )) ||
              (!isOnline &&
                  offlineCorresGames.maybeWhen(
                    data: (data) => data.isNotEmpty,
                    orElse: () => false,
                  ));
          widgets = [
                shouldShow: false,
                child: _BlogCarouselWidget(blogPosts, _worker!),
              ),
