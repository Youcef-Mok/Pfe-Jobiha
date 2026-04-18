import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/messaging/data/models/chat_model.dart';
import 'package:job_app/features/messaging/data/mock_conversations.dart';

// ── Mock messages per conversation ───────────────────────────────────────────
final Map<String, List<MessageModel>> mockMessages = {
  '1': [
    MessageModel(id: 'm1', conversationId: '1', senderId: 'them', content: 'Bonjour ! Votre candidature nous intéresse.', sentAt: '10:00', isMe: false),
    MessageModel(id: 'm2', conversationId: '1', senderId: 'me', content: 'Merci beaucoup, je suis disponible cette semaine.', sentAt: '10:02', isMe: true),
    MessageModel(id: 'm3', conversationId: '1', senderId: 'them', content: 'Parfait, on vous recontacte demain.', sentAt: '10:05', isMe: false),
  ],
  '2': [
    MessageModel(id: 'm1', conversationId: '2', senderId: 'them', content: "Hi! We'd like to schedule an interview for the Frontend role.", sentAt: '9:30', isMe: false),
    MessageModel(id: 'm2', conversationId: '2', senderId: 'me', content: "That sounds great! I'm available Monday or Tuesday.", sentAt: '9:45', isMe: true),
    MessageModel(id: 'm3', conversationId: '2', senderId: 'them', content: "Let's do Monday at 2 PM. I'll send a calendar invite.", sentAt: '9:50', isMe: false),
    MessageModel(id: 'm4', conversationId: '2', senderId: 'me', content: 'Perfect, looking forward to it!', sentAt: '9:51', isMe: true),
  ],
  '3': [
    MessageModel(id: 'm1', conversationId: '3', senderId: 'me', content: "Hey Marcus, check out this opening at Stripe — think you'd be a great fit.", sentAt: 'Yesterday', isMe: true),
    MessageModel(id: 'm2', conversationId: '3', senderId: 'them', content: "Thanks for the referral! I'll check out the posting tonight.", sentAt: 'Yesterday', isMe: false),
  ],
  '4': [
    MessageModel(id: 'm1', conversationId: '4', senderId: 'them', content: 'The portfolio you shared is impressive. Really love the motion work.', sentAt: '3h', isMe: false),
    MessageModel(id: 'm2', conversationId: '4', senderId: 'me', content: 'Thank you Elena! That means a lot coming from you.', sentAt: '3h', isMe: true),
  ],
};

MessageModel _fallback(String convId) => MessageModel(
      id: 'placeholder',
      conversationId: convId,
      senderId: 'them',
      content: 'No messages yet. Say hello!',
      sentAt: '',
      isMe: false,
    );

// ── Screen ────────────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late ConversationModel _conversation;
  late List<MessageModel> _messages;

  @override
  void initState() {
    super.initState();
    _conversation = mockConversations.firstWhere(
      (c) => c.id == widget.conversationId,
    );
    _messages = List.from(
      mockMessages[widget.conversationId] ?? [_fallback(widget.conversationId)],
    );
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

    setState(() {
      _messages.add(MessageModel(
        id: 'new_${_messages.length}',
        conversationId: widget.conversationId,
        senderId: 'me',
        content: text,
        sentAt: 'Now',
        isMe: true,
      ));
      _inputController.clear();
    });

    // Scroll to bottom after frame
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(conversation: _conversation),
            const Divider(height: 1, color: AppColors.slate200),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final showTime = index == 0 ||
                      _messages[index - 1].sentAt != msg.sentAt;
                  return _MessageBubble(
                    message: msg,
                    showTime: showTime,
                  );
                },
              ),
            ),
            _InputBar(
              controller: _inputController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _ChatHeader extends StatelessWidget {
  final ConversationModel conversation;

  const _ChatHeader({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final initials = conversation.contactName
        .split(' ')
        .take(2)
        .map((w) => w[0])
        .join()
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

          // Name + tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.contactName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (conversation.contactTag != null)
                  Text(
                    conversation.contactTag!,
                    style: AppTextStyles.captionLight,
                  ),
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.slate400, size: 20),
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
  final bool showTime;

  const _MessageBubble({required this.message, required this.showTime});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Timestamp
          if (showTime && message.sentAt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Center(
                child: Text(
                  message.sentAt,
                  style: AppTextStyles.captionLight.copyWith(fontSize: 11),
                ),
              ),
            ),

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
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isMe ? Colors.white : AppColors.slate900,
                      height: 1.4,
                    ),
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

  const _InputBar({required this.controller, required this.onSend});

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
                  hintText: 'Type a message…',
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
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.violet,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}