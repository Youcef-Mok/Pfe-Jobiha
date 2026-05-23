import 'package:job_app/features/messaging/data/models/chat_model.dart';
import 'package:job_app/features/messaging/data/repositories/messaging_repository.dart';
import 'package:job_app/features/messaging/domain/message_entity.dart';

// TODO(API): Remplacer par MessagingRepositoryHttp dans messaging_provider.dart.
class MessagingRepositoryMock implements MessagingRepository {
  static final Set<String> _blockedIds = {};
  static final Set<String> _restrictedIds = {};

  static final List<ConversationModel> _conversations = [
    ConversationModel(
      id: 'c1',
      contactName: 'Sarah Jenkins',
      contactRole: '· HR @TechCorp',
      contactAvatar: 'assets/images/pdp_1.png',
      isOnline: true,
      lastMessage: "Nous aimerions planifier un entretien...",
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      isUnread: true,
      messages: [
        MessageModel(
          id: 'm1',
          senderId: 'sarah',
          content: 'Bonjour Lucas, disponible pour un entretien demain ?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 48)),
          isRead: true,
          isMine: false,
        ),
        MessageModel(
          id: 'm2',
          senderId: 'me',
          content: 'Oui, demain vers 10h me convient.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
          isRead: true,
          isMine: true,
        ),
        MessageModel(
          id: 'm3',
          senderId: 'sarah',
          content: 'Parfait, rendez-vous confirme.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 5)),
          isRead: true,
          isMine: false,
        ),
      ],
    ),
    ConversationModel(
      id: 'c2',
      contactName: 'Marcus Chen',
      contactRole: '',
      contactAvatar: 'assets/images/pdp_4.png',
      isOnline: false,
      lastMessage: 'Merci pour la recommandation !',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      isUnread: false,
      messages: [
        MessageModel(
          id: 'm4',
          senderId: 'marcus',
          content: "Merci pour la recommandation ! Je vais consulter le poste.",
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: true,
          isMine: false,
        ),
      ],
    ),
    ConversationModel(
      id: 'c3',
      contactName: 'Elena Rodriguez',
      contactRole: '· Creative Lead',
      contactAvatar: 'assets/images/pdp_2.png',
      isOnline: false,
      lastMessage: 'Le portfolio que vous avez partagé est impressionnant...',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      isUnread: true,
      messages: [
        MessageModel(
          id: 'm5',
          senderId: 'elena',
          content: 'The portfolio you shared is impressive!',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: false,
          isMine: false,
        ),
      ],
    ),
    ConversationModel(
      id: 'c4',
      contactName: 'Karim Benali',
      contactRole: '· Chef de rang',
      contactAvatar: null,
      isOnline: true,
      lastMessage: 'Merci pour votre réponse rapide.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
      isUnread: false,
      messages: [
        MessageModel(
          id: 'm6',
          senderId: 'karim',
          content: 'Bonjour, je suis intéressé par le poste de serveur.',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          isRead: true,
          isMine: false,
        ),
        MessageModel(
          id: 'm7',
          senderId: 'me',
          content: 'Bonjour Karim, nous avons bien reçu votre candidature.',
          timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
          isRead: true,
          isMine: true,
        ),
        MessageModel(
          id: 'm8',
          senderId: 'karim',
          content: 'Merci pour votre réponse rapide.',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: true,
          isMine: false,
        ),
      ],
    ),
    ConversationModel(
      id: 'c5',
      contactName: 'Amina Cherif',
      contactRole: '· RH @FoodGroup',
      contactAvatar: null,
      isOnline: false,
      lastMessage: "Votre entretien est confirmé pour vendredi.",
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      isUnread: true,
      messages: [
        MessageModel(
          id: 'm9',
          senderId: 'amina',
          content: "Votre entretien est confirmé pour vendredi à 10h.",
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: false,
          isMine: false,
        ),
      ],
    ),
    ConversationModel(
      id: 'c6',
      contactName: 'Thomas Leclerc',
      contactRole: '· Manager',
      contactAvatar: null,
      isOnline: false,
      lastMessage: 'Pouvez-vous apporter votre CV en version papier ?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      isUnread: false,
      messages: [
        MessageModel(
          id: 'm10',
          senderId: 'thomas',
          content: 'Pouvez-vous apporter votre CV en version papier ?',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
          isMine: false,
        ),
      ],
    ),
    ConversationModel(
      id: 'c7',
      contactName: 'Nour Hadj',
      contactRole: '· Responsable recrutement',
      contactAvatar: null,
      isOnline: true,
      lastMessage: 'Nous avons retenu votre profil !',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      isUnread: false,
      messages: [
        MessageModel(
          id: 'm11',
          senderId: 'nour',
          content: 'Nous avons retenu votre profil !',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
          isMine: false,
        ),
      ],
    ),
  ];

