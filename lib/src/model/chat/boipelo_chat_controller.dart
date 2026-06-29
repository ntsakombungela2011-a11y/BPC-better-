import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/chat/boipelo_chat_model.dart';
import 'package:lichess_mobile/src/model/chat/boipelo_chat_service.dart';
import 'package:logging/logging.dart';

final _logger = Logger('BoipeloChatController');

final boipeloChatControllerProvider =
    NotifierProvider.autoDispose<BoipeloChatController, BoipeloChatState>(
  BoipeloChatController.new,
  name: 'BoipeloChatController',
);

final boipeloUnreadCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(boipeloChatControllerProvider.select((s) => s.unreadCount));
});

class BoipeloChatState {
  final List<BoipeloChatMessage> messages;
  final bool isLoading;
  final bool boipeloIsTyping;
  final int unreadCount;

  const BoipeloChatState({
    this.messages = const [],
    this.isLoading = true,
    this.boipeloIsTyping = false,
    this.unreadCount = 0,
  });

  BoipeloChatState copyWith({
    List<BoipeloChatMessage>? messages,
    bool? isLoading,
    bool? boipeloIsTyping,
    int? unreadCount,
  }) {
    return BoipeloChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      boipeloIsTyping: boipeloIsTyping ?? this.boipeloIsTyping,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

final _kBoipeloUserId = 'boipelo';

class BoipeloChatController extends Notifier<BoipeloChatState> {
  BoipeloChatService get _service => ref.read(boipeloChatServiceProvider);
  Timer? _typingTimeout;

  @override
  BoipeloChatState build() {
    _loadMessages();
    return const BoipeloChatState();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _service.loadAllMessages();
      final unreadCount = await _service.getUnreadCount();
      state = BoipeloChatState(
        messages: messages,
        isLoading: false,
        unreadCount: unreadCount,
      );
    } catch (e, st) {
      _logger.warning('Failed to load chat messages: $e', e, st);
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final message = BoipeloChatMessage(
      senderId: 'user',
      text: text.trim(),
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    state = state.copyWith(
      messages: [...state.messages, message],
    );

    try {
      await _service.saveMessage(message);
      _simulateBoipeloResponse(text);
    } catch (e, st) {
      _logger.warning('Failed to save message: $e', e, st);
    }
  }

  void setBoipeloTyping(bool typing) {
    state = state.copyWith(boipeloIsTyping: typing);
    _typingTimeout?.cancel();
    if (typing) {
      _typingTimeout = Timer(const Duration(seconds: 5), () {
        if (state.boipeloIsTyping) {
          state = state.copyWith(boipeloIsTyping: false);
        }
      });
    }
  }

  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0) return;
    await _service.markAllAsRead();
    state = state.copyWith(unreadCount: 0);
  }

  Future<void> simulateIncomingMessage(String text) async {
    final message = BoipeloChatMessage(
      senderId: _kBoipeloUserId,
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      unreadCount: state.unreadCount + 1,
    );
    await _service.saveMessage(message);
  }

  void _simulateBoipeloResponse(String userMessage) async {
    setBoipeloTyping(true);

    await Future.delayed(const Duration(milliseconds: 1500));

    setBoipeloTyping(false);

    String? response;
    final lower = userMessage.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      response = 'Hello! Welcome to Boipelo Chess. How can I help you today?';
    } else if (lower.contains('help') || lower.contains('?') || lower.contains('how')) {
      response = 'Feel free to ask me anything about the app. I am here to help!';
    } else if (lower.contains('thanks') || lower.contains('thank')) {
      response = 'You are welcome! Enjoy your games.';
    } else if (lower.contains('bug') || lower.contains('issue') || lower.contains('problem')) {
      response = 'Please describe the issue and I will look into it right away.';
    } else if (lower.contains('puzzle') || lower.contains('puzzles')) {
      response = 'Puzzles are a great way to improve! Try the Puzzle tab for daily puzzles.';
    } else if (lower.contains('engine') || lower.contains('stockfish')) {
      response = 'The engine analysis is available during games. Toggle it from the game screen.';
    } else if (lower.contains('bye') || lower.contains('goodbye')) {
      response = 'Goodbye! Checkmate soon!';
    } else {
      response = 'Thanks for your message! I will get back to you as soon as possible.';
    }

    await Future.delayed(const Duration(milliseconds: 500));
    await simulateIncomingMessage(response);
  }

  @override
  void dispose() {
    _typingTimeout?.cancel();
    super.dispose();
  }
}
