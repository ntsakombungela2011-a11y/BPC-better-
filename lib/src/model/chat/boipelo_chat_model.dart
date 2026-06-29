import 'dart:convert';

enum MessageStatus { sending, sent, delivered, read }

class BoipeloChatMessage {
  final int? id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;

  const BoipeloChatMessage({
    this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  BoipeloChatMessage copyWith({
    int? id,
    String? senderId,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return BoipeloChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
    };
  }

  factory BoipeloChatMessage.fromJson(Map<String, dynamic> json) {
    return BoipeloChatMessage(
      id: json['id'] as int?,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, Object?> toDbRow() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
    };
  }

  factory BoipeloChatMessage.fromDbRow(Map<String, dynamic> row) {
    return BoipeloChatMessage(
      id: row['id'] as int,
      senderId: row['senderId'] as String,
      text: row['text'] as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      status: MessageStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }
}
