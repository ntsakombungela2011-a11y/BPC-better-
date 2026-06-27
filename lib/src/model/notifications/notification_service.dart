import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/l10n/l10n.dart';
import 'package:lichess_mobile/src/localizations.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
import 'package:lichess_mobile/src/model/chat/private_chat.dart';
import 'package:lichess_mobile/src/model/notifications/bpc_notifications.dart';
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.info('Received foreground message: ${message.notification?.title}');

      final data = message.data;
      if (data['type'] == 'BpcPrivateChatNotification') {
        final notification = BpcPrivateChatNotification.fromJson(data);
        show(notification);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.info('Opened app from background message: ${message.data}');
      _handleRemoteMessage(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _logger.info('App opened from terminated state via message: ${message.data}');
        _handleRemoteMessage(message);
      }
    });
  }

  void _handleRemoteMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'BpcPrivateChatNotification') {
      final notification = BpcPrivateChatNotification.fromJson(data);
      _responseStreamController.add((
        NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          payload: jsonEncode(notification.payload),
        ),
        notification,
      ));
    }
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

  Future<bool> registerDevice() async {
    try {
      final auth = _ref.read(authControllerProvider);
      if (auth == null) return false;

      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await messaging.getToken();
        if (token != null) {
          final db = _ref.read(firestoreProvider);
          await db.collection('users').doc(auth.user.id.toString()).set({
            'fcmTokens': FieldValue.arrayUnion([token]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          _logger.info('FCM token registered successfully');
          return true;
        }
      }
    } catch (e, st) {
      _logger.severe('Failed to register device for notifications: $e', e, st);
    }
    return false;
  }

  Future<void> unregister() async {
    try {
      final auth = _ref.read(authControllerProvider);
      if (auth == null) return;

      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      if (token != null) {
        final db = _ref.read(firestoreProvider);
        await db.collection('users').doc(auth.user.id.toString()).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
      await messaging.deleteToken();
    } catch (e, st) {
      _logger.severe('Failed to unregister device for notifications: $e', e, st);
    }
  }
}