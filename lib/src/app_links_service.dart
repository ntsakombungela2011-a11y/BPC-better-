import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/analysis/analysis_controller.dart';
import 'package:lichess_mobile/src/model/broadcast/broadcast.dart';
import 'package:lichess_mobile/src/model/broadcast/broadcast_providers.dart';
import 'package:lichess_mobile/src/model/challenge/challenge_repository.dart';
import 'package:lichess_mobile/src/model/challenge/challenge_service.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/game/game_repository.dart';
import 'package:lichess_mobile/src/model/game/playable_game.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_providers.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_angle.dart';
import 'package:lichess_mobile/src/model/puzzle/puzzle_theme.dart';
import 'package:lichess_mobile/src/model/tv/tv_channel.dart';
import 'package:lichess_mobile/src/model/user/user.dart';
import 'package:lichess_mobile/src/model/user/user_repository.dart';
import 'package:lichess_mobile/src/view/analysis/analysis_screen.dart';
import 'package:lichess_mobile/src/view/broadcast/broadcast_player_results_screen.dart';
import 'package:lichess_mobile/src/view/broadcast/broadcast_round_screen.dart';
import 'package:lichess_mobile/src/view/puzzle/puzzle_screen.dart';
import 'package:lichess_mobile/src/view/tournament/tournament_screen.dart';
import 'package:lichess_mobile/src/view/watch/tv_screen.dart';
import 'package:lichess_mobile/src/view/user/user_screen.dart';
import 'package:lichess_mobile/src/view/user/user_or_profile_screen.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/utils/list_extension.dart';
import 'package:lichess_mobile/src/widgets/feedback.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dartchess/dartchess.dart';

final appLinksServiceProvider = Provider((ref) => AppLinksService(ref));

class AppLinksService {
  AppLinksService(this.ref);

  final Ref ref;
  final _logger = Logger('AppLinksService');

  static const kLichessHost = 'lichess.org';
  static const _kDailyPuzzleDeeplinkPath = 'training/daily';

  void start() {
    // Initialization logic if needed
  }

