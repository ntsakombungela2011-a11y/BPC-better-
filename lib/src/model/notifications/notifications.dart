import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lichess_mobile/l10n/l10n.dart';
import 'package:lichess_mobile/src/model/challenge/challenge.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/game/playable_game.dart';
import 'package:lichess_mobile/src/model/user/user.dart' show TemporaryBan;
import 'package:lichess_mobile/src/utils/json.dart';
import 'package:lichess_mobile/src/utils/l10n.dart' show relativeDate;
import 'package:meta/meta.dart';

///////////////

///
/// kind of use cases, depending on the message content:
///
///   and the application can handle it in the foreground or background; It typically
///   serves to update the application state silently.
///
///   If the application is in the background, the system displays the notification to the user.
///   If the application is in the foreground, the system does not display the notification
///   automatically, but we might want to display it ourselves.
///   which can also be used to update the application state.
 else {
      switch (messageType) {
        case 'corresAlarm':
        case 'gameTakebackOffer':
        case 'gameDrawOffer':
        case 'gameMove':
        case 'gameFinish':
          final gameFullId = message.data['lichess.fullId'] as String?;
          final round = message.data['lichess.round'] as String?;
          if (gameFullId != null) {
            final fullId = GameFullId(gameFullId);
            final game = round != null
                ? PlayableGame.fromServerJson(jsonDecode(round) as Map<String, dynamic>)
                : null;
              fullId,
              game: game,
              notification: message.notification,
            );
          } else {
          }
        case 'newMessage':
          final conversationId = message.data['lichess.threadId'] as String?;
          if (conversationId != null) {
          } else {
          }
        case 'challengeCreate':
          final challengeId = message.data['lichess.challengeId'] as String?;
          if (challengeId != null) {
              ChallengeId(challengeId),
              notification: message.notification,
            );
          } else {
          }
        case 'challengeAccept':
          final challengeId = message.data['lichess.challengeId'] as String?;
          final fullId = message.data['lichess.fullId'] as String?;
          if (challengeId != null && fullId != null) {
              ChallengeId(challengeId),
              GameFullId(fullId),
              notification: message.notification,
            );
          } else {
          }
        default:
      }
    }
  }
}

@immutable
);

  final UserId conversationId;

  @override
  final RemoteNotification? notification;

  @override
}

@immutable
);

  final GameFullId fullId;
  final PlayableGame? game;

  @override
  final RemoteNotification? notification;
}

@immutable
);

  final ChallengeId id;

  @override
  final RemoteNotification? notification;
}

@immutable
);

  final ChallengeId id;
  final GameFullId fullId;

  @override
  final RemoteNotification? notification;
}

@immutable


@immutable


/// Local Notifications
///////////////////////

/// A notification shown to the user from the platform's notification system.
@immutable
sealed class LocalNotification {
  const LocalNotification();

  /// The unique identifier of the notification.
  int get id;

  /// The channel identifier of the notification.
  ///
  /// Corresponds to [AndroidNotificationDetails.channelId] for android and
  /// [DarwinNotificationDetails.threadIdentifier] for iOS.
  ///
  /// It must match the channel identifier of the notification details.
  String get channelId;

  /// The localized title of the notification.
  String title(AppLocalizations l10n);

  /// The localized body of the notification.
  String? body(AppLocalizations l10n);

  /// The payload of the notification.
  ///
  /// Implementations must not override this getter, but [_concretePayload] instead.
  ///
  /// See [LocalNotification.fromJson] where the [channelId] is used to determine the
  /// concrete type of the notification, to be able to deserialize it.
  Map<String, dynamic> get payload => {'channel': channelId, ..._concretePayload};

  /// The actual payload of the notification.
  ///
  /// Will be merged with the channel:[channelId] entry to form the final payload.
  Map<String, dynamic> get _concretePayload;

  /// The localized details of the notification for each platform.
  NotificationDetails details(AppLocalizations l10n);

  /// Retrives a local notification from a JSON payload.


  @override
  String get channelId => 'newMessage';

  @override
  int get id => conversationId.hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {
    'conversationId': conversationId.toJson(),
    'title': _title,
    'message': _message,
  };

  @override
  String title(AppLocalizations l10n) => _title;

  @override
  String body(AppLocalizations _) => _message;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      l10n.preferencesNotifyInboxMsg,
      importance: Importance.max,
      priority: Priority.high,
      autoCancel: true,
    ),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

/// A notification for a correspondence game update.
///
/// This notification is shown when a correspondence game is updated on the server
///
/// Fields [title] and [body] are dynamic and part of the payload because they
class CorresGameUpdateNotification extends LocalNotification {
  const CorresGameUpdateNotification(this.fullId, String title, String body)
    : _title = title,
      _body = body;

  final GameFullId fullId;

  final String _title;
  final String _body;



  @override
  String get channelId => 'corresGameUpdate';

  @override
  int get id => fullId.hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {
    'fullId': fullId.toJson(),
    'title': _title,
    'body': _body,
  };

  @override
  String title(_) => _title;

  @override
  String? body(_) => _body;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      l10n.preferencesNotifyGameEvent,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      autoCancel: true,
    ),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

/// A notification for a challenge acceptance.
///
/// This notification is shown when a challenge is accepted on the server.
class ChallengeAcceptedNotification extends LocalNotification {
  const ChallengeAcceptedNotification(this.fullId, String title, String body)
    : _title = title,
      _body = body;

