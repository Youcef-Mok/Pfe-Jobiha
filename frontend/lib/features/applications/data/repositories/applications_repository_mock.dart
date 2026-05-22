import 'package:job_app/features/applications/data/models/application_model.dart';
import 'package:job_app/features/applications/data/repositories/applications_repository.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';

// TODO(API): Remplacer par ApplicationsRepositoryHttp dans applications_provider.dart.
class ApplicationsRepositoryMock implements ApplicationsRepository {
  static final List<ApplicationModel> _data = [
    ApplicationModel(
      id: 'app1',
      jobId: '2',
      jobTitle: 'Product Manager',
      companyName: 'TechCorp Solutions',
      department: 'IT',
      logoAsset: 'assets/images/imageannonc(1).jpg',
      status: 'pending',
      appliedAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'cdi',
      scheduleLabel: '9h-17h',
      candidateName: 'Amélie Laurent',
      candidateAvatar: 'assets/images/pdp_1.png',
      candidateDomain: 'Gestion de produit',
      candidateRating: 4.7,
      motivationLetter: 'Passionnée par la gestion de produits digitaux, je souhaite mettre mon expertise au service de votre entreprise. Fort de 5 ans d\'expérience dans le domaine, j\'ai développé une approche centrée utilisateur qui a permis d\'augmenter l\'engagement de 40% sur mes projets précédents.\n\nMa capacité à coordonner des équipes pluridisciplinaires et à traduire les besoins métier en fonctionnalités concrètes sera un atout majeur pour vos projets. Je suis particulièrement intéressée par votre vision produit et votre approche innovante du marché.',
    ),
    ApplicationModel(
      id: 'app2',
      jobId: '4',
      jobTitle: 'Développeur Flutter',
      companyName: 'ServicePro',
      department: 'IT',
      logoAsset: 'assets/images/imageannonc(3).jpg',
      status: 'pending',
      appliedAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'cdi',
      scheduleLabel: '10h-17h',
      interviewDate: 'Entretien prévu le 18 Oct.',
      candidateName: 'Marc Dubois',
      candidateAvatar: 'assets/images/pdp_4.png',
      candidateDomain: 'Développement Mobile',
      candidateRating: 4.9,
      motivationLetter: 'Développeur Flutter passionné avec 3 ans d\'expérience, je maîtrise parfaitement le framework et les bonnes pratiques de développement mobile. J\'ai contribué à plusieurs applications à fort trafic disponibles sur les stores.\n\nMon expertise technique couvre l\'architecture clean, la gestion d\'état avec Riverpod, et l\'intégration d\'APIs REST. Je suis convaincu que mes compétences techniques et ma rigueur seront des atouts précieux pour vos projets mobiles.',
    ),
    ApplicationModel(
      id: 'app3',
      jobId: '5',
      jobTitle: 'UX Designer',
      companyName: 'Creative Agency',
      department: 'Design',
      logoAsset: 'assets/images/imageannonc(4).jpg',
      status: 'pending',
      appliedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'mission',
      scheduleLabel: '8h-16h',
      interviewDate: 'Entretien prévu le 18 Oct.',
      candidateName: 'Lucas Petit',
      candidateAvatar: 'assets/images/pdp_new.png',
      candidateDomain: 'Design UX/UI',
      candidateRating: 4.5,
      motivationLetter: 'Designer UX/UI avec une approche centrée utilisateur, je crée des expériences digitales intuitives et engageantes. Mon portfolio témoigne de ma capacité à transformer des problématiques complexes en interfaces simples et élégantes.\n\nJe maîtrise Figma, Adobe XD et les méthodologies de design thinking. Ma collaboration étroite avec les équipes de développement garantit une implémentation fidèle aux maquettes tout en respectant les contraintes techniques.',
    ),
    ApplicationModel(
      id: 'app4',
      jobId: '6',
      jobTitle: 'Chef de projet',
      companyName: 'BuildCorp',
      department: 'Opérations',
      logoAsset: 'assets/images/imageannonc(5).jpg',
      status: 'rejected',
      appliedAt: DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'cdi',
      scheduleLabel: '9h-18h',
      candidateName: 'Sophie Martin',
      candidateAvatar: 'assets/images/pdp_2.png',
      candidateDomain: 'Gestion de projet',
      candidateRating: 4.3,
      motivationLetter: 'Chef de projet expérimentée, je pilote avec succès des projets complexes en respectant les délais et les budgets. Ma méthodologie agile et ma capacité à fédérer les équipes ont permis de livrer plus de 20 projets d\'envergure.\n\nJe suis certifiée PMP et Scrum Master, et je possède une excellente maîtrise des outils de gestion de projet. Mon approche pragmatique et ma communication efficace sont des garanties de réussite pour vos projets.',
    ),
    ApplicationModel(
      id: 'app5',
      jobId: '2',
      jobTitle: 'Product Manager',
      companyName: 'TechCorp Solutions',
      logoAsset: 'assets/images/imageannonc(1).jpg',
      status: 'pending',
      appliedAt: DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'cdi',
      scheduleLabel: '9h-17h',
      candidateName: 'Thomas Durand',
      candidateAvatar: 'assets/images/pdp_3.png',
      candidateDomain: 'Product Management',
      candidateRating: 4.6,
      motivationLetter: 'Product Manager avec 4 ans d\'expérience dans le développement de produits SaaS. J\'ai une approche data-driven et une excellente compréhension des besoins utilisateurs.\n\nMa capacité à prioriser les fonctionnalités et à travailler en étroite collaboration avec les équipes techniques et commerciales a permis de lancer plusieurs produits à succès.',
    ),
    ApplicationModel(
      id: 'app6',
      jobId: '4',
      jobTitle: 'Développeur Flutter',
      companyName: 'ServicePro',
      logoAsset: 'assets/images/imageannonc(3).jpg',
      status: 'pending',
      appliedAt: DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'freelance',
      scheduleLabel: '10h-17h',
      candidateName: 'Emma Rousseau',
      candidateAvatar: 'assets/images/pdp_1.png',
      candidateDomain: 'Développement Mobile',
      candidateRating: 4.8,
      motivationLetter: 'Développeuse Flutter freelance avec une expertise en architecture clean et state management. J\'ai développé plus de 15 applications mobiles pour des clients variés.\n\nMa maîtrise de Dart, Flutter et des APIs REST me permet de livrer des applications performantes et maintenables. Je suis passionnée par l\'UX et l\'optimisation des performances.',
    ),
    ApplicationModel(
      id: 'app7',
      jobId: '5',
      jobTitle: 'UX Designer',
      companyName: 'Creative Agency',
      logoAsset: 'assets/images/imageannonc(4).jpg',
      status: 'pending',
      appliedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'mission',
      scheduleLabel: '8h-16h',
      candidateName: 'Karim Benali',
      candidateAvatar: 'assets/images/pdp_4.png',
      candidateDomain: 'Design UX/UI',
      candidateRating: 4.4,
      motivationLetter: 'Designer UX/UI passionné par la création d\'expériences utilisateur exceptionnelles. Mon portfolio démontre ma capacité à résoudre des problèmes complexes avec des solutions simples et élégantes.\n\nJe maîtrise Figma, Adobe XD et les méthodologies de design thinking. Ma collaboration avec les développeurs garantit une implémentation fidèle aux maquettes.',
    ),
    ApplicationModel(
      id: 'app8',
      jobId: '2',
      jobTitle: 'Product Manager',
      companyName: 'TechCorp Solutions',
      logoAsset: 'assets/images/imageannonc(1).jpg',
      status: 'pending',
      appliedAt: DateTime.now().subtract(const Duration(hours: 15)).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'cdi',
      scheduleLabel: '9h-17h',
      candidateName: 'Julie Bernard',
      candidateAvatar: 'assets/images/pdp_2.png',
      candidateDomain: 'Product Management',
      candidateRating: 4.5,
      motivationLetter: 'Product Manager expérimentée avec une forte orientation résultats. J\'ai piloté le lancement de 8 produits SaaS avec un taux de satisfaction client supérieur à 90%.\n\nMa méthodologie agile et ma capacité à analyser les données me permettent de prendre des décisions éclairées pour maximiser la valeur produit.',
    ),
    ApplicationModel(
      id: 'app9',
      jobId: '4',
      jobTitle: 'Développeur Flutter',
      companyName: 'ServicePro',
      logoAsset: 'assets/images/imageannonc(3).jpg',
      status: 'pending',
      appliedAt: DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'cdi',
      scheduleLabel: '10h-17h',
      candidateName: 'Alexandre Moreau',
      candidateAvatar: 'assets/images/pdp_3.png',
      candidateDomain: 'Développement Mobile',
      candidateRating: 4.7,
      motivationLetter: 'Développeur Flutter senior avec 5 ans d\'expérience. J\'ai une expertise approfondie en architecture MVVM, BLoC et Riverpod. Mes applications sont reconnues pour leur performance et leur maintenabilité.\n\nJe suis passionné par les bonnes pratiques de développement et le clean code. Mon expérience en CI/CD me permet de livrer des applications de qualité en continu.',
    ),
    ApplicationModel(
      id: 'app10',
      jobId: '5',
      jobTitle: 'UX Designer',
      companyName: 'Creative Agency',
      logoAsset: 'assets/images/imageannonc(4).jpg',
      status: 'pending',
      appliedAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'mission',
      scheduleLabel: '8h-16h',
      candidateName: 'Léa Fontaine',
      candidateAvatar: 'assets/images/pdp_1.png',
      candidateDomain: 'Design UX/UI',
      candidateRating: 4.6,
      motivationLetter: 'Designer UX/UI créative avec un sens aigu du détail. Je conçois des interfaces qui allient esthétique et fonctionnalité. Mon approche user-centric garantit des expériences optimales.\n\nJe maîtrise l\'ensemble du processus de design, de la recherche utilisateur aux tests d\'utilisabilité. Ma collaboration avec les équipes produit assure une cohérence parfaite.',
    ),
  ];

