import 'package:job_app/features/candidates/data/models/candidate_model.dart';
import 'package:job_app/features/candidates/domain/candidate_entity.dart';
import 'candidates_repository.dart';

// TODO(API): Remplacer par CandidatesRepositoryHttp dans candidates_provider.dart.
class CandidatesRepositoryMock implements CandidatesRepository {
  @override
  Future<List<CandidateModel>> getCandidates(String jobId) async {
    // TODO(API): GET /api/v1/jobs/:jobId/candidates
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockCandidates;
  }

  @override
  Future<void> updateCandidateStatus(String candidateId, String status) async {
    // TODO(API): PATCH /api/v1/candidates/:candidateId/status  body: { status }
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockCandidates.indexWhere((c) => c.id == candidateId);
    if (index != -1) {
      final old = _mockCandidates[index];
      // Create a copy with the new status because CandidateModel doesn't have copyWith
      // Actually CandidateModel might have copyWith if it's freezed, wait, let's check.
      // If not, we instantiate a new one.
      _mockCandidates[index] = CandidateModel(
        id: old.id,
        name: old.name,
        title: old.title,
        photoUrl: old.photoUrl,
        rating: old.rating,
        reviewsCount: old.reviewsCount,
        isTopRated: old.isTopRated,
        coverLetter: old.coverLetter,
        status: _parseStatus(status),
      );
    }
  }

  CandidateStatus _parseStatus(String statusStr) {
    return CandidateStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => CandidateStatus.nouveau,
    );
  }

  @override
  Future<void> scheduleInterview(
    String candidateId,
    DateTime date,
    String timeSlot,
  ) async {
    // TODO(API): POST /api/v1/interviews  body: { candidateId, date, timeSlot }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static final List<CandidateModel> _mockCandidates = [
    const CandidateModel(
      id: '1',
      name: 'Momo',
      title: 'Barman',
      photoUrl: 'assets/images/pdp_1.png',
      rating: 3.7,
      reviewsCount: 12,
      isTopRated: false,
      coverLetter:
          'Je vous adresse ma candidature pour le poste de barman au sein de votre établissement.',
      status: CandidateStatus.nouveau,
    ),
    const CandidateModel(
      id: '2',
      name: 'Farid',
      title: 'Etudiant',
      photoUrl: 'assets/images/pdp_4.png',
      rating: 4.9,
      reviewsCount: 12,
      isTopRated: true,
      coverLetter:
          'Je vous adresse ma candidature pour le poste de développeur frontend au sein de votre entreprise, attiré par votre approche centrée sur l\'expérience utilisateur',
      status: CandidateStatus.nouveau,
    ),
    const CandidateModel(
      id: '3',
      name: 'Farida',
      title: 'Computer Science Junior',
      photoUrl: 'assets/images/pdp_3.png',
      rating: 3.5,
      reviewsCount: 12,
      isTopRated: false,
      coverLetter:
          'Je suis très intéressée par cette opportunité et je pense que mes compétences correspondent parfaitement.',
      status: CandidateStatus.nouveau,
    ),
    const CandidateModel(
      id: '4',
      name: 'John',
      title: 'Computer Science Junior',
      photoUrl: 'assets/images/pdp_new.png',
      rating: 4.9,
      reviewsCount: 12,
      isTopRated: true,
      coverLetter:
          'Passionné par le développement web, je souhaite rejoindre votre équipe.',
      status: CandidateStatus.nouveau,
    ),
    const CandidateModel(
      id: '5',
      name: 'Alice',
      title: 'Computer Science Junior',
      photoUrl: 'assets/images/pdp_7.png',
      rating: 4.9,
      reviewsCount: 12,
      isTopRated: false,
      coverLetter:
          'Mon expérience dans le domaine me permettra de contribuer efficacement.',
      status: CandidateStatus.nouveau,
    ),
    const CandidateModel(
      id: '6',
      name: 'Djamel',
      title: 'Computer Science Junior',
      photoUrl: 'assets/images/pdp_2.png',
      rating: 4.9,
      reviewsCount: 12,
      isTopRated: false,
      coverLetter:
          'Je serais ravi de mettre mes compétences au service de votre entreprise.',
      status: CandidateStatus.nouveau,
    ),
  ];
}
