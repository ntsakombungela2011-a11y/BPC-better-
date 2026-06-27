import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';

/// Status of a chat message delivery.
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

/// A chat message in a private conversation.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.status = MessageStatus.sending,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': Timestamp.fromDate(timestamp),
        'status': status.name,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final ts = json['timestamp'];
    DateTime timestamp;
    if (ts is Timestamp) {
      timestamp = ts.toDate();
    } else if (ts is DateTime) {
      timestamp = ts;
    } else {
      timestamp = DateTime.now();
    }

    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      timestamp: timestamp,
      status: MessageStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }
}

/// Provider for Firestore database instance.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for sending a private message.
final sendPrivateMessageProvider = FutureProvider.family<void, ({String conversationId, String content})>((ref, params) async {
  final auth = ref.read(authControllerProvider);
  if (auth == null) return;

  final db = ref.read(firestoreProvider);
  final messageId = db.collection('messages').doc().id;
  
  final message = {
    'id': messageId,
    'senderId': auth.user.id,
    'receiverId': params.conversationId.split('_').firstWhere((id) => id != auth.user.id, orElse: () => params.conversationId),
    'content': params.content,
    'timestamp': FieldValue.serverTimestamp(),
    'status': MessageStatus.sent.name,
  };

  await db.collection('conversations').doc(params.conversationId)
      .collection('messages').doc(messageId).set(message);
});

/// Provider for watching messages in a conversation.
final privateMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, conversationId) {
  final db = ref.watch(firestoreProvider);
  
  return db.collection('conversations').doc(conversationId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList());
});

/// Provider to mark messages as read.
final markPrivateMessagesReadProvider = FutureProvider.family<void, String>((ref, conversationId) async {
  final auth = ref.read(authControllerProvider);
  if (auth == null) return;

  final db = ref.read(firestoreProvider);
  
  final messages = await db.collection('conversations').doc(conversationId)
      .collection('messages')
      .where('receiverId', isEqualTo: auth.user.id)
      .where('status', whereIn: ['sent', 'delivered'])
      .get();

  final batch = db.batch();
  for (final doc in messages.docs) {
    batch.update(doc.reference, {'status': MessageStatus.read.name});
  }
  await batch.commit();
});

/// Provider to get or create a conversation.
final getOrCreateConversationProvider = FutureProvider.family<String, ({String otherUserId, String otherUserName})>((ref, params) async {
  final auth = ref.read(authControllerProvider);
  if (auth == null) throw Exception('Not authenticated');

  final db = ref.read(firestoreProvider);
  
  // Sort IDs for consistent conversation ID
  final sortedIds = [auth.user.id, params.otherUserId]..sort();
  final conversationId = '${sortedIds[0]}_${sortedIds[1]}';

  final docRef = db.collection('conversations').doc(conversationId);
  final doc = await docRef.get();

  if (!doc.exists) {
    await docRef.set({
      'participant1Id': sortedIds[0],
      'participant2Id': sortedIds[1],
      'participant1Name': auth.user.id == sortedIds[0] ? auth.user.username : params.otherUserName,
      'participant2Name': auth.user.id == sortedIds[0] ? params.otherUserName : auth.user.username,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  return conversationId;
});

/// Provider to watch typing indicator.
final typingIndicatorProvider = StreamProvider.family<bool, String>((ref, conversationId) {
  final auth = ref.watch(authControllerProvider);
  if (auth == null) return Stream.value(false);

  final db = ref.watch(firestoreProvider);
  
  return db.collection('conversations').doc(conversationId).snapshots().map((doc) {
    if (!doc.exists) return false;
    final data = doc.data()!;
    final isP1 = auth.user.id == data['participant1Id'];
    return isP1 
        ? (data['participant2Typing'] as bool? ?? false)
        : (data['participant1Typing'] as bool? ?? false);
  });
});

/// Provider to send typing indicator.
final sendTypingIndicatorProvider = FutureProvider.family<void, ({String conversationId, bool isTyping})>((ref, params) async {
  final auth = ref.read(authControllerProvider);
  if (auth == null) return;

  final db = ref.read(firestoreProvider);
  final doc = await db.collection('conversations').doc(params.conversationId).get();
  if (!doc.exists) return;

  final data = doc.data()!;
  final isP1 = auth.user.id == data['participant1Id'];
  
  await db.collection('conversations').doc(params.conversationId).update({
    isP1 ? 'participant1Typing' : 'participant2Typing': params.isTyping,
    'typingAt': FieldValue.serverTimestamp(),
  });
});