  static final List<ApplicationModel> _applications = List.from(_data);

  @override
  Future<List<ApplicationEntity>> getMyApplications() async {
    // TODO(API): GET /api/v1/applications
    await Future.delayed(const Duration(milliseconds: 500));
    return _applications.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ApplicationEntity> applyToJob(
    String jobId, {
    String? motivationLetter,
  }) async {
    // TODO(API): POST /api/v1/jobs/:jobId/apply
    await Future.delayed(const Duration(milliseconds: 400));
    final model = ApplicationModel(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      jobId: jobId,
      jobTitle: 'Nouveau poste',
      companyName: 'Entreprise',
      status: 'pending',
      appliedAt: DateTime.now().toIso8601String(),
      location: 'Alger',
      contractType: 'cdi',
      motivationLetter: motivationLetter,
    );
    _applications.add(model);
    return model.toEntity();
  }

  @override
  Future<void> cancelApplication(String applicationId) async {
    // TODO(API): DELETE /api/v1/applications/:applicationId
    await Future.delayed(const Duration(milliseconds: 300));
    _applications.removeWhere((a) => a.id == applicationId);
  }

  @override
  Future<void> acceptApplication(String applicationId) async {
    // TODO(API): PATCH /api/v1/applications/:applicationId/accept
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index != -1) {
      final app = _applications[index];
      _applications[index] = ApplicationModel(
        id: app.id,
        jobId: app.jobId,
        jobTitle: app.jobTitle,
        companyName: app.companyName,
        logoAsset: app.logoAsset,
        status: 'accepted',
        appliedAt: app.appliedAt,
        location: app.location,
        contractType: app.contractType,
        scheduleLabel: app.scheduleLabel,
        interviewDate: app.interviewDate,
        candidateName: app.candidateName,
        candidateAvatar: app.candidateAvatar,
        candidateDomain: app.candidateDomain,
        candidateRating: app.candidateRating,
        motivationLetter: app.motivationLetter,
      );
    }
  }

  @override
  Future<void> rejectApplication(String applicationId) async {
    // TODO(API): PATCH /api/v1/applications/:applicationId/reject
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index != -1) {
      final app = _applications[index];
      _applications[index] = ApplicationModel(
        id: app.id,
        jobId: app.jobId,
        jobTitle: app.jobTitle,
        companyName: app.companyName,
        logoAsset: app.logoAsset,
        status: 'rejected',
        appliedAt: app.appliedAt,
        location: app.location,
        contractType: app.contractType,
        scheduleLabel: app.scheduleLabel,
        interviewDate: app.interviewDate,
        candidateName: app.candidateName,
        candidateAvatar: app.candidateAvatar,
        candidateDomain: app.candidateDomain,
        candidateRating: app.candidateRating,
        motivationLetter: app.motivationLetter,
      );
    }
  }
}
