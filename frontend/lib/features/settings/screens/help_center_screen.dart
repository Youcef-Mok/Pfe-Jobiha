import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqs = [
    (
      'Comment postuler à une offre ?',
      'Parcourez les offres disponibles, cliquez sur une offre qui vous intéresse, puis appuyez sur "Postuler". Votre candidature sera envoyée directement au recruteur.'
    ),
    (
      'Comment modifier mon profil ?',
      'Allez dans Paramètres → Informations personnelles. Vous pouvez y modifier votre nom, prénom et numéro de téléphone.'
    ),
    (
      'Comment changer mon mot de passe ?',
      'Allez dans Paramètres → Mot de passe & Sécurité. Entrez votre ancien mot de passe, puis votre nouveau mot de passe deux fois.'
    ),
    (
      'Comment voir mes candidatures ?',
      'Allez dans Paramètres → Mes candidatures. Vous y trouverez toutes les offres auxquelles vous avez postulé avec leur statut.'
    ),
    (
      'Comment sauvegarder une offre ?',
      'Sur la page d\'une offre, appuyez sur l\'icône de signet. L\'offre apparaîtra dans Paramètres → Offres sauvegardées.'
    ),
    (
      'Comment contacter le support ?',
      'Envoyez-nous un email à jobihausthb@gmail.com. Nous répondons dans un délai de 24 à 48 heures.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F3F8),
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'Centre d\'aide',
          style: AppTextStyles.heading1.copyWith(fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF401E66),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.help_outline, size: 40, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Comment pouvons-nous vous aider ?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Retrouvez les réponses aux questions fréquentes ci-dessous.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Questions fréquentes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => _FaqItem(question: faq.$1, answer: faq.$2)),
          const SizedBox(height: 24),
          // Contact
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCDCDCD)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.mail_outline,
                      color: Color(0xFF401E66), size: 22),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contacter le support',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    SizedBox(height: 2),
                    Text('jobihausthb@gmail.com',
                        style:
                            TextStyle(color: Colors.black54, fontSize: 13)),
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

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCDCDCD)),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(widget.question,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF401E66),
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(widget.answer,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}