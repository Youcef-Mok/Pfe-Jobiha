// lib/features/settings/data/models/settings_model.dart

class SettingsModel {
  final bool pushNotifEnabled;
  final List<BlockedUserModel> blockedUsers;

  const SettingsModel({
    this.pushNotifEnabled = true,
    this.blockedUsers = const [],
  });

  SettingsModel copyWith({
    bool? pushNotifEnabled,
    List<BlockedUserModel>? blockedUsers,
  }) =>
      SettingsModel(
        pushNotifEnabled: pushNotifEnabled ?? this.pushNotifEnabled,
        blockedUsers:     blockedUsers     ?? this.blockedUsers,
      );
}

class BlockedUserModel {
  final int id;
  final String nom;
  final String prenom;
  final String? avatar;
  final DateTime? dateBlocage;

  const BlockedUserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.avatar,
    this.dateBlocage,
  });

  String get fullName => '$prenom $nom'.trim();

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) =>
      BlockedUserModel(
        id:          json['id'] as int,
        nom:         json['nom']    as String,
        prenom:      json['prenom'] as String,
        avatar:      json['avatar'] as String?,
        dateBlocage: json['date_blocage'] != null
            ? DateTime.tryParse(json['date_blocage'] as String)
            : null,
      );
}