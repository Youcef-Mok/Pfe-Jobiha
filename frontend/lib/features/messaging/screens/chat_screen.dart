// lib/features/messaging/screens/chat_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/core/storage/token_storage.dart';
import 'package:job_app/features/messaging/data/models/chat_model.dart';
import 'package:job_app/features/messaging/data/providers/chat_provider.dart';

// ── Screen ────────────────────────────────────────────────────────────────────
class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final String displayName;
  final String? subtitle; // role for DMs, member count for groups
  final bool isGroup;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.displayName,
    this.subtitle,
    this.isGroup = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _currentUserId;
  Timer? _typingDebounce;
  bool _isTyping = false;
  bool _hasScrolledToBottom = false;

  late final ActiveChatNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(activeChatProvider(widget.conversationId).notifier);
    _loadCurrentUserId();
    _inputController.addListener(_onTextChanged);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notifier.onChatOpened();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 100) {
      _notifier.loadMore();
    }
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await TokenStorage.getUserId();
    if (mounted) {
      setState(() => _currentUserId = userId);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    _scrollController.dispose();
    _typingDebounce?.cancel();

    if (_isTyping) {
      _notifier.sendTypingStop();
    }

    _notifier.onChatClosed();
    super.dispose();
  }

  // ── Typing indicator logic ────────────────────────────────────────────────

  void _onTextChanged() {
    final text = _inputController.text.trim();

    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _notifier.sendTypingStart();
    }

    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        _notifier.sendTypingStop();
      }
    });

    if (text.isEmpty && _isTyping) {
      _isTyping = false;
      _typingDebounce?.cancel();
      _notifier.sendTypingStop();
    }
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (_isTyping) {
      _isTyping = false;
      _typingDebounce?.cancel();
      _notifier.sendTypingStop();
    }

    _notifier.sendMessage(text);
    _inputController.clear();
    _scrollToBottom(animate: true);
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(activeChatProvider(widget.conversationId));

    ref.listen<ActiveChatState>(activeChatProvider(widget.conversationId),
        (prev, next) {
      if (prev != null &&
          !prev.initialLoadDone &&
          next.initialLoadDone &&
          next.messages.isNotEmpty &&
          !_hasScrolledToBottom) {
        _hasScrolledToBottom = true;
        _scrollToBottom(animate: false);
        return;
      }

      if (prev != null && next.messages.length > prev.messages.length) {
        _scrollToBottom(animate: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(
              displayName: widget.displayName,
              subtitle: widget.subtitle,
              isGroup: widget.isGroup,
              isTyping: chatState.partnerIsTyping,
            ),
            const Divider(height: 1, color: AppColors.slate200),
            Expanded(child: _buildMessages(chatState)),
            if (chatState.partnerIsTyping)
              _TypingIndicator(isGroup: widget.isGroup),
            _InputBar(
              controller: _inputController,
              onSend: _sendMessage,
              isSending: chatState.isSending,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(ActiveChatState state) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.violet),
      );
    }

    if (state.error != null && state.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.slate400, size: 48),
              const SizedBox(height: 12),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _notifier.refresh(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline,
                color: AppColors.slate400, size: 48),
            const SizedBox(height: 12),
            Text('Aucun message', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Envoyez le premier message !',
              style: AppTextStyles.captionLight,
            ),
          ],
        ),
      );
    }

    final hasLoadingHeader = state.hasMore;
    final totalItems = state.messages.length + (hasLoadingHeader ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (hasLoadingHeader && index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.violet,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        }

        final msgIndex = hasLoadingHeader ? index - 1 : index;
        final msg = state.messages[msgIndex];
        final isMe =
            _currentUserId != null && msg.expediteur.id == _currentUserId;

        final showDate = msgIndex == 0 ||
            !_isSameDay(
              state.messages[msgIndex - 1].dateEnvoi,
              msg.dateEnvoi,
            );

        return Column(
          children: [
            if (showDate)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDateHeader(msg.dateEnvoi),
                      style:
                          AppTextStyles.captionLight.copyWith(fontSize: 11),
                    ),
                  ),
                ),
              ),
            _MessageBubble(
              message: msg,
              isMe: isMe,
              showSenderName: widget.isGroup && !isMe,
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return "Aujourd'hui";
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Hier';
    return DateFormat('dd MMMM yyyy').format(date);
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  final bool isGroup;

  const _TypingIndicator({this.isGroup = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 32, height: 16, child: _AnimatedDots()),
          const SizedBox(width: 8),
          Text(
            isGroup ? 'Quelqu\'un écrit…' : 'en train d\'écrire…',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (0.3 + 0.7 * (1.0 - (2.0 * t - 1.0).abs()));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Opacity(
                opacity: opacity.clamp(0.3, 1.0).toDouble(),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.violet,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _ChatHeader extends StatelessWidget {
  final String displayName;
  final String? subtitle;
  final bool isGroup;
  final bool isTyping;

  const _ChatHeader({
    required this.displayName,
    this.subtitle,
    this.isGroup = false,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = isGroup
        ? displayName.isNotEmpty ? displayName[0].toUpperCase() : 'G'
        : (() {
            final parts = displayName.split(' ');
            final first = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
            final last = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
            return '$first$last'.toUpperCase();
          })();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.slate900),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: isGroup ? AppColors.slate400 : AppColors.violet,
            child: isGroup
                ? const Icon(Icons.group, color: Colors.white, size: 20)
                : Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isTyping)
                  const Text(
                    'en train d\'écrire…',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.violet,
                    ),
                  )
                else if (subtitle != null)
                  Text(subtitle!, style: AppTextStyles.captionLight),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert,
                color: AppColors.slate400, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showSenderName;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.showSenderName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender name for group chats
          if (showSenderName)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Text(
                '${message.expediteur.prenom} ${message.expediteur.nom}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.violet,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) const SizedBox(width: 4),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.violet : AppColors.searchingBg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message.contenu,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isMe ? Colors.white : AppColors.slate900,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.Hm().format(message.dateEnvoi),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const _InputBar({
    required this.controller,
    required this.onSend,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.slate200, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file_outlined,
                color: AppColors.slate400, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.searchingBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.slate900,
                ),
                decoration: const InputDecoration(
                  hintText: 'Écrire un message…',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.slate400,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                maxLines: null,
                enabled: !isSending,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSending
                    ? AppColors.violet.withValues(alpha: 0.5)
                    : AppColors.violet,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}