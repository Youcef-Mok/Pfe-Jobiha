// lib/features/auth/data/models/user_model.dart

class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String? role; // 'candidat' | 'recruteur'
  final String? avatarUrl;
  final String? location;
  final String? bio;
  final bool estVerifie;
  final String statutCompte;

  const UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    this.role,
    this.avatarUrl,
    this.location,
    this.bio,
    required this.estVerifie,
    required this.statutCompte,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        nom: json['nom'] as String,
        prenom: json['prenom'] as String,
        email: json['email'] as String,
        telephone: json['telephone'] as String?,
        role: json['role'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        location: json['location'] as String?,
        bio: json['bio'] as String?,
        estVerifie: json['est_verifie'] as bool? ?? false,
        statutCompte: json['statut_compte'] as String? ?? 'actif',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        if (telephone != null) 'telephone': telephone,
        if (role != null) 'role': role,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (location != null) 'location': location,
        if (bio != null) 'bio': bio,
        'est_verifie': estVerifie,
        'statut_compte': statutCompte,
      };
}
