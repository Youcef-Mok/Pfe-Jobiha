import 'package:flutter/material.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/core/theme/app_theme.dart';

class ApplicationsReceivedScreen extends StatefulWidget {
  const ApplicationsReceivedScreen({super.key});

  @override
  State<ApplicationsReceivedScreen> createState() => _ApplicationsReceivedScreenState();
}

class _ApplicationsReceivedScreenState extends State<ApplicationsReceivedScreen> {
  List<Map<String, dynamic>> _applications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.receivedApplications);
      final List data = response.data as List;
      setState(() => _applications = data.cast<Map<String, dynamic>>());
    } catch (e) {
      setState(() => _error = 'Impossible de charger les candidatures reçues.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
          'Candidatures reçues',
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
                onPressed: _loadApplications,
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

    if (_applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.slate400),
            const SizedBox(height: 16),
            Text('Aucune candidature reçue',
                style: AppTextStyles.heading3.copyWith(color: AppColors.slate600)),
            const SizedBox(height: 8),
            Text('Les candidatures reçues apparaîtront ici.',
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.violet,
      onRefresh: _loadApplications,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _applications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _ReceivedApplicationCard(app: _applications[index]);
        },
      ),
    );
  }
}

// ── Received Application Card ─────────────────────────────────────────────────

class _ReceivedApplicationCard extends StatelessWidget {
  final Map<String, dynamic> app;

  const _ReceivedApplicationCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final title       = app['offre']?['titre']        ?? app['titre']        ?? 'Sans titre';
    final company     = app['offre']?['entreprise']   ?? app['entreprise']   ?? '';
    final status      = app['statut']                 ?? app['status']       ?? 'en_attente';
    final dateStr     = app['date_candidature']       ?? app['created_at']   ?? '';
    final candidatNom = app['candidat']?['nom']       ?? app['nom']          ?? '';
    final candidatPrenom = app['candidat']?['prenom'] ?? app['prenom']       ?? '';
    final avatar      = app['candidat']?['photo']     ?? app['photo'];

    final date = dateStr.isNotEmpty ? DateTime.tryParse(dateStr) : null;
    final fullName = '$candidatPrenom $candidatNom'.trim();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violetBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.draftBg,
                borderRadius: BorderRadius.circular(26),
              ),
              child: avatar != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.network(
                        avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, color: AppColors.slate400, size: 24),
                      ),
                    )
                  : const Icon(Icons.person, color: AppColors.slate400, size: 24),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isNotEmpty ? fullName : 'Candidat inconnu',
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(title, style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (company.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(company, style: AppTextStyles.captionLight),
                  ],
                  if (date != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Reçue le ${date.day}/${date.month}/${date.year}',
                      style: AppTextStyles.captionLight,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Status badge
            _StatusBadge(status: status),
          ],
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, textColor, label) = switch (status) {
      'accepte'    || 'accepted'  => (const Color(0xFFE6F4EA), const Color(0xFF2E7D32), 'Acceptée'),
      'refuse'     || 'rejected'  => (const Color(0xFFFFEBEE), const Color(0xFFC62828), 'Refusée'),
      'en_attente' || 'pending'   => (AppColors.draftBg, AppColors.draftText, 'En attente'),
      _                           => (AppColors.draftBg, AppColors.draftText, 'En attente'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}