  /// Resolves an app link [Uri] into a list of [Route]s to push.
  ///
  /// Returns `null` if the link cannot be resolved.
  Future<List<Route<dynamic>>?> resolveAppLinkUri(BuildContext context, Uri appLinkUri) async {
    if (appLinkUri.scheme == 'org.lichess.mobile') {
      if (appLinkUri.host == 'open-web') {
        _handleOpenWebLink(appLinkUri);
        return [];
      }
    }

    if (appLinkUri.pathSegments.getOrNull(0) == _kDailyPuzzleDeeplinkPath) {
      final puzzleId = appLinkUri.pathSegments.getOrNull(1);
      await handleDailyPuzzleLink(context, puzzleId);
      return [];
    }

    if (appLinkUri.scheme == 'https' && appLinkUri.host != kLichessHost) {
      return null;
    }

    final path = appLinkUri.pathSegments.getOrNull(0);
    switch (path) {
      case 'analysis':
        final options = AnalysisOptions.standalone(
          variant: Variant.standard,
          orientation: Side.white,
          initialMoveCursor: appLinkUri.queryParameters['fen'] != null ? 0 : null,
        );
        return [AnalysisScreen.buildRoute(options)];
      case 'broadcast':
        if (appLinkUri.pathSegments.length < 2) return null;
        final roundId = BroadcastRoundId(appLinkUri.pathSegments[1]);
        if (appLinkUri.pathSegments.length == 2) {
          return [BroadcastRoundScreenLoading.buildRoute(roundId)];
        } else {
          final fragment = appLinkUri.fragment;
          final tab = BroadcastRoundTab.tabOrNullFromString(fragment.split('/').first);
          if (tab == BroadcastRoundTab.players && fragment.length > 'players/'.length) {
            final playerId = Uri.decodeComponent(fragment.substring('players/'.length));
            return [
              BroadcastRoundScreenLoading.buildRoute(
                roundId,
                initialTab: BroadcastRoundTab.players,
              ),
              BroadcastPlayerResultsScreenLoading.buildRoute(roundId, playerId),
            ];
          }
          return [BroadcastRoundScreenLoading.buildRoute(roundId, initialTab: tab)];
        }
      case 'tournament':
        if (appLinkUri.pathSegments.length < 2) return null;
        final tournamentId = TournamentId(appLinkUri.pathSegments[1]);
        final playerName = appLinkUri.queryParameters['player'];
        final playerId = playerName != null ? UserId.fromUserName(playerName) : null;
        return [TournamentScreen.buildRoute(tournamentId, initialPlayerId: playerId)];
      case 'training':
        if (appLinkUri.pathSegments.length < 2) return null;
        final id = appLinkUri.pathSegments[1];
        return [PuzzleScreen.buildRoute(angle: PuzzleAngle.fromKey('mix'), puzzleId: PuzzleId(id))];
      case 'tv':
        if (appLinkUri.pathSegments.length < 2) return null;
        final channel = TvChannel.nameMap[appLinkUri.pathSegments[1]];
        if (channel != null) {
          return [TvScreen.buildRoute(channel: channel)];
        } else {
          if (!context.mounted) return null;
          showSnackBar(
            context,
            'Invalid TV channel: ${appLinkUri.pathSegments[1]}',
            type: SnackBarType.error,
          );
          return [];
        }
      case '@':
        if (appLinkUri.pathSegments.length < 2) return null;
        final isTv = appLinkUri.pathSegments.getOrNull(2) == 'tv';
        if (appLinkUri.pathSegments.length > 2 && !isTv) {
          return null;
        }
        try {
          final user = await ref
              .read(userRepositoryProvider)
              .getUser(UserId.fromUserName(appLinkUri.pathSegments[1]));
          if (!context.mounted) return null;

          return isTv
              ? [TvScreen.buildRoute(user: user.lightUser)]
              : [UserOrProfileScreen.buildRoute(user.lightUser)];
        } catch (e) {
          if (!context.mounted) return null;
          showSnackBar(
            context,
            'Cannot find user ${appLinkUri.pathSegments[1]}',
            type: SnackBarType.error,
          );
          return [];
        }
      case _:
        final gameRoutes = await _tryResolveGameLink(context, appLinkUri);
        if (gameRoutes != null) return gameRoutes;
    }

    return null;
  }

  void _handleOpenWebLink(Uri uri) {
    final target = uri.queryParameters['url'];
    if (target != null) {
      final targetUri = Uri.tryParse(target);
      if (targetUri != null) {
        launchUrl(targetUri, mode: LaunchMode.inAppBrowserView);
      }
    }
  }

  @visibleForTesting
  Future<void> handleDailyPuzzleLink(
    BuildContext context,
    String? puzzleId, {
    bool animated = true,
  }) async {
    try {
      Puzzle puzzle;
      final dailyPuzzle = await ref.read(dailyPuzzleProvider.future);
      if (puzzleId == null || dailyPuzzle.puzzle.id == PuzzleId(puzzleId)) {
        puzzle = dailyPuzzle;
      } else {
        try {
          puzzle = await ref.read(puzzleProvider(PuzzleId(puzzleId)).future);
        } catch (e, st) {
          _logger.info('Failed to load widget puzzle id $puzzleId, falling back: $e', e, st);
          puzzle = dailyPuzzle;
        }
      }
      if (!context.mounted) return;
      final route = PuzzleScreen.buildRoute(
        angle: PuzzleAngle.fromKey('mix'),
        puzzle: puzzle,
      );
      await _pushDeepLinkRoute(
        Navigator.of(context, rootNavigator: true),
        route,
        animated: animated,
      );
    } catch (e, st) {
      _logger.severe('Failed to open daily puzzle from widget: $e\n$st');
    }
  }

