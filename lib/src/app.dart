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
import 'package:lichess_mobile/src/model/study/study_preferences.dart';
import 'package:lichess_mobile/src/network/connectivity.dart';
import 'package:lichess_mobile/src/network/socket.dart';
import 'package:lichess_mobile/src/quick_actions.dart';
import 'package:lichess_mobile/src/shared_pgn_service.dart';
import 'package:lichess_mobile/src/tab_scaffold.dart';
import 'package:lichess_mobile/src/theme.dart';
import 'package:lichess_mobile/src/theme_system.dart';
import 'package:lichess_mobile/src/utils/screen.dart';
import 'package:lichess_mobile/src/widgets/animated_train_logo.dart';

const String _kIosAppGroupId = 'group.com.boipelo.chess.LichessWidgets';
const List<String> _kIosBlogWidgetKinds = [
  'OfficialBlogWidget',
  'CommunityBlogWidget',
  'UserBlogFeedWidget',
];

/// Application initialization and main entry point.
class AppInitializationScreen extends ConsumerStatefulWidget {
  const AppInitializationScreen({super.key});

  @override
  ConsumerState<AppInitializationScreen> createState() => _AppInitializationScreenState();
}

class _AppInitializationScreenState extends ConsumerState<AppInitializationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _splashAnimController;
  late Animation<double> _fadeOut;
  bool _showApp = false;

  @override
  void initState() {
    super.initState();
    _splashAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeOut = CurvedAnimation(
      parent: _splashAnimController,
      curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(preloadedDataProvider);
      if ((current case AsyncData() || AsyncError()) && !_showApp) {
        FlutterNativeSplash.remove();
        _splashAnimController.forward().then((_) {
          if (mounted) {
            setState(() => _showApp = true);
          }
        });
      } else {
        ref.listenManual(preloadedDataProvider, (prev, state) {
          if ((state.hasValue || state.hasError) && !_showApp) {
            FlutterNativeSplash.remove();
            _splashAnimController.forward().then((_) {
              if (mounted) {
                setState(() => _showApp = true);
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _splashAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_showApp || ref.watch(preloadedDataProvider) case AsyncData())
          const Application(),
        if (!_showApp)
          FadeTransition(
            opacity: _fadeOut,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedTrainLogo(
                      size: 200,
                      controller: _splashAnimController,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Boipelo Chess',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The Last Dance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The main application widget.
///
/// This widget is the root of the application and is responsible for setting up
/// the theme, locale, and other global settings.
class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => _AppState();
}

class _AppState extends ConsumerState<Application> {
  /// Whether the app has checked for online status for the first time.
  bool _firstTimeOnlineCheck = false;
  final _navigatorKey = GlobalKey<NavigatorState>();

  // Adjusts some settings for small screens based on the MediaQuery data.
  Future<void> _screenSizeBasedInitialization(WidgetRef ref) async {
    // Bump version here in case we adjust the thresholds for screen size based initialization
    // and want it to run again for users who already launched the app with a previous version.
    const kDoneScreenSizeInitKey = 'done_screen_size_init_v1';

    final prefs = LichessBinding.instance.sharedPreferences;
    if (prefs.getBool(kDoneScreenSizeInitKey) == true) {
      return;
    }

    final mediaQueryData = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    );
    final isTablet = mediaQueryData.size.shortestSide > FormFactor.tablet;
    final isSmallScreen = estimateHeightMinusBoard(mediaQueryData) < kSmallHeightMinusBoard;
    final showEngineLines =
        isTablet || estimateHeightMinusBoard(mediaQueryData) > kSmallHeightMinusBoard - 30;

    // For tablets in portrait mode using the full board size makes the bottom analysis tabs tiny,
    // see https://github.com/lichess-org/mobile/issues/3150,
    // so use a small board there by default as well.
    final smallBoard = isTablet || isSmallScreen;

    await ref
        .read(analysisPreferencesProvider.notifier)
        .save(
          ref
              .read(analysisPreferencesProvider)
              .copyWith(smallBoard: smallBoard, showEngineLines: showEngineLines),
        );
    await ref
        .read(studyPreferencesProvider.notifier)
        .save(
          ref
              .read(studyPreferencesProvider)
              .copyWith(smallBoard: smallBoard, showEngineLines: showEngineLines),
        );
    await ref
        .read(broadcastPreferencesProvider.notifier)
        .save(
          ref
              .read(broadcastPreferencesProvider)
              .copyWith(smallBoard: smallBoard, showEngineLines: showEngineLines),
        );

    await prefs.setBool(kDoneScreenSizeInitKey, true);
  }

  @override
  void initState() {
    _screenSizeBasedInitialization(ref);

    // Start services
    ref.read(appLogServiceProvider).start();
    ref.read(notificationServiceProvider).start();
    ref.read(messageServiceProvider).start();
    ref.read(challengeServiceProvider).start();
    ref.read(accountServiceProvider).start();
    ref.read(correspondenceServiceProvider).start();
    ref.read(quickActionServiceProvider).start();
    ref.read(announceServiceProvider).start();
    ref.read(appLinksServiceProvider).start();
    ref.read(sharedPgnServiceProvider).start();

    if (Platform.isIOS) {
      HomeWidget.setAppGroupId(_kIosAppGroupId);
      HomeWidget.saveWidgetData<String>('lichessHost', kLichessHost);
      ref.listenManual(kidModeProvider, (prev, state) {
        if (state.hasValue && prev?.value != state.value) {
          HomeWidget.saveWidgetData<bool>('isKidMode', state.value).then((_) {
            Future.wait([
              for (final kind in _kIosBlogWidgetKinds) HomeWidget.updateWidget(iOSName: kind),
            ]);
          });
        }
      }, fireImmediately: true);
      ref.listenManual(boardPreferencesProvider, (prev, state) {
        if (prev == null ||
            prev.boardTheme != state.boardTheme ||
            prev.pieceSet != state.pieceSet) {
          Future.wait([
            HomeWidget.saveWidgetData<String>('boardTheme', state.boardTheme.name),
            HomeWidget.saveWidgetData<String>('pieceSet', state.pieceSet.name),
          ]).then((_) {
            HomeWidget.updateWidget(iOSName: 'DailyPuzzleLargeWidget');
          });
        }
      }, fireImmediately: true);
    }

    // Listen for connectivity changes and perform actions accordingly.
    ref.listenManual(connectivityChangesProvider, (prev, current) async {
      final prevWasOffline = prev?.value?.isOnline == false;
      final currentIsOnline = current.value?.isOnline == true;

      // Play registered moves whenever the app comes back online.
      if (prevWasOffline && currentIsOnline) {
        final nbMovesPlayed = await ref.read(correspondenceServiceProvider).playRegisteredMoves();
        if (nbMovesPlayed > 0) {
          ref.invalidate(ongoingGamesProvider);
        }
      }

      // Perform actions once when the app comes online.
      if (current.value?.isOnline == true && !_firstTimeOnlineCheck) {
        _firstTimeOnlineCheck = true;
        ref.read(correspondenceServiceProvider).syncGames();
      }

      final socketClient = ref.read(socketPoolProvider).currentClient;
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
    final generalPrefs = ref.watch(generalPreferencesProvider);
    final boardPrefs = ref.watch(boardPreferencesProvider);
    final selectedTheme = ref.watch(selectedThemeProvider);
    final theme = makeAppTheme(context, generalPrefs, boardPrefs, selectedTheme);

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return AnimatedTheme(
      data: theme,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: MaterialApp(
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
            : NavigationBarTheme.of(
                context,
              ).copyWith(height: isShortVerticalScreen(context) ? 60 : null),
      ),
      home: const MainTabScaffold(),
      navigatorObservers: [rootNavPageRouteObserver],
      ),
    );
  }
}

final selectedThemeProvider = StreamProvider<ThemeModel>((ref) async* {
  yield ThemeManager.instance.currentTheme.value;
  yield* ThemeManager.instance.themeStream;
}).select((value) => value.value ?? ThemeManager.instance.currentTheme.value);