  static final List<ConversationModel> _invitations = [
    ConversationModel(
      id: 'i1',
      contactName: 'Sarah Jenkins',
      contactRole: '· HR @TechCorp',
      contactAvatar: 'assets/images/pdp_1.png',
      isOnline: true,
      lastMessage: "We'd like to schedule an interview...",
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      isUnread: true,
      isInvitation: true,
    ),
    ConversationModel(
      id: 'i2',
      contactName: 'Marcus Chen',
      contactRole: '',
      contactAvatar: 'assets/images/pdp_4.png',
      isOnline: false,
      lastMessage: 'Thanks for the referral!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      isUnread: false,
      isInvitation: true,
    ),
    ConversationModel(
      id: 'i3',
      contactName: 'Marcus Chen',
      contactRole: '',
      contactAvatar: 'assets/images/pdp_4.png',
      isOnline: false,
      lastMessage: 'Thanks for the referral!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      isUnread: false,
      isInvitation: true,
    ),
  ];

  @override
  Future<List<ConversationEntity>> getConversations() async {
    // TODO(API): GET /api/v1/conversations
    await Future.delayed(const Duration(milliseconds: 300));
    return _conversations.map((c) => c.toEntity()).toList();
  }

  @override
  Future<List<ConversationEntity>> getInvitations() async {
    // TODO(API): GET /api/v1/conversations/invitations
    await Future.delayed(const Duration(milliseconds: 300));
    return _invitations.map((c) => c.toEntity()).toList();
  }

  @override
  Future<MessageEntity> sendMessage(String conversationId, String content) async {
    // TODO(API): POST /api/v1/conversations/:conversationId/messages  body: { content, type: "text" }
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    final newMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      isMine: true,
      type: MessageType.text,
    );

    if (idx != -1) {
      final conv = _conversations[idx];
      _conversations[idx] = ConversationModel(
        id: conv.id,
        contactName: conv.contactName,
        contactRole: conv.contactRole,
        contactAvatar: conv.contactAvatar,
        isOnline: conv.isOnline,
        lastMessage: content,
        lastMessageTime: DateTime.now(),
        isUnread: false,
        isInvitation: conv.isInvitation,
        messages: [...conv.messages, newMsg],
      );
    }

