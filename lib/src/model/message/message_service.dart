import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/notifications/notification_service.dart';
import 'package:lichess_mobile/src/model/notifications/notifications.dart';
import 'package:lichess_mobile/src/model/user/user_repository.dart';
import 'package:lichess_mobile/src/tab_scaffold.dart';
import 'package:lichess_mobile/src/view/message/conversation_screen.dart';

final messageServiceProvider = Provider<MessageService>((Ref ref) {
  final service = MessageService(ref);
  ref.onDispose(service.dispose);
  return service;
});

class MessageService {
  MessageService(this.ref);
  final Ref ref;
  StreamSubscription<ParsedLocalNotification>? _notificationResponseSubscription;

  void start() {
    _notificationResponseSubscription = NotificationService.responseStream.listen((data) {
      final (_, notification) = data;
      if (notification is NewMessageNotification) {
        _onNotificationResponse(notification.conversationId);
      }
    });
  }

  Future<void> _onNotificationResponse(UserId conversationId) async {
    final user = await ref.read(userRepositoryProvider).getUser(conversationId);
    if (user.kid == true) return;
    final context = ref.read(currentNavigatorKeyProvider).currentContext;
    if (context == null || !context.mounted) return;
    final rootNavState = Navigator.of(context, rootNavigator: true);
    if (rootNavState.canPop()) {
      rootNavState.popUntil((route) => route.isFirst);
    }
    Navigator.of(context, rootNavigator: true).push(ConversationScreen.buildRoute(user: user.lightUser));
  }

  void dispose() {
    _notificationResponseSubscription?.cancel();
  }
}
