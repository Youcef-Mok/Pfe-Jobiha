# Prompt — Seed base de données Jobiha (Algérie)

Copie-colle ce prompt à une IA (Claude / ChatGPT) et elle génère le script Django directement exécutable.

---

## PROMPT À COPIER :

Tu es un expert Django. Génère un fichier Python `seed.py` à placer à la racine du dossier `backend/` d'un projet Django.
Ce script doit être lancé avec `python seed.py` (il configure lui-même Django avant d'importer les modèles).

Le projet s'appelle **Jobiha** — une application de mise en relation entre **recruteurs** et **candidats** en Algérie, dans le secteur de la **restauration, hôtellerie et services**.

---

### Configuration Django à mettre en tête du script :

```python
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()
```

---

### Modèles disponibles (à importer ainsi) :

```python
from apps.users.models.utilisateur import Utilisateur
from apps.users.models.candidat import Candidat
from apps.users.models.recruteur import Recruteur
from apps.users.models.disponibilite import Disponibilite
from apps.jobs.models.offre import Offre
from apps.jobs.models.mission import Mission
from apps.applications.models.candidature import Candidature
```

---

### Ce que le script doit créer :

#### 1. Disponibilités (à créer d'abord)
Crée les disponibilités : `Matin`, `Après-midi`, `Soir`, `Nuit`, `Week-end`, `Jours fériés`

#### 2. Recruteurs (5 recruteurs algériens réalistes)
Champs : `nom`, `prenom`, `email`, `mot_de_passe` (hashé avec `make_password`), `telephone`, `latitude`, `longitude`, `location`, `bio`, `est_verifie=True`, `statut_compte='actif'`, `nom_structure`, `type_structure`, `description`, `note_globale`, `avatar_url`

Utilise ces données réalistes algériennes :
- **Karim Benali** — Restaurant Le Zitoun, Alger Centre (36.7372, 3.0865) — restaurant traditionnel algérien
- **Sonia Rahmani** — Hôtel El Aurassi, Alger (36.7538, 3.0588) — hôtel 5 étoiles
- **Mohamed Khelifi** — Brasserie Tafna, Oran (35.6987, 0.6349) — brasserie moderne
- **Amira Boukhelifa** — Café Literati, Constantine (36.3650, 6.6147) — café culturel
- **Yacine Messaoudi** — Catering Soleil d'Or, Annaba (36.9000, 7.7667) — traiteur événementiel

Pour `avatar_url` utilise des URLs Unsplash réalistes de portraits professionnels :
- `https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200`
- `https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200`
- `https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200`
- `https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200`
- `https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200`

#### 3. Candidats (8 candidats algériens réalistes)
Champs : `nom`, `prenom`, `email`, `mot_de_passe` (hashé), `telephone`, `latitude`, `longitude`, `location`, `bio`, `est_verifie=True`, `statut_compte='actif'`, `competences` (JSONField liste de strings), `experience`, `note_globale`, `titre_poste`, `domain`, `avatar_url`

Utilise ces données :
- **Amine Brahimi** — Serveur expérimenté, Alger, 4 ans d'expérience, compétences: ["Service en salle", "Accueil client", "Gestion caisse", "Anglais professionnel"]
- **Nadia Ouali** — Cuisinière, Alger, 6 ans, compétences: ["Cuisine algérienne", "Pâtisserie orientale", "Gestion des stocks", "HACCP"]
- **Sofiane Merad** — Barista, Oran, 2 ans, compétences: ["Préparation café", "Latte art", "Accueil client", "Caisse"]
- **Yasmine Hadjadj** — Réceptionniste hôtel, Alger, 3 ans, compétences: ["Accueil", "Anglais courant", "Français courant", "Opera PMS"]
- **Bilal Kaced** — Commis de cuisine, Constantine, 1 an, compétences: ["Cuisine froide", "Épluchage", "Nettoyage", "Aide pâtisserie"]
- **Meriem Benzitouni** — Serveuse, Annaba, 5 ans, compétences: ["Service banquet", "Sommellerie basique", "Encaissement", "Travail en équipe"]
- **Rami Slimani** — Chef de rang, Alger, 7 ans, compétences: ["Management équipe", "Service VIP", "Vins et spiritueux", "Formation junior"]
- **Lina Cherif** — Barman, Oran, 3 ans, compétences: ["Cocktails", "Gestion bar", "Fidélisation client", "Caisse"]

Pour `avatar_url` utilise des portraits Unsplash variés (hommes/femmes).
Assigne des disponibilités aléatoires à chaque candidat avec `candidat.disponibilites.set(...)`.

#### 4. Offres d'emploi (10 offres réalistes)
Champs : `titre`, `description`, `categorie`, `date_debut`, `date_fin`, `salaire`, `type_contrat`, `latitude`, `longitude`, `location`, `statut='searching'`, `is_published=True`, `candidate_count`, `recruteur`, `image_url`, `schedule_label`

Offres à créer (variées, réalistes pour l'Algérie) :
1. **Serveur en salle** — Le Zitoun, Alger — CDD — 45000 DA/mois — debut: dans 3 jours
2. **Chef de partie pâtisserie** — El Aurassi, Alger — CDI — 75000 DA/mois
3. **Réceptionniste nuit** — El Aurassi, Alger — CDD — 50000 DA/mois
4. **Barista** — Café Literati, Constantine — Temps partiel — 30000 DA/mois
5. **Commis de cuisine** — Brasserie Tafna, Oran — CDD — 38000 DA/mois
6. **Chef cuisinier** — Catering Soleil d'Or, Annaba — CDI — 90000 DA/mois
7. **Serveur événementiel** — Catering Soleil d'Or, Annaba — Freelance — 8000 DA/jour
8. **Barman** — Brasserie Tafna, Oran — CDI — 55000 DA/mois
9. **Agent d'accueil** — Café Literati, Constantine — Temps partiel — 25000 DA/mois
10. **Second de cuisine** — Le Zitoun, Alger — CDI — 65000 DA/mois

Pour `image_url` utilise des images Unsplash de restaurant/cuisine/hôtel.
Pour `schedule_label` utilise : `"Temps plein"`, `"Temps partiel"`, `"Week-end"`, `"Soir uniquement"`.

#### 5. Candidatures (10 candidatures variées)
Associe des candidats aux offres de manière logique (ex: Amine postule pour Serveur en salle).
Statuts variés : `"en_attente"`, `"acceptee"`, `"refusee"`.
Ajoute un `message_personnalise` réaliste en français algérien pour chacune.

#### 6. Missions (3 missions) 
Pour les candidatures avec statut `"acceptee"`, crée des missions :
- 1 mission `en_cours` (date_debut = il y a 2 jours)
- 1 mission `terminee` (date_debut = il y a 10 jours, date_fin = il y a 3 jours, duree_heures calculée)
- 1 mission `en_attente`

---

### Instructions importantes :
- Utilise `make_password` de `django.contrib.auth.hashers` pour hasher les mots de passe
- Mot de passe pour tous : `Test1234!`
- Utilise `get_or_create` pour éviter les doublons si le script est relancé
- Ajoute des `print()` pour montrer la progression
- À la fin affiche un résumé : nombre de recruteurs, candidats, offres, candidatures, missions créés
- Gère les dates avec `from datetime import date, datetime, timedelta` et `from django.utils import timezone`

---

### À la fin du fichier ajoute :
```python
if __name__ == '__main__':
    run()
```

Et encapsule tout dans une fonction `def run():`.
