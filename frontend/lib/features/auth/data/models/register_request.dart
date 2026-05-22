// lib/features/auth/data/models/register_request.dart

class RegisterCandidatRequest {
  final String prenom;
  final String nom;
  final String email;
  final String telephone;
  final String motDePasse;

  const RegisterCandidatRequest({
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.motDePasse,
  });

  Map<String, dynamic> toJson() => {
        'prenom':       prenom,
        'nom':          nom,
        'email':        email,
        'telephone':    telephone,
        'mot_de_passe': motDePasse,
      };
}

class RegisterRecruteurRequest {
  final String prenom;
  final String nom;
  final String email;
  final String telephone;
  final String motDePasse;

  const RegisterRecruteurRequest({
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.motDePasse,
  });

  Map<String, dynamic> toJson() => {
        'prenom':       prenom,
        'nom':          nom,
        'email':        email,
        'telephone':    telephone,
        'mot_de_passe': motDePasse,
      };
}