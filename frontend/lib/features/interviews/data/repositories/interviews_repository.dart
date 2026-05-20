import 'package:job_app/features/interviews/domain/interview_entity.dart';

/// Interface du repository pour les entretiens
abstract class InterviewsRepository {
  /// Récupère tous les entretiens
  Future<List<InterviewEntity>> getInterviews();

  /// Récupère les entretiens à venir
  Future<List<InterviewEntity>> getUpcomingInterviews();

  /// Récupère un entretien par son ID
  Future<InterviewEntity?> getInterviewById(String id);

  /// Crée un nouvel entretien
  Future<InterviewEntity> createInterview(InterviewEntity interview);

  /// Met à jour un entretien
  Future<InterviewEntity> updateInterview(InterviewEntity interview);

  /// Annule un entretien
  Future<void> cancelInterview(String id);

  /// Marque un entretien comme complété
  Future<InterviewEntity> completeInterview(String id, String? notes);
}
