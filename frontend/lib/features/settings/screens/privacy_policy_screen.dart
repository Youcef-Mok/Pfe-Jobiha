// lib/features/settings/screens/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F3F8),
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'Politique de confidentialité',
          style: AppTextStyles.heading1.copyWith(fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _PolicySection(
            title: '1. Collecte des données',
            content:
                'Jobiha collecte les informations que vous fournissez lors de la création de votre compte, notamment votre nom, adresse email, numéro de téléphone et informations professionnelles. Nous collectons également des données d\'utilisation pour améliorer nos services.',
          ),
          _PolicySection(
            title: '2. Utilisation des données',
            content:
                'Vos données sont utilisées pour vous mettre en relation avec des recruteurs ou des candidats, personnaliser votre expérience, vous envoyer des notifications pertinentes et améliorer notre plateforme.',
          ),
          _PolicySection(
            title: '3. Partage des données',
            content:
                'Nous ne vendons jamais vos données personnelles à des tiers. Vos informations de profil sont visibles uniquement par les recruteurs ou candidats avec lesquels vous interagissez sur la plateforme.',
          ),
          _PolicySection(
            title: '4. Sécurité',
            content:
                'Nous utilisons des mesures de sécurité standard pour protéger vos données, notamment le chiffrement SSL et des mots de passe hachés. Vos tokens d\'authentification sont stockés de manière sécurisée sur votre appareil.',
          ),
          _PolicySection(
            title: '5. Vos droits',
            content:
                'Vous avez le droit d\'accéder à vos données, de les modifier ou de les supprimer à tout moment. Pour exercer ces droits, contactez-nous à jobihausthb@gmail.com ',
          ),
          _PolicySection(
            title: '6. Cookies',
            content:
                'Notre application utilise des technologies similaires aux cookies pour mémoriser vos préférences et maintenir votre session active.',
          ),
          _PolicySection(
            title: '7. Contact',
            content:
                'Pour toute question concernant cette politique, contactez notre délégué à la protection des données à privacy@jobiha.dz.',
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

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  const _PolicySection({required this.title, required this.content});

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