  Future<bool> _tryResolveChallengeLink(BuildContext context, Uri appLinkUri) async {
    try {
      if (appLinkUri.pathSegments.isEmpty) return false;
      final challengeId = ChallengeId(appLinkUri.pathSegments[0]);
      if (!challengeId.isValid) return false;
      final challenge = await ref.read(challengeRepositoryProvider).show(challengeId);
      if (!context.mounted) return false;

      ref.read(challengeServiceProvider).showConfirmDialog(context, challenge, fromLink: true);

      return true;
    } catch (e, st) {
      _logger.info('Not a challenge link: $e', e, st);
    }
    return false;
  }

  Future<List<Route<dynamic>>?> _tryResolveGameLink(BuildContext context, Uri appLinkUri) async {
    try {
      if (appLinkUri.pathSegments.isEmpty) return null;
      final gameId = GameId(appLinkUri.pathSegments[0]);
      if (!gameId.isValid) return null;

      final game = await ref.read(gameRepositoryProvider).getGame(gameId);
      final orientation = appLinkUri.pathSegments.getOrNull(1) == 'black' ? Side.black : Side.white;
      final int ply = int.tryParse(appLinkUri.fragment) ?? 0;

      if (!context.mounted) return null;

      if (game.finished || game.source == GameSource.import) {
        return [
          AnalysisScreen.buildRoute(
            AnalysisOptions.archivedGame(
              orientation: orientation,
              gameId: gameId,
              initialMoveCursor: ply,
            ),
          ),
        ];
      }

      final user = game.playerOf(orientation).user;
      if (user != null) {
        return [TvScreen.buildRoute(gameId: gameId, user: user, orientation: orientation)];
      }
    } catch (e, st) {
      _logger.info('Not a game link: $e', e, st);
    }

    return null;
  }

  Future<void> handleAppLink(
    BuildContext context,
    Uri uri, {
    bool animated = true,
    bool allowBrowserFallback = true,
  }) async {
    final routes = await resolveAppLinkUri(context, uri);
    if (!context.mounted) return;

    if (routes != null) {
      final navigator = Navigator.of(context, rootNavigator: true);
      for (final route in routes) {
        _pushDeepLinkRoute(navigator, route, animated: animated);
      }
    } else {
      final isChallengeLink = await _tryResolveChallengeLink(context, uri);
      if (isChallengeLink) return;

      if (allowBrowserFallback) {
        launchUrl(uri);
      } else {
        _logger.warning('Could not resolve app link $uri');
      }
    }
  }

  static Future<void> _pushDeepLinkRoute(
    NavigatorState navigator,
    Route<dynamic> route, {
    required bool animated,
  }) {
    final pushed = animated ? route : _withNoTransition(route);
    Route<dynamic>? top;
    navigator.popUntil((r) {
      top = r;
      return true;
    });
    final topRoute = top;
    if (topRoute is ScreenRoute &&
        pushed is ScreenRoute &&
        topRoute.screen.runtimeType == pushed.screen.runtimeType) {
      return navigator.pushReplacement(pushed);
    }
    return navigator.push(pushed);
  }

  static Route<dynamic> _withNoTransition(Route<dynamic> route) {
    if (route is ScreenRoute) {
      return MaterialScreenRoute(
        screen: (route as ScreenRoute).screen,
        settings: route.settings,
        fullscreenDialog: route.fullscreenDialog,
        maintainState: route.maintainState,
        allowSnapshotting: route.allowSnapshotting,
        overrideTransitionDuration: Duration.zero,
      );
    }
    return route;
  }

  static const kLichessLinkifiers = [UrlLinkifier(), EmailLinkifier()];

  Future<void> onLinkifyOpen(BuildContext context, LinkableElement link) async {
    if (link is UrlElement && link.url.startsWith(RegExp('https?:\\/\\/$kLichessHost'))) {
      final appLinkUri = Uri.parse(link.url);
      await handleAppLink(context, appLinkUri);
    } else if (link.originText.startsWith('@')) {
      final username = link.originText.substring(1);
      Navigator.of(context).push(
        UserOrProfileScreen.buildRoute(
          LightUser(id: UserId(UserId.fromUserName(username).value), name: username),
        ),
      );
    } else {
      launchUrl(Uri.parse(link.url));
    }
  }
}
