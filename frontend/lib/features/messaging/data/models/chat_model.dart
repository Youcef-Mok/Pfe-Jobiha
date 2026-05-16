// lib/features/messaging/data/models/chat_model.dart
//
// Data-layer models that map 1-to-1 to the Django REST API response shapes.
// Updated for unified conversations (DM + group).

import '../../domain/conversation_entity.dart';
import '../../domain/message_entity.dart';

// ---------------------------------------------------------------------------
// Lightweight user sub-object returned inside message payloads
// ---------------------------------------------------------------------------

class UserBrief {
  final int id;
  final String nom;
  final String prenom;

  const UserBrief({
    required this.id,
    required this.nom,
    required this.prenom,
  });

  factory UserBrief.fromJson(Map<String, dynamic> json) => UserBrief(
        id:     json['id'] as int,
        nom:    json['nom'] as String? ?? '',
        prenom: json['prenom'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
      };
}

// ---------------------------------------------------------------------------
// MessageModel — maps to MessageSerializer output
// ---------------------------------------------------------------------------

class MessageModel {
  final int id;
  final String contenu;
  final DateTime dateEnvoi;
  final int conversationId;
  final UserBrief expediteur;

  const MessageModel({
    required this.id,
    required this.contenu,
    required this.dateEnvoi,
    required this.conversationId,
    required this.expediteur,
  });

  MessageModel copyWith({
    int? id,
    String? contenu,
    DateTime? dateEnvoi,
    int? conversationId,
    UserBrief? expediteur,
  }) =>
      MessageModel(
        id:             id ?? this.id,
        contenu:        contenu ?? this.contenu,
        dateEnvoi:      dateEnvoi ?? this.dateEnvoi,
        conversationId: conversationId ?? this.conversationId,
        expediteur:     expediteur ?? this.expediteur,
      );

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id:             json['id'] as int,
        contenu:        json['contenu'] as String,
        dateEnvoi:      DateTime.parse(json['date_envoi'] as String).toLocal(),
        conversationId: json['conversation_id'] as int,
        expediteur:     UserBrief.fromJson(json['expediteur'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'contenu': contenu,
        'date_envoi': dateEnvoi.toIso8601String(),
        'conversation_id': conversationId,
        'expediteur': expediteur.toJson(),
      };

  MessageEntity toEntity() => MessageEntity(
        id:               id,
        contenu:          contenu,
        dateEnvoi:        dateEnvoi,
        conversationId:   conversationId,
        expediteurId:     expediteur.id,
        expediteurNom:    expediteur.nom,
        expediteurPrenom: expediteur.prenom,
      );
}

// ---------------------------------------------------------------------------
// MemberBriefModel — user sub-object in group conversations
// ---------------------------------------------------------------------------

class MemberBriefModel {
  final int id;
  final String nom;
  final String prenom;
  final String? role;

  const MemberBriefModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.role,
  });

  factory MemberBriefModel.fromJson(Map<String, dynamic> json) =>
      MemberBriefModel(
        id:     json['id'] as int,
        nom:    json['nom'] as String? ?? '',
        prenom: json['prenom'] as String? ?? '',
        role:   json['role'] as String?,
      );
}

// ---------------------------------------------------------------------------
// ConversationModel — maps to ConversationSummarySerializer output
// ---------------------------------------------------------------------------

class ConversationModel {
  final int conversationId;
  final String type;
  final String? nom;
  final MemberBriefModel? interlocuteur;  // DMs only
  final List<MemberBriefModel>? members;  // groups only
  final MessageModel dernierMessage;
  final int nbNonLus;

  const ConversationModel({
    required this.conversationId,
    required this.type,
    this.nom,
    this.interlocuteur,
    this.members,
    required this.dernierMessage,
    required this.nbNonLus,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    // Parse interlocuteur (DMs)
    MemberBriefModel? interlocuteur;
    if (json['interlocuteur'] != null) {
      interlocuteur = MemberBriefModel.fromJson(
          json['interlocuteur'] as Map<String, dynamic>);
    }

    // Parse members (groups)
    List<MemberBriefModel>? members;
    if (json['members'] != null) {
      members = (json['members'] as List)
          .map((m) => MemberBriefModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return ConversationModel(
      conversationId: json['conversation_id'] as int,
      type:           json['type'] as String,
      nom:            json['nom'] as String?,
      interlocuteur:  interlocuteur,
      members:        members,
      dernierMessage: MessageModel.fromJson(
          json['dernier_message'] as Map<String, dynamic>),
      nbNonLus:       json['nb_non_lus'] as int? ?? 0,
    );
  }

  bool get isDirect => type == 'direct';
  bool get isGroup  => type == 'group';

  ConversationEntity toEntity() => ConversationEntity(
        conversationId:     conversationId,
        type:               type,
        groupName:          nom,
        interlocuteurId:    interlocuteur?.id,
        interlocuteurNom:   interlocuteur?.nom,
        interlocuteurPrenom: interlocuteur?.prenom,
        interlocuteurRole:  interlocuteur?.role,
        members: members
            ?.map((m) => MemberBrief(
                  id: m.id,
                  nom: m.nom,
                  prenom: m.prenom,
                  role: m.role,
                ))
            .toList(),
        dernierMessage: dernierMessage.toEntity(),
        nbNonLus:       nbNonLus,
      );
}