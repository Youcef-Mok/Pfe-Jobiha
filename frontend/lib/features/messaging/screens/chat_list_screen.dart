// lib/features/messaging/screens/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/messaging/data/models/chat_model.dart';
import 'package:job_app/features/messaging/data/providers/chat_provider.dart';
import 'package:job_app/features/messaging/screens/chat_screen.dart';


class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Start polling when screen is visible
    Future.microtask(() {
      ref.read(conversationListProvider.notifier).startPolling();
    });
  }

  @override
  void dispose() {
    // Defensive: stop polling when leaving screen.
    // We can't use ref here after dispose, so the notifier's own dispose
    // handles cleanup if the provider is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.slate900),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text('Messages', style: AppTextStyles.heading1),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ConversationListState state) {
    // Loading (first load only)
    if (state.isLoading && state.conversations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.violet),
      );
    }

    // Error
    if (state.error != null && state.conversations.isEmpty) {
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
                onPressed: () =>
                    ref.read(conversationListProvider.notifier).loadConversations(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (state.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, color: AppColors.slate400, size: 48),
            const SizedBox(height: 12),
            Text(
              'Aucune conversation',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Vos messages apparaîtront ici',
              style: AppTextStyles.captionLight,
            ),
          ],
        ),
      );
    }

    // Conversation list
    return RefreshIndicator(
      color: AppColors.violet,
      onRefresh: () =>
          ref.read(conversationListProvider.notifier).loadConversations(),
      child: ListView.builder(
        itemCount: state.conversations.length,
        itemBuilder: (context, index) {
          final conv = state.conversations[index];
          return _ConversationTile(
            conversation: conv,
            onTap: () => _openChat(conv),
          );
        },
      ),
    );
  }

  void _openChat(ConversationModel conv) {
    // Stop list polling while in chat
    ref.read(conversationListProvider.notifier).stopPolling();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          partnerId: conv.interlocuteur.id,
          partnerNom: conv.interlocuteur.nom,
          partnerPrenom: conv.interlocuteur.prenom,
          partnerRole: conv.interlocuteur.role,
        ),
      ),
    ).then((_) {
      // Resume list polling + refresh when coming back
      ref.read(conversationListProvider.notifier)
        ..loadConversations()
        ..startPolling();
    });
  }
}

// ── Conversation Tile ─────────────────────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final entity = conversation.toEntity();
    final hasUnread = entity.hasUnread;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.surface,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _Avatar(
                    initials: entity.contactInitials,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      entity.contactDisplayName,
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: AppColors.slate900,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (entity.interlocuteurRole != null) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.searchingBg,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        entity.interlocuteurRole!,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10,
                                          color: AppColors.violet,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(entity.dernierMessage.dateEnvoi),
                              style: AppTextStyles.captionLight,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entity.dernierMessage.contenu,
                                style: AppTextStyles.captionLight,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.violet,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${entity.nbNonLus}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.slate200),
          ],
        ),
      ),
    );
  }

  /// Format the date for conversation tiles.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Maintenant';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return DateFormat.E('fr_FR').format(date);
    return DateFormat('dd/MM').format(date);
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String initials;

  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.violet,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}