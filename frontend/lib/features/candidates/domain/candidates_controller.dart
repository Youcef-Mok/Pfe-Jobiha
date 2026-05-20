import 'package:job_app/features/candidates/domain/candidate_entity.dart';

// TODO(API): Quand le backend est branché, CandidatesNotifier récupérera des
//            CandidateEntity depuis CandidatesRepositoryHttp (GET /api/jobs/:id/candidates).
//            Ce controller reste identique — il ne touche pas à la couche data.

class CandidatesController {
  const CandidatesController();

  /// Filtre par statut simple (ex. détails offre — onglet candidatures).
  /// TODO(API): GET /api/v1/jobs/:jobId/candidates?status=
  List<CandidateEntity> filterByStatus(
    List<CandidateEntity> candidates,
    CandidateStatus status,
  ) =>
      candidates.where((c) => c.status == status).toList();

  /// Filtre et trie la liste des candidats selon l'onglet actif et le mode de tri.
  List<CandidateEntity> filterAndSort({
    required List<CandidateEntity> candidates,
    required CandidateStatus tab,
    required String sortMode,
  }) {
    var list = candidates.where((c) {
      if (tab == CandidateStatus.archive) {
        return c.status == CandidateStatus.archive;
      }
      if (tab == CandidateStatus.nouveau) {
        return c.status == CandidateStatus.nouveau ||
            c.status == CandidateStatus.archive;
      }
      return c.status == tab;
    }).toList();

    if (sortMode == 'best') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sortMode == 'recent') {
      list.sort((a, b) => b.id.compareTo(a.id));
    } else if (sortMode == 'unprocessed') {
      list = list.where((c) => c.status == CandidateStatus.nouveau).toList();
    }

    return list;
  }
}
