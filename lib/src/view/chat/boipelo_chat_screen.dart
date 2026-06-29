import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lichess_mobile/src/model/chat/boipelo_chat_controller.dart';
import 'package:lichess_mobile/src/model/chat/boipelo_chat_model.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/widgets/platform.dart';

class BoipeloChatScreen extends ConsumerStatefulWidget {
  const BoipeloChatScreen({super.key});

  static Route<dynamic> buildRoute() {
    return buildScreenRoute(screen: const BoipeloChatScreen());
  }

  @override
  ConsumerState<BoipeloChatScreen> createState() => _BoipeloChatScreenState();
}

class _BoipeloChatScreenState extends ConsumerState<BoipeloChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(boipeloChatControllerProvider.notifier).markAllAsRead();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;
    _isSending = true;
    ref.read(boipeloChatControllerProvider.notifier).sendMessage(text);
    _textController.clear();
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 100), () {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(boipeloChatControllerProvider);

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.train, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Boipelo',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(state),
          ),
          if (state.boipeloIsTyping)
            _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.train, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Chat with Boipelo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to start the conversation',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BoipeloChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final msg = state.messages[index];
        final isMe = msg.senderId == 'user';
        final showDate = index == 0 ||
            !_isSameDay(state.messages[index - 1].timestamp, msg.timestamp);
        final isLastInGroup = index == state.messages.length - 1 ||
            state.messages[index + 1].senderId != msg.senderId;

        return Column(
          children: [
            if (showDate) _buildDateSeparator(msg.timestamp),
            _buildMessageBubble(msg, isMe, isLastInGroup),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);
    String label;
    if (msgDate.isAtSameMomentAs(today)) {
      label = context.l10n.today;
    } else if (msgDate
        .isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      label = context.l10n.yesterday;
    } else {
      label = DateFormat.yMMMd().format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BoipeloChatMessage msg, bool isMe, bool isLastInGroup) {
    final time = DateFormat.Hm().format(msg.timestamp);
    final bubbleColor = isMe
        ? const Color(0xFF1A237E)
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isMe
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLastInGroup ? 6 : 2,
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe
                    ? const Radius.circular(18)
                    : (isLastInGroup
                    ? const Radius.circular(4)
                    : const Radius.circular(18)),
                bottomRight: isMe
                    ? (isLastInGroup
                    ? const Radius.circular(4)
                    : const Radius.circular(18))
                    : const Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        msg.status == MessageStatus.sending
                            ? Icons.access_time
                            : msg.status == MessageStatus.sent
                            ? Icons.check
                            : msg.status == MessageStatus.delivered
                            ? Icons.done_all
                            : Icons.done_all,
                        size: 14,
                        color: msg.status == MessageStatus.read
                            ? const Color(0xFF4FC3F7)
                            : textColor.withValues(alpha: 0.6),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.train, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 3.0 : 0),
                    child: _TypingDot(delay: i * 200),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.12),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _sendMessage,
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
