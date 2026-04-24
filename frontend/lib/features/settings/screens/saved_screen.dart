// lib/features/settings/screens/saved_screen.dart

import 'package:flutter/material.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/widgets/job_card.dart';
import 'package:intl/intl.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<JobEntity> _jobs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.savedJobs);
      final List data = response.data as List;
      setState(() {
        _jobs = data.map((j) => _mapJob(j)).toList();
      });
    } catch (e) {
      setState(() => _error = 'Impossible de charger les offres sauvegardées.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  JobEntity _mapJob(Map<String, dynamic> j) {
    return JobEntity(
      id:            j['id'].toString(),
      title:         j['titre']        ?? j['title']        ?? 'Sans titre',
      companyName:   j['entreprise']   ?? j['company_name'] ?? '',
      contractType:  ContractType.cdi,
      postedAt:      j['date_publication'] != null
          ? DateTime.tryParse(j['date_publication']) ?? DateTime.now()
          : DateTime.now(),
      status:        JobStatus.searching,
      candidateCount: j['nombre_candidats'] ?? 0,
      viewCount:      j['vues']             ?? 0,
      logoAsset:      j['logo'],
      isPublished:    true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'Offres sauvegardées',
          style: AppTextStyles.heading1.copyWith(fontSize: 18),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.violet),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.slate400),
              const SizedBox(height: 16),
              Text(_error!, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadSaved,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_border, size: 48, color: AppColors.slate400),
            const SizedBox(height: 16),
            Text('Aucune offre sauvegardée',
                style: AppTextStyles.heading3.copyWith(color: AppColors.slate600)),
            const SizedBox(height: 8),
            Text('Les offres que vous sauvegardez apparaîtront ici.',
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.violet,
      onRefresh: _loadSaved,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _jobs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return JobCard(job: _jobs[index]);
        },
      ),
    );
  }
}