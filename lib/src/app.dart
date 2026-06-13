import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:l10n_esperanto/l10n_esperanto.dart';
import 'package:lichess_mobile/l10n/l10n.dart';
import 'package:lichess_mobile/src/app_links_service.dart';
import 'package:lichess_mobile/src/binding.dart';
import 'package:lichess_mobile/src/constants.dart';
import 'package:lichess_mobile/src/model/account/account_repository.dart';
import 'package:lichess_mobile/src/model/account/account_service.dart';
import 'package:lichess_mobile/src/model/account/ongoing_game.dart';
import 'package:lichess_mobile/src/model/analysis/analysis_preferences.dart';
import 'package:lichess_mobile/src/model/announce/announce_service.dart';
import 'package:lichess_mobile/src/model/broadcast/broadcast_preferences.dart';
import 'package:lichess_mobile/src/model/challenge/challenge_service.dart';
import 'package:lichess_mobile/src/model/common/preloaded_data.dart';
import 'package:lichess_mobile/src/model/correspondence/correspondence_service.dart';
import 'package:lichess_mobile/src/model/log/app_log_service.dart';
import 'package:lichess_mobile/src/model/message/message_service.dart';
import 'package:lichess_mobile/src/model/notifications/notification_service.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/model/settings/general_preferences.dart';
import 'package:lichess_mobile/src/model/settings/theme_preferences.dart';
import 'package:lichess_mobile/src/model/study/study_preferences.dart';
import 'package:lichess_mobile/src/network/connectivity.dart';
import 'package:lichess_mobile/src/network/socket.dart';
import 'package:lichess_mobile/src/quick_actions.dart';
import 'package:lichess_mobile/src/shared_pgn_service.dart';
import 'package:lichess_mobile/src/tab_scaffold.dart';
import 'package:lichess_mobile/src/theme.dart';
import 'package:lichess_mobile/src/utils/screen.dart';

const String _kIosAppGroupId = 'group.org.lichess.mobileV2.LichessWidgets';
const List<String> _kIosBlogWidgetKinds = [
  'OfficialBlogWidget',
  'CommunityBlogWidget',
  'UserBlogFeedWidget',
];

/// Application initialization and main entry point.
class AppInitializationScreen extends ConsumerWidget {
  const AppInitializationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<PreloadedData>>(preloadedDataProvider, (_, state) {
      if (state.hasValue || state.hasError) {
        FlutterNativeSplash.remove();
      }
    });

    switch (ref.watch(preloadedDataProvider)) {
      case AsyncData():
        return const Application();
      case AsyncError(:final error, :final stackTrace):
        debugPrint(
          'SEVERE: [App] could not initialize app; $error\n$stackTrace',
        );
        return const SizedBox.shrink();
      case _:
        // loading screen is handled by the native splash screen
        return const SizedBox.shrink();
    }
  }
}

class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => _ApplicationState();
}

class _ApplicationState extends ConsumerState<Application> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    LichessBinding.instance.setNavigatorKey(_navigatorKey);
    LichessBinding.instance.setRef(ref);

    ref.read(quickActionsProvider).initialize(_navigatorKey);
    ref.read(appLinksServiceProvider).initialize(_navigatorKey);
    ref.read(sharedPgnServiceProvider).initialize(_navigatorKey);
    ref.read(notificationServiceProvider).initialize(_navigatorKey);
    ref.read(announceServiceProvider).initialize();

    if (Platform.isIOS) {
      HomeWidget.setAppGroupId(_kIosAppGroupId);
    }

    ref.listenManual(accountServiceProvider, (previous, next) {
      if (next.value != previous?.value && Platform.isIOS) {
        for (final kind in _kIosBlogWidgetKinds) {
          HomeWidget.updateWidget(iOSWidget: kind);
        }
      }
    });

    ref.listenManual(ongoingGameProvider, (previous, next) {
      if (next.value?.id != previous?.value?.id && Platform.isIOS) {
        HomeWidget.updateWidget(iOSWidget: 'OngoingGameWidget');
      }
    });

    ref.listenManual(connectivityProvider, (previous, next) {
      final socketClient = ref.read(socketClientProvider);
      if (next.value?.isOnline == true &&
          ref.read(appLifecycleProvider).value?.appState ==
              AppLifecycleState.resumed &&
          !socketClient.isActive) {
        socketClient.connect();
      } else if (next.value?.isOnline == false) {
        socketClient.close();
      }
    });

    ref.listenManual(appLifecycleProvider, (previous, current) {
      final socketClient = ref.read(socketClientProvider);
      if (current.value?.isOnline == true &&
          current.value?.appState == AppLifecycleState.resumed &&
          !socketClient.isActive) {
        socketClient.connect();
      } else if (current.value?.isOnline == false) {
        socketClient.close();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themePrefs = ref.watch(themePreferencesProvider);
    final themeNotifier = ref.watch(themePreferencesProvider.notifier);
    final generalPrefs = ref.watch(generalPreferencesProvider);
    final boardPrefs = ref.watch(boardPreferencesProvider);
    final theme = makeAppTheme(
      context,
      generalPrefs,
      boardPrefs,
      themePrefs,
      themeNotifier,
    );

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return AnimatedTheme(
      data: theme,
      duration: const Duration(milliseconds: 300),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              MaterialLocalizationsEo.delegate,
              CupertinoLocalizationsEo.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            title: 'lichess.org',
            locale: generalPrefs.locale,
            theme: theme.copyWith(
              navigationBarTheme: isIOS
                  ? null
                  : NavigationBarTheme.of(context).copyWith(
                      height: isShortVerticalScreen(context) ? 60 : null,
                    ),
            ),
            home: const MainTabScaffold(),
            navigatorObservers: [rootNavPageRouteObserver],
          );
        },
      ),
    );
  }
}
