import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/l10n/l10n.dart';
import 'package:lichess_mobile/src/localizations.dart';
import 'package:logging/logging.dart';
import 'notifications.dart';

final _logger = Logger('NotificationService');

final notificationDisplayProvider = Provider<FlutterLocalNotificationsPlugin>(
  (Ref _) => FlutterLocalNotificationsPlugin(),
);

final notificationServiceProvider = Provider<NotificationService>((Ref ref) {
  final service = NotificationService(ref);
  ref.onDispose(() => service._dispose());
  return service;
});

typedef ParsedLocalNotification = (NotificationResponse response, LocalNotification notification);

class NotificationService {
  NotificationService(this._ref);

  final Ref _ref;

  static final StreamController<ParsedLocalNotification> _responseStreamController =
      StreamController.broadcast();

  static Stream<ParsedLocalNotification> get responseStream => _responseStreamController.stream;

  AppLocalizations get _l10n => _ref.read(localizationsProvider).strings;

  FlutterLocalNotificationsPlugin get _notificationDisplay =>
      _ref.read(notificationDisplayProvider);

  Future<void> start() async {
  }

  Future<int> show(LocalNotification notification) async {
    final id = notification.id;
    final payload = jsonEncode(notification.payload);

    await _notificationDisplay.show(
      id: id,
      title: notification.title(_l10n),
      body: notification.body(_l10n),
      notificationDetails: notification.details(_l10n),
      payload: payload,
    );
    return id;
  }

  Future<void> cancel(int id) {
    return _notificationDisplay.cancel(id: id);
  }

  void _dispose() {
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    final rawPayload = response.payload;
    if (rawPayload == null) return;
    final json = jsonDecode(rawPayload) as Map<String, dynamic>;
    final notification = LocalNotification.fromJson(json);
    _responseStreamController.add((response, notification));
  }

  Future<bool> registerDevice() async => false;
  Future<void> unregister() async {}
}
