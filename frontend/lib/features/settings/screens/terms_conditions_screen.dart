import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F3F8),
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'Conditions d\'utilisation',
          style: AppTextStyles.heading1.copyWith(fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _TermsSection(
            title: '1. Acceptation des conditions',
            content:
                'En utilisant Jobiha, vous acceptez les présentes conditions d\'utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.',
          ),
          _TermsSection(
            title: '2. Description du service',
            content:
                'Jobiha est une plateforme de mise en relation entre candidats à la recherche de petits jobs et recruteurs. Nous ne sommes pas un employeur et ne sommes pas partie aux contrats conclus entre candidats et recruteurs.',
          ),
          _TermsSection(
            title: '3. Compte utilisateur',
            content:
                'Vous êtes responsable de la confidentialité de vos identifiants de connexion et de toutes les activités effectuées depuis votre compte. Vous devez nous informer immédiatement de toute utilisation non autorisée.',
          ),
          _TermsSection(
            title: '4. Contenu interdit',
            content:
                'Il est interdit de publier des offres frauduleuses, du contenu illégal, des informations personnelles d\'autrui ou tout contenu qui viole les droits de tiers.',
          ),
          _TermsSection(
            title: '5. Propriété intellectuelle',
            content:
                'Tout le contenu de l\'application Jobiha (logo, design, code) est protégé par les lois sur la propriété intellectuelle et appartient à Jobiha SAS.',
          ),
          _TermsSection(
            title: '6. Limitation de responsabilité',
            content:
                'Jobiha ne peut être tenu responsable des dommages résultant de l\'utilisation ou de l\'impossibilité d\'utiliser le service, ni des actions ou omissions des utilisateurs.',
          ),
          _TermsSection(
            title: '7. Modification des conditions',
            content:
                'Nous nous réservons le droit de modifier ces conditions à tout moment. Les modifications entrent en vigueur dès leur publication sur l\'application.',
          ),
          _TermsSection(
            title: '8. Droit applicable',
            content:
                'Les présentes conditions sont régies par le droit algérien. Tout litige sera soumis aux tribunaux compétents d\'Alger.',
          ),
          SizedBox(height: 12),
          Text(
            'Dernière mise à jour : janvier 2025',
            style: TextStyle(fontSize: 12, color: Colors.black38),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String content;
  const _TermsSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCDCDCD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF401E66))),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(
                  fontSize: 13, color: Colors.black54, height: 1.6)),
        ],
      ),
    );
  }
}