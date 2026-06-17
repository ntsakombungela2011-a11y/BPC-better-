import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lichess_mobile/l10n/l10n.dart';
import 'package:lichess_mobile/src/model/challenge/challenge.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/game/playable_game.dart';
import 'package:lichess_mobile/src/model/user/user.dart' show TemporaryBan;
import 'package:lichess_mobile/src/utils/json.dart';
import 'package:lichess_mobile/src/utils/l10n.dart' show relativeDate;
import 'package:meta/meta.dart';

@immutable
abstract class LocalNotification {
  const LocalNotification();
  int get id;
  String get channelId;
  Map<String, dynamic> get payload => {'type': runtimeType.toString(), ..._concretePayload};
  Map<String, dynamic> get _concretePayload;
  String title(AppLocalizations l10n);
  String? body(AppLocalizations l10n);
  NotificationDetails details(AppLocalizations l10n);

  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'CorresGameUpdateNotification': return CorresGameUpdateNotification.fromJson(json);
      case 'NewMessageNotification': return NewMessageNotification.fromJson(json);
      case 'ChallengeAcceptedNotification': return ChallengeAcceptedNotification.fromJson(json);
      case 'ChallengeCreatedNotification': return ChallengeCreatedNotification.fromJson(json);
      case 'AnnounceNotification': return AnnounceNotification.fromJson(json);
      case 'ChallengeNotification': return ChallengeNotification.fromJson(json);
      default: throw Exception('Unknown notification type: $type');
    }
  }
}

