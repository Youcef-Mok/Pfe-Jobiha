// lib/features/messaging/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/core/storage/token_storage.dart';
import 'package:job_app/features/messaging/data/models/chat_model.dart';
import 'package:job_app/features/messaging/data/providers/chat_provider.dart';

// ── Screen ────────────────────────────────────────────────────────────────────
class ChatScreen extends ConsumerStatefulWidget {
  final int partnerId;
  final String partnerNom;
  final String partnerPrenom;
  final String? partnerRole;

  const ChatScreen({
    super.key,
    required this.partnerId,
    required this.partnerNom,
    required this.partnerPrenom,
    this.partnerRole,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Load current user ID for determining message ownership
    _loadCurrentUserId();
    // Start polling for new messages
    Future.microtask(() {
      ref.read(activeChatProvider(widget.partnerId).notifier).startPolling();
    });
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await TokenStorage.getUserId();
    if (mounted) {
      setState(() => _currentUserId = userId);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    ref.read(activeChatProvider(widget.partnerId).notifier).sendMessage(text);
    _inputController.clear();

    // Scroll to bottom after send
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(activeChatProvider(widget.partnerId));

    // Auto-scroll when new messages arrive
    ref.listen<ActiveChatState>(activeChatProvider(widget.partnerId),
        (prev, next) {
      if (prev != null &&
          next.messages.length > prev.messages.length &&
          _scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(
              partnerNom: widget.partnerNom,
              partnerPrenom: widget.partnerPrenom,
              partnerRole: widget.partnerRole,
            ),
            const Divider(height: 1, color: AppColors.slate200),
            Expanded(child: _buildMessages(chatState)),
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
    // Loading
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.violet),
      );
    }

    // Error
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
                onPressed: () => ref
                    .read(activeChatProvider(widget.partnerId).notifier)
                    .refresh(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, color: AppColors.slate400, size: 48),
            const SizedBox(height: 12),
            Text(
              'Aucun message',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Envoyez le premier message !',
              style: AppTextStyles.captionLight,
            ),
          ],
        ),
      );
    }

    // Messages
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final msg = state.messages[index];
        final isMe = _currentUserId != null &&
            msg.expediteur.id == _currentUserId;

        // Show date separator
        final showDate = index == 0 ||
            !_isSameDay(
              state.messages[index - 1].dateEnvoi,
              msg.dateEnvoi,
            );

        return Column(
          children: [
            if (showDate)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDateHeader(msg.dateEnvoi),
                      style: AppTextStyles.captionLight.copyWith(fontSize: 11),
                    ),
                  ),
                ),
              ),
            _MessageBubble(message: msg, isMe: isMe),
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

// ── Header ────────────────────────────────────────────────────────────────────
class _ChatHeader extends StatelessWidget {
  final String partnerNom;
  final String partnerPrenom;
  final String? partnerRole;

  const _ChatHeader({
    required this.partnerNom,
    required this.partnerPrenom,
    this.partnerRole,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = '$partnerPrenom $partnerNom';
    final initials =
        '${partnerPrenom.isNotEmpty ? partnerPrenom[0] : ''}${partnerNom.isNotEmpty ? partnerNom[0] : ''}'
            .toUpperCase();

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

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.violet,
            child: Text(
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

          // Name + role
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
                if (partnerRole != null)
                  Text(
                    partnerRole!,
                    style: AppTextStyles.captionLight,
                  ),
              ],
            ),
          ),

          // Actions
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

// ── Message Bubble ─────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Bubble
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.estLu
                                  ? Icons.done_all
                                  : Icons.done,
                              size: 14,
                              color: message.estLu
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ],
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
          // Attachment
          IconButton(
            icon: const Icon(Icons.attach_file_outlined,
                color: AppColors.slate400, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),

          // Text field
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

          // Send button
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