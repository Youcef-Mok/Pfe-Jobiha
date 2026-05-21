// ─────────────────────────────────────────────────────────────────────────────
// map_provider.dart — REDIRECT
//
// Le vrai fichier de providers est map_providers.dart (avec un 's').
// Ce fichier re-exporte tout pour éviter les imports cassés.
//
// TODO(API): Lors du branchement backend, modifier map_providers.dart :
//            - Remplacer MapRepositoryMock par MapRepositoryHttp
//            - Connecter allMapJobsProvider sur GET /api/jobs/map
//            - Connecter recentSearchesProvider sur GET/POST /api/searches
//            Puis supprimer ce fichier de redirection.
// ─────────────────────────────────────────────────────────────────────────────

export 'map_providers.dart';
