import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/candidates/domain/candidate_entity.dart';

class CandidateProfileScreen extends StatelessWidget {
  final CandidateEntity candidate;

  const CandidateProfileScreen({
    super.key,
    required this.candidate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil du Candidat',
          style: AppTextStyles.heading1.copyWith(color: AppColors.slate900),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildStats(),
            _buildAbout(),
            _buildExperience(),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.violet, width: 4),
                  image: DecorationImage(
                    image: AssetImage(candidate.photoUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (candidate.isTopRated)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1AA62),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TOP RATED',
                      style: AppTextStyles.badge,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            candidate.name,
            style: AppTextStyles.heading1.copyWith(fontSize: 24, color: AppColors.violet),
          ),
          Text(
            candidate.title,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Rating', candidate.rating.toStringAsFixed(1), Icons.star),
          _buildStatItem('Avis', candidate.reviewsCount.toString(), Icons.comment),
          _buildStatItem('Jobs', '12', Icons.work), 
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFC1AA62), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading1.copyWith(fontSize: 18),
        ),
        Text(
          label,
          style: AppTextStyles.captionLight,
        ),
      ],
    );
  }

  Widget _buildAbout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos',
            style: AppTextStyles.heading2.copyWith(color: AppColors.violet),
          ),
          const SizedBox(height: 12),
          Text(
            candidate.coverLetter,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate700, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildExperience() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expériences récentes',
            style: AppTextStyles.heading2.copyWith(color: AppColors.violet),
          ),
          const SizedBox(height: 16),
          _buildExpItem('Barman Senior', 'Hôtel Ritz Paris', '2021 - Présent'),
          _buildExpItem('Serveur', 'Le Meurice', '2019 - 2021'),
        ],
      ),
    );
  }

  Widget _buildExpItem(String title, String company, String period) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: AppColors.violet),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelBold.copyWith(fontSize: 16, color: AppColors.slate900),
              ),
              Text(
                company,
                style: AppTextStyles.captionLight.copyWith(fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Text(
            period,
            style: AppTextStyles.captionLight,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.violet),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('IGNORER', style: AppTextStyles.labelBold.copyWith(color: AppColors.violet)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('CONTACTER', style: AppTextStyles.labelBold.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
