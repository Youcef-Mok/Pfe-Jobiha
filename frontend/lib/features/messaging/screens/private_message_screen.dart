import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/messaging/data/providers/messaging_provider.dart';
import 'package:job_app/features/messaging/domain/message_entity.dart';
import 'package:job_app/features/messaging/widgets/invitation_accept_sheet.dart';
import 'package:job_app/features/messaging/widgets/message_actions_sheet.dart';
import 'package:job_app/features/messaging/screens/report_screen.dart';
import 'package:job_app/features/messaging/widgets/more_options_sheet.dart';

class PrivateMessageScreen extends ConsumerStatefulWidget {
  final ConversationEntity conversation;

  const PrivateMessageScreen({super.key, required this.conversation});

  @override
  ConsumerState<PrivateMessageScreen> createState() =>
      _PrivateMessageScreenState();
}

class _PrivateMessageScreenState extends ConsumerState<PrivateMessageScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocusNode = FocusNode();
  bool _bannerVisible = false;
  MessageEntity? _replyingTo;
  Timer? _bannerTimer;
  List<MessageEntity> _messages = [];
  bool _loadingMessages = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    if (widget.conversation.isInvitation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showInvitationSheet();
      });
    }
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() => _loadingMessages = true);
    try {
      final repo = ref.read(messagingRepositoryProvider);
      final conv = await repo.getConversationById(widget.conversation.id);
      if (mounted) {
        setState(() {
          _messages = conv.messages;
          _loadingMessages = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMessages = false);
    }
  }

  void _showInvitationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => InvitationAcceptSheet(
        contactName: widget.conversation.contactName,
        contactRole: widget.conversation.contactRole,
        contactAvatar: widget.conversation.contactAvatar,
        onAccept: () {
          Navigator.pop(context);
          ref
              .read(messagingControllerProvider.notifier)
              .acceptInvitation(widget.conversation.id);
          Navigator.pop(context);
        },
        onDecline: () {
          Navigator.pop(context);
          ref
              .read(messagingControllerProvider.notifier)
              .declineInvitation(widget.conversation.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Ajouter le message localement immédiatement
    final tempMsg = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      content: text,
      timestamp: DateTime.now(),
      isRead: false,
      isMine: true,
      type: MessageType.text,
    );
    setState(() {
      _messages = [..._messages, tempMsg];
      _replyingTo = null;
    });
    _controller.clear();

    // Envoyer au backend
    ref.read(messagingControllerProvider.notifier)
        .sendMessage(widget.conversation.id, text);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showMoreOptions() {
    final role = widget.conversation.contactRole;
    final isRecruiter = role.contains('Recruteur') ||
        role.contains('@') ||
        role.contains('RH') ||
        role.contains('Manager') ||
        role.contains('Responsable');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MoreOptionsSheet(
        isRecruiter: isRecruiter,
        onBlock: () {
          ref
              .read(messagingControllerProvider.notifier)
              .blockContact(widget.conversation.id);
          setState(() => _bannerVisible = true);
          _bannerTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) Navigator.pop(context);
          });
        },
        onRestrict: () {
          ref
              .read(messagingControllerProvider.notifier)
              .restrictContact(widget.conversation.id);
          setState(() => _bannerVisible = true);
          _bannerTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) setState(() => _bannerVisible = false);
          });
        },
        onReport: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportScreen(
              contactName: widget.conversation.contactName,
              isRecruiter: isRecruiter,
            ),
          ),
        ),
      ),
    );
  }

  void _showAttachmentOverlay() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => Stack(
        children: [
          _AttachmentOverlay(
            bottomOffset: 76 + MediaQuery.of(context).padding.bottom,
            onGallery: () async {
              Navigator.pop(ctx);
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                // Envoyer l'image dans la discussion
                ref
                    .read(messagingControllerProvider.notifier)
                    .sendImageMessage(widget.conversation.id, image.path);
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            },
            onFile: () async {
              Navigator.pop(ctx);
              final result = await FilePicker.platform.pickFiles();
              if (result != null && result.files.single.path != null) {
                // Envoyer le fichier dans la discussion
                ref
                    .read(messagingControllerProvider.notifier)
                    .sendFileMessage(widget.conversation.id, result.files.single.path!);
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagingControllerProvider);
    final conv = state.conversations.firstWhere(
      (c) => c.id == widget.conversation.id,
      orElse: () => widget.conversation,
    );
    final isBlocked =
        state.blockedIds.contains(conv.id) && _bannerVisible;
    final isRestricted =
        state.restrictedIds.contains(conv.id) && _bannerVisible;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7))),
              boxShadow: [
                BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 2,
                    offset: Offset(0, 1)),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_back,
                            size: 20, color: Color(0xFF71717A)),
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE2E8F0),
                            image: conv.contactAvatar != null
                                ? DecorationImage(
                                    image: AssetImage(conv.contactAvatar!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: conv.isOnline
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFCBD5E1),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conv.contactName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF18181B),
                            ),
                          ),
                          Text(
                            conv.isOnline ? 'en ligne' : 'hors ligne',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: conv.isOnline
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _showMoreOptions,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.more_vert,
                            size: 22, color: Color(0xFF71717A)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE6ED),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text(
                      "aujourd'hui",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: Color(0xFF4A454F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_loadingMessages)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ..._messages.map((msg) => _messageBubble(
                        message: msg,
                        avatarAsset: conv.contactAvatar,
                        onReply: () {
                          setState(() => _replyingTo = msg);
                          _inputFocusNode.requestFocus();
                        },
                      )),
              ],
            ),
          ),

          // Footer
          if (isBlocked)
            _StatusBanner(
              icon: Icons.block,
              iconColor: const Color(0xFFBE123C),
              bgColor: const Color(0xFFFFF1F2),
              borderColor: const Color(0xFFFFCDD2),
              title: 'Compte bloqué',
              titleColor: const Color(0xFF9F1239),
              message:
                  'Vous ne pouvez plus échanger de messages avec cette personne. '
                  'Pour débloquer, allez dans comptes bloqués.',
              messageColor: const Color(0xFFBE123C),
            )
          else if (isRestricted)
            _StatusBanner(
              icon: Icons.visibility_off_outlined,
              iconColor: const Color(0xFFB45309),
              bgColor: const Color(0xFFFFF8E7),
              borderColor: const Color(0xFFFFECB3),
              title: 'Compte restreint',
              titleColor: const Color(0xFF92400E),
              message:
                  'Cette personne ne verra plus vos publications et messages. '
                  'Gérez cela dans vos paramètres.',
              messageColor: const Color(0xFFB45309),
            )
          else
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFCCC3D0))),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                10 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reply preview
                  if (_replyingTo != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 25, 8, 25),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EBF8),
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            left: BorderSide(
                                color: Color(0xFF401E66), width: 3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _replyingTo!.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Color(0xFF401E66),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _replyingTo = null),
                              child: const Icon(Icons.close,
                                  size: 16, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Input row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: GestureDetector(
                          onTap: _showAttachmentOverlay,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: const Icon(
                              Icons.add_circle_outline,
                              size: 28,
                              color: Color(0xFF401E66),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 128),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _inputFocusNode,
                            maxLines: null,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF1D1B1F),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'écrivez votre message...',
                              hintStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF7C7580),
                              ),
                              contentPadding:
                                  EdgeInsets.fromLTRB(16, 12, 16, 12),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (_, val, __) {
                          if (val.text.trim().isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 8, bottom: 4),
                            child: GestureDetector(
                              onTap: _send,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF401E66),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.send,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Attachment overlay ──────────────────────────────────────────────────────
class _AttachmentOverlay extends StatelessWidget {
  final double bottomOffset;
  final VoidCallback onGallery;
  final VoidCallback onFile;

  const _AttachmentOverlay({
    required this.bottomOffset,
    required this.onGallery,
    required this.onFile,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: bottomOffset + 8,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 138,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEDF2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 50,
                offset: Offset(0, 25),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AttachRow(
                icon: Icons.photo_library_outlined,
                label: 'Galerie',
                onTap: onGallery,
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: const Color(0xFFF4F4F5),
              ),
              _AttachRow(
                icon: Icons.insert_drive_file_outlined,
                label: 'Fichier',
                onTap: onFile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFE8E1F4),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 15, color: const Color(0xFF401E66)),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF401E66),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status banner ───────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String title;
  final Color titleColor;
  final String message;
  final Color messageColor;

  const _StatusBanner({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.title,
    required this.titleColor,
    required this.message,
    required this.messageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: messageColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Message bubble ──────────────────────────────────────────────────────────
class _messageBubble extends StatelessWidget {
  final MessageEntity message;
  final String? avatarAsset;
  final VoidCallback? onReply;

  const _messageBubble({
    required this.message,
    this.avatarAsset,
    this.onReply,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          messageActionsSheet(message: message, onReply: onReply),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMine) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE2E8F0),
                  image: avatarAsset != null
                      ? DecorationImage(
                          image: AssetImage(avatarAsset!),
                          fit: BoxFit.cover)
                      : null,
                ),
              ),
            ),
          ],
          Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: () => _showActions(context),
                child: message.type == MessageType.image
                    ? Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.68,
                          maxHeight: 200,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(message.content),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMine
                                      ? const Color(0xFF401E66)
                                      : const Color(0xFFF6F3F8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      color: isMine ? Colors.white : const Color(0xFF401E66),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '📷 Image',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: isMine
                                            ? Colors.white
                                            : const Color(0xFF1D1B1F),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : message.type == MessageType.file
                        ? Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.68,
                            ),
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            decoration: BoxDecoration(
                              color: isMine
                                  ? const Color(0xFF401E66)
                                  : const Color(0xFFF6F3F8),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x0D000000),
                                    blurRadius: 2,
                                    offset: Offset(0, 1)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.insert_drive_file,
                                  color: isMine ? Colors.white : const Color(0xFF401E66),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    message.content.split('/').last,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: isMine
                                          ? Colors.white
                                          : const Color(0xFF1D1B1F),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.68,
                            ),
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            decoration: BoxDecoration(
                              color: isMine
                                  ? const Color(0xFF401E66)
                                  : const Color(0xFFF6F3F8),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft:
                                    isMine ? const Radius.circular(12) : Radius.zero,
                                bottomRight:
                                    isMine ? Radius.zero : const Radius.circular(12),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x0D000000),
                                    blurRadius: 2,
                                    offset: Offset(0, 1)),
                              ],
                            ),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 23 / 14,
                                color: isMine
                                    ? Colors.white
                                    : const Color(0xFF1D1B1F),
                              ),
                            ),
                          ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: Color(0xFF7C7580),
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all,
                        size: 12, color: Color(0xFF401E66)),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
