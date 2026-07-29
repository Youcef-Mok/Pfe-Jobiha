import 'package:job_app/features/interviews/domain/interview_entity.dart';
import 'package:job_app/features/interviews/data/models/interview_model.dart';
import 'package:job_app/features/interviews/data/repositories/interviews_repository.dart';

// TODO(API): Remplacer par InterviewsRepositoryHttp dans interviews_provider.dart.
class InterviewsRepositoryMock implements InterviewsRepository {
  static final List<InterviewModel> _mockData = [
    InterviewModel(
      id: 'int_1',
      candidateId: 'cand_1',
      candidateName: 'Amélie Laurent',
      candidateAvatar: 'assets/images/pdp_1.png',
      jobId: '2',
      jobTitle: 'Chef de Produit',
      department: 'IT',
      scheduledDate: DateTime.now().add(const Duration(days: 2, hours: 10)).toIso8601String(),
      status: 'scheduled',
      notes: null,
    ),
    InterviewModel(
      id: 'int_2',
      candidateId: 'cand_2',
      candidateName: 'Marc Dubois',
      candidateAvatar: 'assets/images/pdp_4.png',
      jobId: '2',
      jobTitle: 'Chef de Produit',
      department: 'IT',
      scheduledDate: DateTime.now().add(const Duration(days: 3, hours: 14)).toIso8601String(),
      status: 'scheduled',
      notes: null,
    ),
    InterviewModel(
      id: 'int_3',
      candidateId: 'cand_3',
      candidateName: 'Lucas Petit',
      candidateAvatar: 'assets/images/pdp_new.png',
      jobId: '4',
      jobTitle: 'Développeur Flutter',
      department: 'IT',
      scheduledDate: DateTime.now().add(const Duration(days: 5, hours: 9)).toIso8601String(),
      status: 'scheduled',
      notes: null,
    ),
    InterviewModel(
      id: 'int_4',
      candidateId: 'cand_4',
      candidateName: 'Sophie Martin',
      candidateAvatar: 'assets/images/pdp_2.png',
      jobId: '5',
      jobTitle: 'Designer UX',
      department: 'Design',
      scheduledDate: DateTime.now().add(const Duration(days: 7, hours: 15)).toIso8601String(),
      status: 'scheduled',
      notes: null,
    ),
    InterviewModel(
      id: 'int_5',
      candidateId: 'cand_5',
      candidateName: 'Thomas Durand',
      candidateAvatar: null,
      jobId: '4',
      jobTitle: 'Développeur Flutter',
      department: 'IT',
      scheduledDate: DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
      status: 'scheduled',
      notes: null,
    ),
  ];

  static final List<InterviewModel> _interviews = List.from(_mockData);

  @override
  Future<List<InterviewEntity>> getInterviews() async {
    // TODO(API): GET /api/v1/interviews
    await Future.delayed(const Duration(milliseconds: 500));
    return _interviews.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<InterviewEntity>> getUpcomingInterviews() async {
    // TODO(API): GET /api/v1/interviews?status=scheduled&upcoming=true
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return _interviews
        .where((m) => 
            m.status == 'scheduled' && 
            DateTime.parse(m.scheduledDate).isAfter(now))
        .map((m) => m.toEntity())
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<InterviewEntity?> getInterviewById(String id) async {
    // TODO(API): GET /api/v1/interviews/:id
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _interviews.firstWhere((m) => m.id == id).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<InterviewEntity> createInterview(InterviewEntity interview) async {
    // TODO(API): POST /api/v1/interviews  body: InterviewEntity serialisé
    await Future.delayed(const Duration(milliseconds: 400));
    final model = InterviewModel.fromEntity(interview);
    _interviews.add(model);
    return model.toEntity();
  }

  @override
  Future<InterviewEntity> updateInterview(InterviewEntity interview) async {
    // TODO(API): PUT /api/v1/interviews/:id  body: InterviewEntity serialisé
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _interviews.indexWhere((m) => m.id == interview.id);
    if (index >= 0) {
      final model = InterviewModel.fromEntity(interview);
      _interviews[index] = model;
      return model.toEntity();
    }
    throw Exception('Interview not found');
  }

  @override
  Future<void> cancelInterview(String id) async {
    // TODO(API): PATCH /api/v1/interviews/:id/cancel
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _interviews.indexWhere((m) => m.id == id);
    if (index >= 0) {
      final interview = _interviews[index];
      _interviews[index] = InterviewModel(
        id: interview.id,
        candidateId: interview.candidateId,
        candidateName: interview.candidateName,
        candidateAvatar: interview.candidateAvatar,
        jobId: interview.jobId,
        jobTitle: interview.jobTitle,
        scheduledDate: interview.scheduledDate,
        status: 'cancelled',
        notes: interview.notes,
      );
    }
  }

  @override
  Future<InterviewEntity> completeInterview(String id, String? notes) async {
    // TODO(API): PATCH /api/v1/interviews/:id/complete  body: { notes }
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _interviews.indexWhere((m) => m.id == id);
    if (index >= 0) {
      final interview = _interviews[index];
      final updated = InterviewModel(
        id: interview.id,
        candidateId: interview.candidateId,
        candidateName: interview.candidateName,
        candidateAvatar: interview.candidateAvatar,
        jobId: interview.jobId,
        jobTitle: interview.jobTitle,
        scheduledDate: interview.scheduledDate,
        status: 'completed',
        notes: notes ?? interview.notes,
      );
      _interviews[index] = updated;
      return updated.toEntity();
    }
    throw Exception('Interview not found');
  }
}