    return MessageEntity(
      id: newMsg.id,
      senderId: newMsg.senderId,
      content: newMsg.content,
      timestamp: newMsg.timestamp,
      isRead: newMsg.isRead,
      isMine: newMsg.isMine,
      type: newMsg.type,
    );
  }

  @override
  Future<void> sendImageMessage(String conversationId, String imagePath) async {
    // TODO(API): POST /api/v1/conversations/:conversationId/messages  multipart: { file, type: "image" }
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;

    final conv = _conversations[idx];
    final newMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      content: imagePath,
      timestamp: DateTime.now(),
      isRead: false,
      isMine: true,
      type: MessageType.image,
    );

    _conversations[idx] = ConversationModel(
      id: conv.id,
      contactName: conv.contactName,
      contactRole: conv.contactRole,
      contactAvatar: conv.contactAvatar,
      isOnline: conv.isOnline,
      lastMessage: '📷 Image',
      lastMessageTime: DateTime.now(),
      isUnread: false,
      isInvitation: conv.isInvitation,
      messages: [...conv.messages, newMsg],
    );
  }

  @override
  Future<void> sendFileMessage(String conversationId, String filePath) async {
    // TODO(API): POST /api/v1/conversations/:conversationId/messages  multipart: { file, type: "file" }
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;

    final conv = _conversations[idx];
    final fileName = filePath.split('/').last;
    final newMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      content: filePath,
      timestamp: DateTime.now(),
      isRead: false,
      isMine: true,
      type: MessageType.file,
    );

    _conversations[idx] = ConversationModel(
      id: conv.id,
      contactName: conv.contactName,
      contactRole: conv.contactRole,
      contactAvatar: conv.contactAvatar,
      isOnline: conv.isOnline,
      lastMessage: '📎 $fileName',
      lastMessageTime: DateTime.now(),
      isUnread: false,
      isInvitation: conv.isInvitation,
      messages: [...conv.messages, newMsg],
    );
  }

  @override
  Future<void> acceptInvitation(String conversationId) async {
    // TODO(API): POST /api/v1/conversations/:conversationId/accept
    final idx = _invitations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    final inv = _invitations[idx];
    _invitations.removeAt(idx);
    _conversations.insert(
      0,
      ConversationModel(
        id: inv.id,
        contactName: inv.contactName,
        contactRole: inv.contactRole,
        contactAvatar: inv.contactAvatar,
        isOnline: inv.isOnline,
        lastMessage: inv.lastMessage,
        lastMessageTime: inv.lastMessageTime,
        isUnread: true,
        isInvitation: false,
        messages: inv.messages,
      ),
    );
  }

  @override
  Future<void> declineInvitation(String conversationId) async {
    // TODO(API): DELETE /api/v1/conversations/:conversationId/invitation
    _invitations.removeWhere((c) => c.id == conversationId);
  }

  @override
  Future<void> deleteConversations(List<String> ids) async {
    // TODO(API): DELETE /api/v1/conversations  body: { ids }
    _conversations.removeWhere((c) => ids.contains(c.id));
    _invitations.removeWhere((c) => ids.contains(c.id));
  }

  @override
  Future<Set<String>> getBlockedIds() async {
    // TODO(API): GET /api/v1/users/me/blocked
    return Set.from(_blockedIds);
  }

  @override
  Future<Set<String>> getRestrictedIds() async {
    // TODO(API): GET /api/v1/users/me/restricted
    return Set.from(_restrictedIds);
  }

  @override
  Future<void> blockContact(String conversationId) async {
    // TODO(API): POST /api/v1/users/me/blocked  body: { contactId: conversationId }
    _blockedIds.add(conversationId);
  }

  @override
  Future<void> unblockContact(String conversationId) async {
    // TODO(API): DELETE /api/v1/users/me/blocked/:contactId
    _blockedIds.remove(conversationId);
  }

  @override
  Future<void> restrictContact(String conversationId) async {
    // TODO(API): POST /api/v1/users/me/restricted  body: { contactId: conversationId }
    _restrictedIds.add(conversationId);
  }

  @override
  Future<void> unrestrictContact(String conversationId) async {
    // TODO(API): DELETE /api/v1/users/me/restricted/:contactId
    _restrictedIds.remove(conversationId);
  }

  @override
  Future<ConversationEntity> getOrCreateConversation({
    required String contactName,
    required String contactRole,
    String? contactAvatar,
  }) async {
    // TODO(API): GET /api/v1/conversations?contactName=... ou POST /api/v1/conversations  body: { contactName, contactRole }
    final existing = _conversations.where((c) => 
      c.contactName == contactName && !c.isGroup
    ).firstOrNull;
    
    if (existing != null) {
      return existing.toEntity();
    }
    
    // Créer une nouvelle conversation
    final id = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final newConv = ConversationModel(
      id: id,
      contactName: contactName,
      contactRole: contactRole,
      contactAvatar: contactAvatar,
      isOnline: false,
      lastMessage: 'Nouvelle conversation',
      lastMessageTime: DateTime.now(),
      isUnread: false,
      messages: [],
    );
    
    _conversations.insert(0, newConv);
    return newConv.toEntity();
  }

  @override
  Future<ConversationEntity> getOrCreateConversationById(int contactId) async {
    final existing = _conversations.where((c) => !c.isGroup).firstOrNull;
    if (existing != null) return existing.toEntity();
    final newConv = ConversationModel(
      id: 'conv_$contactId',
      contactName: 'Recruteur',
      contactRole: '',
      contactAvatar: null,
      isOnline: false,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      isUnread: false,
      messages: [],
    );
    _conversations.insert(0, newConv);
    return newConv.toEntity();
  }

  @override
  Future<ConversationEntity> createGroup(
    String groupName,
    List<int> memberIds,
  ) async {
    // TODO(API): POST /api/v1/conversations/group  body: { groupName, memberIds }
    final id = 'group_${DateTime.now().millisecondsSinceEpoch}';
    final displayName = groupName.isNotEmpty ? groupName : 'Nouveau groupe';
    final newConv = ConversationModel(
      id: id,
      contactName: displayName,
      contactRole: '',
      contactAvatar: null,
      isOnline: false,
      lastMessage: 'Groupe créé',
      lastMessageTime: DateTime.now(),
      isUnread: false,
      isGroup: true,
      groupName: groupName.isNotEmpty ? groupName : null,
    );
    _conversations.insert(0, newConv);
    return newConv.toEntity();
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    // Mock: no-op
  }
}

