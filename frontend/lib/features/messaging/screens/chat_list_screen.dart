import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/messaging/data/mock_conversations.dart';
import 'package:job_app/features/messaging/data/models/chat_model.dart';
import 'package:job_app/features/messaging/screens/chat_screen.dart';


class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinned = mockConversations.where((c) => c.isPinned).toList();
    final others = mockConversations.where((c) => !c.isPinned).toList();

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

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                children: [
                  // Pinned
                  ...pinned.map((c) => _ConversationTile(conversation: c)),
                  // Divider between pinned and others
                  if (pinned.isNotEmpty && others.isNotEmpty)
                    const Divider(height: 1, color: AppColors.slate200),
                  // Others
                  ...others.map((c) => _ConversationTile(conversation: c)),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: AppColors.violet.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 8),
              spreadRadius: -6,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          elevation: 0,
          child: const Icon(Icons.add, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom Nav Bar ────────────────────────────────────────────────
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

// ── Bottom Nav Bar ────────────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 89,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(icon: Icons.home_outlined, label: 'Home', isActive: false),
          _NavItem(icon: Icons.notifications_none_outlined, label: 'Notif', isActive: false),
          const SizedBox(width: 56),
          _NavItem(icon: Icons.chat_bubble_outline, label: 'mess', isActive: true),
          _NavItem(icon: Icons.person_outline, label: 'Profil', isActive: false),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.violet : AppColors.slate400;
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Conversation Tile ─────────────────────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('TAPPED: ${conversation.id}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(conversationId: conversation.id),
          ),
        );
      },
      child: Container(
        color: conversation.isPinned
            ? const Color(0xFFF8F3FE)
            : AppColors.surface,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _Avatar(conversation: conversation),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              conversation.contactName,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.slate900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (conversation.contactTag != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.searchingBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  conversation.contactTag!,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    color: AppColors.violet,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              conversation.lastMessageTime,
                              style: AppTextStyles.captionLight,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                conversation.lastMessage,
                                style: AppTextStyles.captionLight,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (conversation.isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.violet,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (conversation.isPinned) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right,
                        color: AppColors.slate400, size: 18),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.slate200),
          ],
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final ConversationModel conversation;

  const _Avatar({required this.conversation});

  @override
  Widget build(BuildContext context) {
    if (conversation.avatarUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(conversation.avatarUrl!),
      );
    }

    if (conversation.contactName.contains('Team')) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.searchingBg,
        child: const Icon(Icons.group, color: AppColors.violet, size: 24),
      );
    }

    final initials = conversation.contactName
        .split(' ')
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();

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