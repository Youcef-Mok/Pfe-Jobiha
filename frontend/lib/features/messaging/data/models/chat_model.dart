// lib/features/messaging/data/models/chat_model.dart
//
// Data-layer models that map 1-to-1 to the Django REST API response shapes.
// Each model knows how to parse JSON and convert to its domain entity.

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
  final bool estLu;
  final UserBrief expediteur;
  final UserBrief destinataire;

  const MessageModel({
    required this.id,
    required this.contenu,
    required this.dateEnvoi,
    required this.estLu,
    required this.expediteur,
    required this.destinataire,
  });


    MessageModel copyWith({
    int? id,
    String? contenu,
    DateTime? dateEnvoi,
    bool? estLu,
    UserBrief? expediteur,
    UserBrief? destinataire,
  }) =>
      MessageModel(
        id:           id ?? this.id,
        contenu:      contenu ?? this.contenu,
        dateEnvoi:    dateEnvoi ?? this.dateEnvoi,
        estLu:        estLu ?? this.estLu,
        expediteur:   expediteur ?? this.expediteur,
        destinataire: destinataire ?? this.destinataire,
      );

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id:           json['id'] as int,
        contenu:      json['contenu'] as String,
        dateEnvoi:    DateTime.parse(json['date_envoi'] as String).toLocal(),
        estLu:        json['est_lu'] as bool? ?? false,
        expediteur:   UserBrief.fromJson(json['expediteur'] as Map<String, dynamic>),
        destinataire: UserBrief.fromJson(json['destinataire'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'contenu': contenu,
        'date_envoi': dateEnvoi.toIso8601String(),
        'est_lu': estLu,
        'expediteur': expediteur.toJson(),
        'destinataire': destinataire.toJson(),
      };

  MessageEntity toEntity() => MessageEntity(
        id:                 id,
        contenu:            contenu,
        dateEnvoi:          dateEnvoi,
        estLu:              estLu,
        expediteurId:       expediteur.id,
        expediteurNom:      expediteur.nom,
        expediteurPrenom:   expediteur.prenom,
        destinataireId:     destinataire.id,
        destinataireNom:    destinataire.nom,
        destinatairePrenom: destinataire.prenom,
      );
}

// ---------------------------------------------------------------------------
// InterlocuteurBrief — user sub-object in conversation summaries
// ---------------------------------------------------------------------------

class InterlocuteurBrief {
  final int id;
  final String nom;
  final String prenom;
  final String? role;

  const InterlocuteurBrief({
    required this.id,
    required this.nom,
    required this.prenom,
    this.role,
  });

  factory InterlocuteurBrief.fromJson(Map<String, dynamic> json) =>
      InterlocuteurBrief(
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
  final InterlocuteurBrief interlocuteur;
  final MessageModel dernierMessage;
  final int nbNonLus;

  const ConversationModel({
    required this.interlocuteur,
    required this.dernierMessage,
    required this.nbNonLus,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        interlocuteur:  InterlocuteurBrief.fromJson(
            json['interlocuteur'] as Map<String, dynamic>),
        dernierMessage: MessageModel.fromJson(
            json['dernier_message'] as Map<String, dynamic>),
        nbNonLus:       json['nb_non_lus'] as int? ?? 0,
      );

  ConversationEntity toEntity() => ConversationEntity(
        interlocuteurId:     interlocuteur.id,
        interlocuteurNom:    interlocuteur.nom,
        interlocuteurPrenom: interlocuteur.prenom,
        interlocuteurRole:   interlocuteur.role,
        dernierMessage:      dernierMessage.toEntity(),
        nbNonLus:            nbNonLus,
      );
}