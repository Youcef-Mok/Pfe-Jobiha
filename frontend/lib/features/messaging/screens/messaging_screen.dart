import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/core/widgets/app_bottom_nav_bar.dart';
import 'package:job_app/core/widgets/candidate_nav_bar.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/core/storage/token_storage.dart';
import 'package:job_app/features/messaging/data/providers/messaging_provider.dart';
import 'package:job_app/features/messaging/domain/message_entity.dart';
import 'package:job_app/features/messaging/screens/new_message_screen.dart';
import 'package:job_app/features/messaging/screens/private_message_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  final bool isRecruiterView;

  const MessagingScreen({super.key, this.isRecruiterView = false});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  bool _deleteMode = false;
  final Set<String> _selectedIds = {};
  WebSocketChannel? _listenerChannel;

  @override
  void initState() {
    super.initState();
    _connectGlobalListener();
  }

  void _connectGlobalListener() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        print('[MessagingScreen] No token available for WebSocket connection');
        return;
      }

      final wsUrl = '${ApiEndpoints.wsBase}/ws/notifications/?token=$token';
      print('[MessagingScreen] Connecting to notifications WebSocket: $wsUrl');
      
      _listenerChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _listenerChannel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data);
            print('[MessagingScreen] Notification received: $decoded');
            
            if (decoded['type'] == 'new_message') {
              // Refresh conversation list when a new message arrives
              if (mounted) {
                ref.read(messagingControllerProvider.notifier).refreshConversations();
              }
            }
          } catch (e) {
            print('[MessagingScreen] Error parsing notification: $e');
          }
        },
        onError: (error) {
          print('[MessagingScreen] WebSocket error: $error');
        },
        onDone: () {
          print('[MessagingScreen] WebSocket connection closed');
        },
      );
    } catch (e) {
      print('[MessagingScreen] Failed to connect to notifications WebSocket: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh conversations when screen comes back into focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagingControllerProvider.notifier).refreshConversations();
    });
  }

  @override
  void dispose() {
    _listenerChannel?.sink.close();
    super.dispose();
  }

  void _toggleDeleteMode() {
    if (_deleteMode && _selectedIds.isNotEmpty) {
      _confirmDelete();
      return;
    }
    setState(() {
      _deleteMode = !_deleteMode;
      _selectedIds.clear();
    });
  }

  void _cancelDeleteMode() {
    setState(() {
      _deleteMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _confirmDelete() async {
    await ref
        .read(messagingControllerProvider.notifier)
        .deleteConversations(_selectedIds.toList());
    setState(() {
      _deleteMode = false;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagingControllerProvider);
    final ctrl = ref.read(messagingControllerProvider.notifier);
    
    print('[MessagingScreen] Building with ${state.conversations.length} conversations');
    for (final c in state.conversations) {
      print('[MessagingScreen] Conv: id=${c.id} isGroup=${c.isGroup} name="${c.contactName}" groupName="${c.groupName}"');
    }
    
    final list = (state.activeTab == 'messages'
            ? state.conversations
            : state.invitations)
        .where((c) => !state.blockedIds.contains(c.id))
        .toList();
    
    print('[MessagingScreen] After filter: ${list.length} conversations to display');
    for (final c in list) {
      print('[MessagingScreen] Display: id=${c.id} isGroup=${c.isGroup} name="${c.contactName}"');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF401E66)),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'messages',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              letterSpacing: -0.6,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NewMessageScreen(),
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 22,
                              color: Color(0xFF401E66),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const NewMessageScreen(initialSearchMode: true),
                          ),
                        ),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFEDF2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 15),
                              Icon(Icons.search,
                                  size: 18, color: Color(0xFF64748B)),
                              SizedBox(width: 8),
                              Text(
                                'rechercher contacts ou messages',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _TabButton(
                            label: 'message',
                            icon: Icons.edit_outlined,
                            isActive: state.activeTab == 'messages',
                            onTap: () => ctrl.setTab('messages'),
                          ),
                          const SizedBox(width: 8),
                          _TabButton(
                            label: 'invitation',
                            icon: Icons.mail_outline,
                            isActive: state.activeTab == 'invitations',
                            onTap: () => ctrl.setTab('invitations'),
                          ),
                          const Spacer(),
                          if (_deleteMode) ...[
                            GestureDetector(
                              onTap: _cancelDeleteMode,
                              child: const Text(
                                'annuler',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          GestureDetector(
                            onTap: _toggleDeleteMode,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              constraints: BoxConstraints(
                                minWidth: 48,
                                maxWidth: _deleteMode && _selectedIds.isNotEmpty ? 200 : 48,
                              ),
                              height: 32,
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    _deleteMode && _selectedIds.isNotEmpty
                                        ? 12
                                        : 0,
                              ),
                              decoration: BoxDecoration(
                                color: _deleteMode
                                    ? (_selectedIds.isNotEmpty
                                        ? const Color(0xFFFFE4E6)
                                        : const Color(0xFFEFEDF2))
                                    : const Color(0xFFEFEDF2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: _deleteMode && _selectedIds.isNotEmpty
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.delete,
                                            size: 16,
                                            color: Color(0xFFBE123C)),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'supprimer (${_selectedIds.length})',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: Color(0xFFBE123C),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: Color(0xFF401E66),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: List.generate(list.length, (i) {
                          try {
                            final conv = list[i];
                            return _ConversationItem(
                              conversation: conv,
                              isInvitationTab: state.activeTab == 'invitations',
                              deleteMode: _deleteMode,
                              isSelected: _selectedIds.contains(conv.id),
                              showTopBorder: i != 0,
                              onToggleSelect: () => _toggleSelect(conv.id),
                              onTap: _deleteMode
                                  ? () => _toggleSelect(conv.id)
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PrivateMessageScreen(
                                            conversation: conv,
                                          ),
                                        ),
                                      ),
                              onAccept: () => ctrl.acceptInvitation(conv.id),
                            );
                          } catch (e, stack) {
                            debugPrint('CONV ITEM CRASH: $e');
                            debugPrint(stack.toString());
                            return const SizedBox.shrink();
                          }
                        }),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
      bottomNavigationBar: widget.isRecruiterView
          ? const AppBottomNavBar(currentIndex: 2)
          : const CandidateNavBar(currentIndex: 2),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF401E66) : const Color(0xFFEFEDF2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : AppColors.violet),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isActive ? Colors.white : AppColors.violet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final ConversationEntity conversation;
  final bool isInvitationTab;
  final bool deleteMode;
  final bool isSelected;
  final bool showTopBorder;
  final VoidCallback onToggleSelect;
  final VoidCallback onTap;
  final VoidCallback onAccept;

  const _ConversationItem({
    required this.conversation,
    required this.isInvitationTab,
    required this.deleteMode,
    required this.isSelected,
    required this.showTopBorder,
    required this.onToggleSelect,
    required this.onTap,
    required this.onAccept,
  });

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    if (msgDay == today) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return DateFormat('d MMM', 'fr_FR').format(dt);
  }

  String _formatLastMessage(String? msg) {
    if (msg == null || msg.isEmpty) return '';
    try {
      if (msg.startsWith('http') || msg.startsWith('https')) {
        final lower = msg.toLowerCase().split('?').first; // strip query params
        if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || 
            lower.endsWith('.png') || lower.endsWith('.webp') || 
            lower.endsWith('.gif')) {
          return '📷 Image';
        }
        return '📎 Fichier';
      }
      return msg;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: showTopBorder
              ? const Border(top: BorderSide(color: Color(0xFFEEEBF4)))
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 45,
              child: c.isGroup
                  ? _StackedAvatars(avatars: c.memberAvatars)
                  : Stack(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEFEDF2),
                            image: c.contactAvatar != null
                                ? DecorationImage(
                                    image: AssetImage(c.contactAvatar!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: c.contactAvatar == null
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 24)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: c.isOnline
                                  ? const Color(0xFF401E66)
                                  : const Color(0xFFCBD5E1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFF7F5F8),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: c.contactName,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (c.contactRole.isNotEmpty)
                                TextSpan(
                                  text: ' ${c.contactRole}',
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (deleteMode)
                        _CircleCheckbox(checked: isSelected)
                      else
                        Text(
                          _formatTime(c.lastMessageTime),
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatLastMessage(c.lastMessage),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight:
                                c.isUnread ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 14,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (!deleteMode) ...[
                        const SizedBox(width: 8),
                        if (isInvitationTab)
                          Flexible(
                            child: GestureDetector(
                              onTap: onAccept,
                              child: const Text(
                                'accepter',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(0xFF401E66),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        else if (c.unreadCount > 0 || c.isUnread)
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFF401E66),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              c.unreadCount > 0
                                  ? (c.unreadCount > 99 ? '99+' : '${c.unreadCount}')
                                  : '1',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: Colors.white,
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
    );
  }
}

class _CircleCheckbox extends StatelessWidget {
  final bool checked;
  const _CircleCheckbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? const Color(0xFF401E66) : Colors.transparent,
        border: Border.all(
          color: checked ? const Color(0xFF401E66) : const Color(0xFFCBD5E1),
          width: 2,
        ),
      ),
      child:
          checked ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
    );
  }
}

// Stacked overlapping avatars for group conversations
class _StackedAvatars extends StatelessWidget {
  final List<String> avatars;
  const _StackedAvatars({required this.avatars});

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    const overlap = 12.0;
    final shown = avatars.take(3).toList();

    return SizedBox(
      width: size + (shown.length - 1) * (size - overlap),
      height: 45,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: shown.asMap().entries.map((e) {
          final i = e.key;
          final avatar = e.value;
          return Positioned(
            left: i * (size - overlap),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEFEDF2),
                border: Border.all(color: Colors.white, width: 2),
                image: DecorationImage(
                  image: AssetImage(avatar),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

