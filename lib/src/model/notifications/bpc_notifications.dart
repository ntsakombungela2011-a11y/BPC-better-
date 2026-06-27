import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lichess_mobile/l10n/l10n.dart';
import 'package:lichess_mobile/src/model/notifications/notifications.dart';

class BpcPrivateChatNotification extends LocalNotification {
  const BpcPrivateChatNotification({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    required this.message,
  });

  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String message;

  factory BpcPrivateChatNotification.fromJson(Map<String, dynamic> json) {
    return BpcPrivateChatNotification(
      conversationId: json['conversationId'] as String,
      otherUserId: json['otherUserId'] as String,
      otherUserName: json['otherUserName'] as String,
      message: json['message'] as String,
    );
  }

  @override
  String get channelId => 'bpc_private_chat';

  @override
  int get id => conversationId.hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {
    'conversationId': conversationId,
    'otherUserId': otherUserId,
    'otherUserName': otherUserName,
    'message': message,
  };

  @override
  String title(AppLocalizations l10n) => 'Message from $otherUserName';

  @override
  String body(AppLocalizations _) => message;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      'BPC Private Chat',
      importance: Importance.max,
      priority: Priority.high,
      autoCancel: true,
    ),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}