  final GameFullId fullId;

  final String _title;
  final String _body;



  @override
  String get channelId => 'challengeAccept';

  @override
  int get id => fullId.hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {
    'fullId': fullId.toJson(),
    'title': _title,
    'body': _body,
  };

  @override
  String title(_) => _title;

  @override
  String? body(_) => _body;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      l10n.preferencesNotifyGameEvent,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      autoCancel: true,
    ),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

/// A notification for a challenge creation.
///
/// This notification is shown when a challenge is created on the server while the user is not connected to lichess (e.g., app is in background).
/// If the user is connected, challenges are handled by Websocket and a [ChallengeNotification] is shown instead.
class ChallengeCreatedNotification extends LocalNotification {
  const ChallengeCreatedNotification(this.challengeId, String title, String body)
    : _title = title,
      _body = body;

  final ChallengeId challengeId;

  final String _title;
  final String _body;



  @override
  String get channelId => 'challengeCreate';

  @override
  int get id => challengeId.hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {
    'challengeId': challengeId.toJson(),
    'title': _title,
    'body': _body,
  };

  @override
  String title(_) => _title;

  @override
  String? body(_) => _body;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      l10n.preferencesNotifyGameEvent,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      autoCancel: true,
    ),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

/// A notification for a server-wide announcement.
///
/// There can only be one announce notification at a time. It is shown when the server
/// sends an announce message through the WebSocket, and cancelled when the server
/// clears it or the optional countdown date is reached.
class AnnounceNotification extends LocalNotification {
  const AnnounceNotification(this.message, {this.date});

  final String message;

  /// Optional date shown as a relative time in the notification body.
  final DateTime? date;

  static final int notificationId = 'announce'.hashCode;

  static const _channelId = 'announce';

  static const dismissActionId = 'dismiss';

  static const darwinCategoryId = 'announce-notification';

  factory AnnounceNotification.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String?;
    return AnnounceNotification(
      json['message'] as String,
      date: dateStr != null ? DateTime.parse(dateStr) : null,
    );
  }

  static DarwinNotificationCategory darwinCategory(AppLocalizations l10n) =>
      DarwinNotificationCategory(
        darwinCategoryId,
        actions: [
          DarwinNotificationAction.plain(dismissActionId, l10n.mobileCustomizeHomeTipDismiss),
        ],
      );

  @override
  int get id => notificationId;

  @override
  String get channelId => _channelId;

  @override
  Map<String, dynamic> get _concretePayload => {
    'message': message,
    if (date != null) 'date': date!.toIso8601String(),
  };

  @override
  String title(AppLocalizations _) => message;

  @override
  String? body(AppLocalizations l10n) => date != null ? relativeDate(l10n, date!) : null;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Lichess Announcements',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: false,
      actions: [
        AndroidNotificationAction(
          dismissActionId,
          l10n.mobileCustomizeHomeTipDismiss,
          showsUserInterface: false,
        ),
      ],
    ),
    iOS: const DarwinNotificationDetails(
      threadIdentifier: _channelId,
      categoryIdentifier: darwinCategoryId,
    ),
  );
}

/// A notification for a received challenge.
///
/// This notification is shown when a challenge is received from the server through
/// the web socket.
class ChallengeNotification extends LocalNotification {
  const ChallengeNotification(this.challenge);

  final Challenge challenge;

  factory ChallengeNotification.fromJson(Map<String, dynamic> json) {
    final challenge = Challenge.fromJson(json['challenge'] as Map<String, dynamic>);
    return ChallengeNotification(challenge);
  }

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
    android: AndroidNotificationDetails(
      channelId,
      l10n.preferencesNotifyChallenge,
      importance: Importance.max,
      priority: Priority.high,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        if (challenge.variant.isPlaySupported)
          AndroidNotificationAction(
            'accept',
            l10n.accept,
            icon: const DrawableResourceAndroidBitmap('tick'),
            showsUserInterface: true,
            contextual: true,
          ),
        AndroidNotificationAction(
          'decline',
          l10n.decline,
          icon: const DrawableResourceAndroidBitmap('cross'),
          showsUserInterface: true,
          contextual: true,
        ),
      ],
    ),
    iOS: DarwinNotificationDetails(
      threadIdentifier: channelId,
      categoryIdentifier: challenge.variant.isPlaySupported
          ? darwinPlayableVariantCategoryId
          : darwinUnplayableVariantCategoryId,
    ),
  );

  static const darwinPlayableVariantCategoryId = 'challenge-notification-playable-variant';

  static const darwinUnplayableVariantCategoryId = 'challenge-notification-unplayable-variant';

  static DarwinNotificationCategory darwinPlayableVariantCategory(AppLocalizations l10n) =>
      DarwinNotificationCategory(
        darwinPlayableVariantCategoryId,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            'accept',
            l10n.accept,
            options: <DarwinNotificationActionOption>{DarwinNotificationActionOption.foreground},
          ),
          DarwinNotificationAction.plain(
            'decline',
            l10n.decline,
            options: <DarwinNotificationActionOption>{DarwinNotificationActionOption.foreground},
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      );

  static DarwinNotificationCategory darwinUnplayableVariantCategory(AppLocalizations l10n) =>
      DarwinNotificationCategory(
        darwinUnplayableVariantCategoryId,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            'decline',
            l10n.decline,
            options: <DarwinNotificationActionOption>{DarwinNotificationActionOption.foreground},
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      );
}
