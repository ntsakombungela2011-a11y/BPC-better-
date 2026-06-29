import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/account/ongoing_game.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
import 'package:lichess_mobile/src/model/auth/bearer.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/common/socket.dart';
import 'package:lichess_mobile/src/model/correspondence/correspondence_game_storage.dart';
import 'package:lichess_mobile/src/model/correspondence/offline_correspondence_game.dart';
import 'package:lichess_mobile/src/model/game/game_repository.dart';
import 'package:lichess_mobile/src/model/game/game_socket_events.dart';
import 'package:lichess_mobile/src/model/game/playable_game.dart';
import 'package:lichess_mobile/src/model/notifications/notification_service.dart';
import 'package:lichess_mobile/src/model/notifications/notifications.dart';
import 'package:lichess_mobile/src/network/http.dart';
import 'package:lichess_mobile/src/network/socket.dart';
import 'package:lichess_mobile/src/tab_scaffold.dart' show currentNavigatorKeyProvider;
import 'package:lichess_mobile/src/view/game/game_screen.dart';
import 'package:lichess_mobile/src/view/game/game_screen_providers.dart';
import 'package:logging/logging.dart';

final correspondenceServiceProvider = Provider<CorrespondenceService>((Ref ref) {
  final service = CorrespondenceService(Logger('CorrespondenceService'), ref: ref);
  ref.onDispose(() => service.dispose());
  return service;
}, name: 'CorrespondenceServiceProvider');

class CorrespondenceService {
  CorrespondenceService(this._log, {required this.ref});
  final Ref ref;
  final Logger _log;
  StreamSubscription<ParsedLocalNotification>? _notificationResponseSubscription;

  void start() {
    _notificationResponseSubscription = NotificationService.responseStream.listen((data) {
      final (_, notification) = data;
      if (notification is CorresGameUpdateNotification) {
        _onNotificationResponse(notification.fullId);
      }
    });
  }

  void dispose() {
    _notificationResponseSubscription?.cancel();
  }

  Future<void> _onNotificationResponse(GameFullId fullId) async {
    final context = ref.read(currentNavigatorKeyProvider).currentContext;
    if (context == null || !context.mounted) return;
    final rootNavState = Navigator.of(context, rootNavigator: true);
    if (rootNavState.canPop()) {
      rootNavState.popUntil((route) => route.isFirst);
    }
    Navigator.of(context, rootNavigator: true).push(GameScreen.buildRoute(source: ExistingGameSource(fullId)));
  }

  Future<void> syncGames() async {
    if (_authUser == null) return;
    _log.info('Syncing correspondence games...');
    await playRegisteredMoves();
    final storedOngoingGames = await (await _storage).fetchOngoingGames(_authUser?.user.id);
    try {
      final gameRepository = ref.read(gameRepositoryProvider);
      final ongoingGames = await ref.read(ongoingGamesProvider.future);
      for (final sg in storedOngoingGames) {
        final game = ongoingGames.firstWhereOrNull((e) => e.id == sg.$2.id);
        if (game == null) {
          _log.info('Deleting correspondence game ${sg.$2.id} because it is not present on the server anymore');
          (await _storage).delete(sg.$2.id);
        }
      }
      final playableGames = await gameRepository.getMyGamesByIds(ISet(ongoingGames.map((e) => e.id)));
      await Future.wait([
        for (final playableGame in playableGames)
          updateStoredGame(ongoingGames.firstWhere((e) => e.id == playableGame.id).fullId, playableGame),
      ]);
    } catch (e, s) {
      _log.warning('Failed to sync correspondence games', e, s);
    }
  }

  Future<int> playRegisteredMoves() async {
    _log.info('Playing registered correspondence moves...');
    final games = await (await _storage).fetchGamesWithRegisteredMove(_authUser?.user.id).then((games) => games.map((e) => e.$2).toList());
    WebSocket.userAgent = ref.read(userAgentProvider);
    final Map<String, String> wsHeaders = _authUser != null ? {'Authorization': 'Bearer ${signBearerToken(_authUser!.token)}'} : {};
    int movesPlayed = 0;
    for (final gameToSync in games) {
      if (gameToSync.registeredMoveAtPgn == null) continue;
      final uri = lichessWSUri('/play/${gameToSync.fullId}/v6');
      WebSocket? socket;
      StreamSubscription<SocketEvent>? streamSubscription;
      try {
        socket = await WebSocket.connect(uri.toString(), headers: wsHeaders).timeout(const Duration(seconds: 5));
        final eventStream = socket.where((e) => e != '0').map((e) => SocketEvent.fromJson(jsonDecode(e as String) as Map<String, dynamic>));
        final Completer<PlayableGame> gameCompleter = Completer();
        final Completer<void> movePlayedCompleter = Completer();
        streamSubscription = eventStream.listen((event) {
          if (event.topic == 'full') {
            final playableGame = GameFullEvent.fromJson(event.data as Map<String, dynamic>).game;
            gameCompleter.complete(playableGame);
          } else if (event.topic == 'move') {
            final moveEvent = MoveEvent.fromJson(event.data as Map<String, dynamic>);
            if (moveEvent.uci == gameToSync.registeredMoveAtPgn!.$2.uci) {
              movesPlayed++;
              movePlayedCompleter.complete();
            }
          }
        });
        final playableGame = await gameCompleter.future;
        if (playableGame.sanMoves == gameToSync.registeredMoveAtPgn!.$1) {
          socket.add(jsonEncode({'t': 'move', 'd': {'u': gameToSync.registeredMoveAtPgn!.$2.uci}}));
          await movePlayedCompleter.future.timeout(const Duration(seconds: 3));
          (await ref.read(correspondenceGameStorageProvider.future)).save(gameToSync.copyWith(registeredMoveAtPgn: null));
        } else {
          updateStoredGame(gameToSync.fullId, playableGame);
        }
      } catch (e, s) {
        _log.severe('Failed to sync correspondence game ${gameToSync.id}', e, s);
      } finally {
        streamSubscription?.cancel();
        socket?.close();
      }
    }
    return movesPlayed;
  }

  Future<void> updateStoredGame(GameFullId fullId, PlayableGame game) async {
    return (await ref.read(correspondenceGameStorageProvider.future)).save(
      OfflineCorrespondenceGame(
        id: game.id, fullId: fullId, meta: game.meta, rated: game.meta.rated, steps: game.steps,
        initialFen: game.initialFen, status: game.status, variant: game.meta.variant, speed: game.meta.speed,
        perf: game.meta.perf, white: game.white, black: game.black, youAre: game.youAre,
        daysPerTurn: game.meta.daysPerTurn, clock: game.correspondenceClock, winner: game.winner,
        isThreefoldRepetition: game.isThreefoldRepetition,
      ),
    );
  }

  AuthUser? get _authUser => ref.read(authControllerProvider);
  Future<CorrespondenceGameStorage> get _storage => ref.read(correspondenceGameStorageProvider.future);
}
