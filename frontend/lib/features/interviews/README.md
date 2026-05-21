# Feature: Interviews (Entretiens)

## Vue d'ensemble
Ce feature gère les entretiens planifiés entre recruteurs et candidats.

## Architecture

```
interviews/
├── domain/
│   └── interview_entity.dart          # Entité métier
├── data/
│   ├── models/
│   │   └── interview_model.dart       # Modèle de données
│   ├── repositories/
│   │   ├── interviews_repository.dart      # Interface
│   │   └── interviews_repository_mock.dart # Implémentation mock
│   └── providers/
│       └── interviews_provider.dart   # Providers Riverpod
└── widgets/
    └── compact_interview_card.dart    # Carte entretien compacte
```

## Entité: InterviewEntity

### Attributs
- `id: String` - Identifiant unique
- `candidateId: String` - ID du candidat
- `candidateName: String` - Nom du candidat
- `candidateAvatar: String?` - Avatar du candidat
- `jobId: String` - ID de l'offre d'emploi
- `jobTitle: String` - Titre du poste
- `scheduledDate: DateTime` - Date et heure de l'entretien
- `status: String` - Statut (scheduled, completed, cancelled)
- `notes: String?` - Notes de l'entretien

### Méthodes
- `isScheduled: bool` - Si l'entretien est planifié
- `isCompleted: bool` - Si l'entretien est complété
- `isCancelled: bool` - Si l'entretien est annulé
- `formattedDate: String` - Date formatée (ex: "15 Mai")
- `formattedTime: String` - Heure formatée (ex: "14:30")

## Repository

### Méthodes disponibles
- `getInterviews()` - Récupère tous les entretiens
- `getUpcomingInterviews()` - Récupère les entretiens à venir
- `getInterviewById(id)` - Récupère un entretien par ID
- `createInterview(interview)` - Crée un nouvel entretien
- `updateInterview(interview)` - Met à jour un entretien
- `cancelInterview(id)` - Annule un entretien
- `completeInterview(id, notes)` - Marque un entretien comme complété

## Providers Riverpod

### interviewsNotifierProvider
Provider principal pour gérer l'état des entretiens.

```dart
final interviewsAsync = ref.watch(interviewsNotifierProvider);
```

### upcomingInterviewsProvider
Provider pour les 3 prochains entretiens à venir.

```dart
final upcomingAsync = ref.watch(upcomingInterviewsProvider);
```

## Widgets

### CompactInterviewCard
Carte horizontale compacte pour afficher un entretien.

**Props**:
- `interview: InterviewEntity` - L'entretien à afficher
- `onTap: VoidCallback?` - Action au clic

**Affichage**:
- Photo de profil du candidat (ou initiales)
- Nom du candidat
- Titre du poste
- Date et heure de l'entretien

## Utilisation

### Afficher les entretiens à venir
```dart
final upcomingAsync = ref.watch(upcomingInterviewsProvider);

upcomingAsync.when(
  data: (interviews) => Column(
    children: interviews.map((interview) => 
      CompactInterviewCard(
        interview: interview,
        onTap: () => navigateToDetails(interview),
      ),
    ).toList(),
  ),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Erreur: $e'),
);
```

### Créer un nouvel entretien
```dart
final repository = ref.read(interviewsRepositoryProvider);

final newInterview = InterviewEntity(
  id: 'int_${DateTime.now().millisecondsSinceEpoch}',
  candidateId: 'cand_123',
  candidateName: 'Jean Dupont',
  candidateAvatar: 'assets/images/avatar.png',
  jobId: 'job_456',
  jobTitle: 'Développeur Flutter',
  scheduledDate: DateTime(2026, 5, 20, 14, 30),
  status: 'scheduled',
);

await repository.createInterview(newInterview);
ref.read(interviewsNotifierProvider.notifier).fetch();
```

### Annuler un entretien
```dart
await ref.read(interviewsNotifierProvider.notifier).cancelInterview('int_1');
```

## Données Mock

Le repository mock contient 5 entretiens de démonstration avec différents candidats et postes.

## Intégration avec la homepage recruteur

Les entretiens à venir sont affichés dans la section "Activité" de la homepage recruteur, limitée aux 3 prochains entretiens.