class NewMessageNotification extends LocalNotification {
  const NewMessageNotification(this.conversationId, this._title, this._message);
  final UserId conversationId;
  final String _title;
  final String _message;
  factory NewMessageNotification.fromJson(Map<String, dynamic> json) =>
    NewMessageNotification(UserId.fromJson(json['conversationId'] as String), json['title'] as String, json['message'] as String);
  @override
  String get channelId => 'newMessage';
  @override
  int get id => conversationId.hashCode;
  @override
  Map<String, dynamic> get _concretePayload => {'conversationId': conversationId.toJson(), 'title': _title, 'message': _message};
  @override
  String title(AppLocalizations l10n) => _title;
  @override
  String body(AppLocalizations _) => _message;
  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(channelId, l10n.preferencesNotifyInboxMsg, importance: Importance.max, priority: Priority.high, autoCancel: true),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

class CorresGameUpdateNotification extends LocalNotification {
  const CorresGameUpdateNotification(this.fullId, this._title, this._body);
  final GameFullId fullId;
  final String _title;
  final String _body;
  factory CorresGameUpdateNotification.fromJson(Map<String, dynamic> json) =>
    CorresGameUpdateNotification(GameFullId.fromJson(json['fullId'] as String), json['title'] as String, json['body'] as String);
  @override
  String get channelId => 'corresGameUpdate';
  @override
  int get id => fullId.hashCode;
  @override
  Map<String, dynamic> get _concretePayload => {'fullId': fullId.toJson(), 'title': _title, 'body': _body};
  @override
  String title(_) => _title;
  @override
  String? body(_) => _body;
  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(channelId, l10n.preferencesNotifyGameEvent, importance: Importance.high, priority: Priority.defaultPriority, autoCancel: true),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

class ChallengeAcceptedNotification extends LocalNotification {
  const ChallengeAcceptedNotification(this.fullId, this._title, this._body);
  final GameFullId fullId;
  final String _title;
  final String _body;
  factory ChallengeAcceptedNotification.fromJson(Map<String, dynamic> json) =>
    ChallengeAcceptedNotification(GameFullId.fromJson(json['fullId'] as String), json['title'] as String, json['body'] as String);
  @override
  String get channelId => 'challengeAccept';
  @override
  int get id => fullId.hashCode;
  @override
  Map<String, dynamic> get _concretePayload => {'fullId': fullId.toJson(), 'title': _title, 'body': _body};
  @override
  String title(_) => _title;
  @override
  String? body(_) => _body;
  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(channelId, l10n.preferencesNotifyGameEvent, importance: Importance.high, priority: Priority.defaultPriority, autoCancel: true),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

class ChallengeCreatedNotification extends LocalNotification {
  const ChallengeCreatedNotification(this.challengeId, this._title, this._body);
  final ChallengeId challengeId;
  final String _title;
  final String _body;
  factory ChallengeCreatedNotification.fromJson(Map<String, dynamic> json) =>
    ChallengeCreatedNotification(ChallengeId.fromJson(json['challengeId'] as String), json['title'] as String, json['body'] as String);
  @override
  String get channelId => 'challengeCreate';
  @override
  int get id => challengeId.hashCode;
  @override
  Map<String, dynamic> get _concretePayload => {'challengeId': challengeId.toJson(), 'title': _title, 'body': _body};
  @override
  String title(_) => _title;
  @override
  String? body(_) => _body;
  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(channelId, l10n.preferencesNotifyGameEvent, importance: Importance.high, priority: Priority.defaultPriority, autoCancel: true),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

class AnnounceNotification extends LocalNotification {
  const AnnounceNotification(this.message, {this.date});
  final String message;
  final DateTime? date;
  static final int notificationId = 'announce'.hashCode;
  static const _channelId = 'announce';
  static const dismissActionId = 'dismiss';
  static const darwinCategoryId = 'announce-notification';
  factory AnnounceNotification.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String?;
    return AnnounceNotification(json['message'] as String, date: dateStr != null ? DateTime.parse(dateStr) : null);
  }
  static DarwinNotificationCategory darwinCategory(AppLocalizations l10n) => DarwinNotificationCategory(darwinCategoryId, actions: [DarwinNotificationAction.plain(dismissActionId, l10n.mobileCustomizeHomeTipDismiss)]);
  @override
  int get id => notificationId;
  @override
  String get channelId => _channelId;
  @override
  Map<String, dynamic> get _concretePayload => {'message': message, if (date != null) 'date': date!.toIso8601String()};
  @override
  String title(AppLocalizations _) => message;
  @override
  String? body(AppLocalizations l10n) => date != null ? relativeDate(l10n, date!) : null;
  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(_channelId, 'Lichess Announcements', importance: Importance.high, priority: Priority.high, autoCancel: false, actions: [AndroidNotificationAction(dismissActionId, l10n.mobileCustomizeHomeTipDismiss, showsUserInterface: false)]),
    iOS: const DarwinNotificationDetails(threadIdentifier: _channelId, categoryIdentifier: darwinCategoryId),
  );
}

class ChallengeNotification extends LocalNotification {
  const ChallengeNotification(this.challenge);
  final Challenge challenge;
  factory ChallengeNotification.fromJson(Map<String, dynamic> json) => ChallengeNotification(Challenge.fromJson(json['challenge'] as Map<String, dynamic>));
  @override
  String get channelId => 'challenge';
  @override
  int get id => challenge.id.value.hashCode;
  @override
  Map<String, dynamic> get _concretePayload => {'challenge': challenge.toJson()};
  @override
  String title(AppLocalizations _) => '${challenge.challenger!.user.name} challenges you!';
  @override
  String body(AppLocalizations l10n) => challenge.description(l10n);
  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(channelId, l10n.preferencesNotifyChallenge, importance: Importance.max, priority: Priority.high, autoCancel: false, actions: [if (challenge.variant.isPlaySupported) AndroidNotificationAction('accept', l10n.accept, icon: const DrawableResourceAndroidBitmap('tick'), showsUserInterface: true, contextual: true), AndroidNotificationAction('decline', l10n.decline, icon: const DrawableResourceAndroidBitmap('cross'), showsUserInterface: true, contextual: true)]),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId, categoryIdentifier: challenge.variant.isPlaySupported ? darwinPlayableVariantCategoryId : darwinUnplayableVariantCategoryId),
  );
  static const darwinPlayableVariantCategoryId = 'challenge-notification-playable-variant';
  static const darwinUnplayableVariantCategoryId = 'challenge-notification-unplayable-variant';
  static DarwinNotificationCategory darwinPlayableVariantCategory(AppLocalizations l10n) => DarwinNotificationCategory(darwinPlayableVariantCategoryId, actions: [DarwinNotificationAction.plain('accept', l10n.accept, options: {DarwinNotificationActionOption.foreground}), DarwinNotificationAction.plain('decline', l10n.decline, options: {DarwinNotificationActionOption.foreground})], options: {DarwinNotificationCategoryOption.hiddenPreviewShowTitle});
  static DarwinNotificationCategory darwinUnplayableVariantCategory(AppLocalizations l10n) => DarwinNotificationCategory(darwinUnplayableVariantCategoryId, actions: [DarwinNotificationAction.plain('decline', l10n.decline, options: {DarwinNotificationActionOption.foreground})], options: {DarwinNotificationCategoryOption.hiddenPreviewShowTitle});
}
