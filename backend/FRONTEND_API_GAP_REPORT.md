# Audit Frontend -> API (TODO/API gaps)

Date: 2026-05-21

## Scope
- Analyse du dossier `frontend/lib/features/**`
- Extraction des `TODO(API)` et des implémentations `*RepositoryMock`
- Comparaison avec `backend/IMPLEMENTED_APIS.md`

## Résumé
- La majorité des logiques mock ont déjà un `TODO(API)` explicite.
- Les principaux manques sont des incohérences de route/méthode entre frontend et specs backend.
- Quelques logiques mock sont présentes sans endpoint final clairement verrouillé (cf. section "Manques à spécifier").

## Endpoints TODO détectés côté frontend (principaux)
- Applications: `GET /api/v1/applications`, `POST /api/v1/jobs/:jobId/apply`, `DELETE /api/v1/applications/:applicationId`, `PATCH /api/v1/applications/:applicationId/accept`, `PATCH /api/v1/applications/:applicationId/reject`
- Jobs/Missions: `GET /api/v1/jobs?published=true`, `GET /api/v1/jobs?published=true&q=`, `GET /api/v1/missions`, `POST /api/v1/missions`, `PATCH /api/v1/missions/:id/confirm`
- Users/Profile: `GET /api/v1/users/me`, `PUT /api/v1/users/me`, `GET /api/v1/users/:userId`, `GET /api/v1/users/:userId/reviews`, `GET /api/v1/users/:userId/cv`, `GET/POST/DELETE /api/v1/users/me/recent-searches`
- Notifications: `GET /api/v1/notifications`, `PATCH /api/v1/notifications/:id/read`, `DELETE /api/v1/notifications/:id`
- Interviews: `GET /api/v1/interviews`, `GET /api/v1/interviews/:id`, `POST /api/v1/interviews`, `PUT /api/v1/interviews/:id`, `PATCH /api/v1/interviews/:id/cancel`, `PATCH /api/v1/interviews/:id/complete`
- Messaging: `GET /api/v1/conversations`, `GET /api/v1/conversations/invitations`, `POST /api/v1/conversations/:id/messages`, `POST /api/v1/conversations/:id/accept`, `DELETE /api/v1/conversations`, `DELETE /api/v1/conversations/:id/invitation`, endpoints blocked/restricted users
- Map: `GET /api/v1/jobs/map?...` et aussi `GET /api/v1/map/jobs?...` (incohérence)
- Candidates: `GET /api/v1/jobs/:jobId/candidates`, `GET /api/v1/jobs/:jobId/candidates?status=`, `PATCH /api/v1/candidates/:candidateId/status`

## Incohérences Front <-> Specs backend
1. Applications apply
- Front TODO: `POST /api/v1/jobs/:jobId/apply`
- Specs backend: `POST /applications` ou `POST /jobs/:id/candidates`
- Action: choisir une route canonique et aligner frontend.

2. Interviews cancel
- Front TODO: `PATCH /api/v1/interviews/:id/cancel`
- Specs backend: `DELETE /interviews/:id`
- Action: ajouter alias PATCH ou migrer frontend vers DELETE.

3. Notifications read
- Front TODO: `PATCH /api/v1/notifications/:id/read`
- Specs backend: `PUT /notifications/:id/read`
- Action: accepter PATCH en alias ou corriger frontend en PUT.

4. Messaging invitation decline
- Front TODO: `DELETE /api/v1/conversations/:conversationId/invitation`
- Specs backend: `DELETE /conversations/:id/decline`
- Action: unifier le path.

5. Messaging bulk delete
- Front TODO: `DELETE /api/v1/conversations` body `{ ids }`
- Specs backend: `DELETE /conversations/delete` body `{ ids }`
- Action: unifier le path.

6. Messaging accept invitation
- Front TODO: `POST /api/v1/conversations/:conversationId/accept`
- Specs backend: `PUT /conversations/:id/accept`
- Action: unifier la méthode HTTP.

7. Messaging media upload
- Front TODO: `POST /conversations/:id/messages` multipart + `type=image|file`
- Specs backend: endpoints séparés `/messages/image` et `/messages/file`
- Action: choisir stratégie unique.

8. Map endpoint
- Front TODO mixte: `/jobs/map` et `/map/jobs`
- Specs backend: `/jobs/map`
- Action: garder `/jobs/map` partout frontend.

## Manques à spécifier (ajoutés dans IMPLEMENTED_APIS)
- `PATCH /candidates/:candidateId/status`
- `POST /jobs/:jobId/apply` (ou alias officiel vers `/applications`)
- Alias compatibilité frontend:
  - `PATCH /interviews/:id/cancel`
  - `PATCH /notifications/:id/read`
  - `POST /conversations/:id/accept`
  - `DELETE /conversations/:id/invitation`
  - `DELETE /conversations` (bulk body `{ ids }`)

## Remarque importante
- Certains fichiers mock contiennent une logique métier locale conséquente; même avec TODO présents, il faudra définir précisément les payloads/réponses JSON finaux avant remplacement 1:1.
