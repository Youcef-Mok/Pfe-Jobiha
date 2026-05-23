"""
Management command to seed the database with realistic Algerian test data.

Usage:
    python manage.py seed_db           # seed (skip existing by email)
    python manage.py seed_db --flush   # delete all existing data first
"""

from datetime import date, timedelta
from django.core.management.base import BaseCommand
from django.contrib.auth.hashers import make_password
from django.utils import timezone
from django.db import transaction


PASSWORD = make_password("Test1234!")

# ---------------------------------------------------------------------------
# Unsplash image helpers
# ---------------------------------------------------------------------------

RECRUITER_AVATARS = [
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200",
    "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200",
]

RECRUITER_LOGOS = [
    "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400",
    "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400",
    "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400",
    "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400",
    "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400",
]

CANDIDATE_AVATARS = [
    "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=200",
    "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=200",
    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200",
    "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200",
    "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200",
    "https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=200",
    "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200",
    "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200",
]

JOB_IMAGES = [
    "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600",
    "https://images.unsplash.com/photo-1571197119738-40f3cb9e11a1?w=600",
    "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600",
    "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=600",
    "https://images.unsplash.com/photo-1607631568010-a87245c0daf8?w=600",
    "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600",
    "https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=600",
    "https://images.unsplash.com/photo-1516997121675-4c2d1684aa3e?w=600",
    "https://images.unsplash.com/photo-1559925393-8be0ec4767c8?w=600",
    "https://images.unsplash.com/photo-1481931098730-318b6f776db0?w=600",
]

MISSION_IMAGES = [
    "https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=600",
    "https://images.unsplash.com/photo-1551218808-94e220e084d2?w=600",
    "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600",
    "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600",
]


class Command(BaseCommand):
    help = "Seed the database with realistic Algerian test data"

    def add_arguments(self, parser):
        parser.add_argument(
            "--flush",
            action="store_true",
            help="Delete all existing seed data before inserting",
        )

    @transaction.atomic
    def handle(self, *args, **options):
        if options["flush"]:
            self._flush()

        self.stdout.write("\n[SEED] Demarrage du seeding...\n")

        dispos      = self._create_disponibilites()
        recruteurs  = self._create_recruteurs()
        candidats   = self._create_candidats(dispos)
        offres      = self._create_offres(recruteurs)
        candidatures = self._create_candidatures(candidats, offres)
        missions    = self._create_missions(candidatures)
        reviews     = self._create_reviews(missions)
        self._create_cv_data(candidats)
        self._create_interviews(candidats, recruteurs, offres)
        self._create_comments(offres, candidats, recruteurs)
        self._create_conversations(candidats, recruteurs)

        self.stdout.write(self.style.SUCCESS(
            f"\n[OK] Seeding termine :\n"
            f"   Disponibilites : {len(dispos)}\n"
            f"   Recruteurs     : {len(recruteurs)}\n"
            f"   Candidats      : {len(candidats)}\n"
            f"   Offres         : {len(offres)}\n"
            f"   Candidatures   : {len(candidatures)}\n"
            f"   Missions       : {len(missions)}\n"
            f"   Reviews        : {len(reviews)}\n"
        ))

    # ------------------------------------------------------------------
    # Flush
    # ------------------------------------------------------------------

    def _flush(self):
        from apps.jobs.models import Mission, Interview, JobComment, Offre
        from apps.applications.models import Candidature
        from apps.users.models import Candidat, Recruteur, Disponibilite
        from apps.reviews.models.evaluation import Evaluation
        from apps.users.models.cv_formation import CvFormation
        from apps.users.models.cv_experience import CvExperience
        from apps.users.models.candidate_language import CandidateLanguage
        from apps.users.models.candidate_skill import CandidateSkillGroup
        from apps.messaging.models import Conversation

        self.stdout.write("[FLUSH] Suppression des donnees existantes...")
        Evaluation.objects.all().delete()
        Mission.objects.all().delete()
        Interview.objects.all().delete()
        JobComment.objects.all().delete()
        Candidature.objects.all().delete()
        Offre.objects.all().delete()
        CvFormation.objects.all().delete()
        CvExperience.objects.all().delete()
        CandidateLanguage.objects.all().delete()
        CandidateSkillGroup.objects.all().delete()
        Conversation.objects.all().delete()
        Candidat.objects.all().delete()
        Recruteur.objects.all().delete()
        Disponibilite.objects.all().delete()
        self.stdout.write("   OK\n")

    # ------------------------------------------------------------------
    # 1. Disponibilites
    # ------------------------------------------------------------------

    def _create_disponibilites(self):
        from apps.users.models import Disponibilite

        slots = [
            ("Matin",        "06:00", "12:00"),
            ("Apres-midi",   "12:00", "18:00"),
            ("Soir",         "18:00", "23:00"),
            ("Nuit",         "23:00", "06:00"),
            ("Week-end",     "08:00", "20:00"),
            ("Jours feries", "08:00", "20:00"),
        ]

        dispos = []
        for jour, debut, fin in slots:
            obj, created = Disponibilite.objects.get_or_create(
                jour=jour,
                defaults={"heure_debut": debut, "heure_fin": fin},
            )
            dispos.append(obj)
            self.stdout.write(f"   Disponibilite '{jour}' — {'cree' if created else 'existant'}")

        self.stdout.write(f"   >>{len(dispos)} disponibilites\n")
        return dispos

    # ------------------------------------------------------------------
    # 2. Recruteurs
    # ------------------------------------------------------------------

    def _create_recruteurs(self):
        from apps.users.models import Recruteur

        data = [
            dict(
                email="karim.benali@lezitoun.dz",
                nom="Benali", prenom="Karim",
                telephone="+213550112233",
                latitude=36.7372, longitude=3.0865,
                location="Alger Centre, Alger",
                bio="Directeur du restaurant Le Zitoun, specialiste de la gastronomie algerienne traditionnelle depuis 15 ans.",
                nom_structure="Restaurant Le Zitoun",
                type_structure="Restaurant",
                description="Restaurant traditionnel algerien situe en plein coeur d'Alger Centre. Cuisine authentique du terroir, ambiance chaleureuse et service de qualite.",
                note_globale=4.7,
                avatar_url=RECRUITER_AVATARS[0],
                logo_url=RECRUITER_LOGOS[0],
                titre_poste="Directeur de restaurant",
                domain="Restauration",
            ),
            dict(
                email="sonia.rahmani@elaurassi.dz",
                nom="Rahmani", prenom="Sonia",
                telephone="+213661223344",
                latitude=36.7538, longitude=3.0588,
                location="Ben Aknoun, Alger",
                bio="Directrice des ressources humaines a l'Hotel El Aurassi 5 etoiles. 10 ans d'experience en RH hotelier.",
                nom_structure="Hotel El Aurassi",
                type_structure="Hotellerie",
                description="Hotel 5 etoiles emblematique d'Alger offrant une vue panoramique sur la baie. Standards internationaux, spa, restaurants gastronomiques.",
                note_globale=4.9,
                avatar_url=RECRUITER_AVATARS[1],
                logo_url=RECRUITER_LOGOS[1],
                titre_poste="DRH",
                domain="Hotellerie",
            ),
            dict(
                email="mohamed.khelifi@tafna.dz",
                nom="Khelifi", prenom="Mohamed",
                telephone="+213771334455",
                latitude=35.6987, longitude=0.6349,
                location="Oran",
                bio="Gerant de la Brasserie Tafna, reference de la restauration moderne a Oran depuis 2010.",
                nom_structure="Brasserie Tafna",
                type_structure="Brasserie",
                description="Brasserie moderne au coeur d'Oran, melant cuisine mediterraneenne et influences algeriennes. Terrasse, bar, brunch dominical.",
                note_globale=4.5,
                avatar_url=RECRUITER_AVATARS[2],
                logo_url=RECRUITER_LOGOS[2],
                titre_poste="Gerant",
                domain="Restauration",
            ),
            dict(
                email="amira.boukhelifa@literati.dz",
                nom="Boukhelifa", prenom="Amira",
                telephone="+213550445566",
                latitude=36.3650, longitude=6.6147,
                location="Constantine",
                bio="Fondatrice du Cafe Literati, espace culturel et cafe de specialite a Constantine depuis 2018.",
                nom_structure="Cafe Literati",
                type_structure="Cafe",
                description="Cafe culturel unique a Constantine alliant specialites de cafe, librairie et expositions d'art. Lieu de rencontre pour intellectuels et artistes.",
                note_globale=4.8,
                avatar_url=RECRUITER_AVATARS[3],
                logo_url=RECRUITER_LOGOS[3],
                titre_poste="Fondatrice & Gerante",
                domain="Cafe & Culture",
            ),
            dict(
                email="yacine.messaoudi@soleil-dor.dz",
                nom="Messaoudi", prenom="Yacine",
                telephone="+213661556677",
                latitude=36.9000, longitude=7.7667,
                location="Annaba",
                bio="PDG du Traiteur Soleil d'Or, leader de la restauration evenementielle a Annaba depuis 2005.",
                nom_structure="Traiteur Soleil d'Or",
                type_structure="Traiteur",
                description="Entreprise evenementielle specialisee dans les mariages, seminaires et galas. Capacite jusqu'a 2000 couverts. Service cle en main.",
                note_globale=4.6,
                avatar_url=RECRUITER_AVATARS[4],
                logo_url=RECRUITER_LOGOS[4],
                titre_poste="PDG",
                domain="Evenementiel",
            ),
        ]

        recruteurs = []
        for d in data:
            obj, created = Recruteur.objects.get_or_create(
                email=d["email"],
                defaults={**d, "mot_de_passe": PASSWORD, "est_verifie": True, "statut_compte": "actif"},
            )
            if not created:
                # Update fields that may be missing
                updated = False
                for field in ("bio", "nom_structure", "description", "logo_url", "avatar_url", "titre_poste", "domain"):
                    if field in d and not getattr(obj, field, None):
                        setattr(obj, field, d[field])
                        updated = True
                if updated:
                    obj.save()
            recruteurs.append(obj)
            self.stdout.write(f"   Recruteur {obj.prenom} {obj.nom} — {'cree' if created else 'existant'}")

        self.stdout.write(f"   >>{len(recruteurs)} recruteurs\n")
        return recruteurs

    # ------------------------------------------------------------------
    # 3. Candidats
    # ------------------------------------------------------------------

    def _create_candidats(self, dispos):
        from apps.users.models import Candidat
        import random

        data = [
            dict(
                email="amine.brahimi@gmail.com",
                nom="Brahimi", prenom="Amine",
                telephone="+213550778899",
                latitude=36.7372, longitude=3.0865,
                location="Alger",
                bio="Serveur passionne avec 4 ans d'experience dans la restauration haut de gamme algeroiser. Ponctuel, souriant et professionnel.",
                titre_poste="Serveur en salle",
                domain="Restauration",
                experience="4 ans d'experience en service en salle dans des etablissements 4 et 5 etoiles.",
                competences=["Service en salle", "Accueil client", "Gestion caisse", "Anglais professionnel"],
                note_globale=4.6,
                avatar_url=CANDIDATE_AVATARS[0],
            ),
            dict(
                email="nadia.ouali@gmail.com",
                nom="Ouali", prenom="Nadia",
                telephone="+213661889900",
                latitude=36.7500, longitude=3.0420,
                location="Alger",
                bio="Cuisiniere specialisee dans la gastronomie algerienne et la patisserie orientale. Maitrise parfaite des normes HACCP.",
                titre_poste="Cuisiniere",
                domain="Cuisine",
                experience="6 ans d'experience en cuisine, dont 3 ans en tant que chef de partie patisserie.",
                competences=["Cuisine algerienne", "Patisserie orientale", "Gestion des stocks", "HACCP"],
                note_globale=4.8,
                avatar_url=CANDIDATE_AVATARS[1],
            ),
            dict(
                email="sofiane.merad@gmail.com",
                nom="Merad", prenom="Sofiane",
                telephone="+213771990011",
                latitude=35.6987, longitude=0.6349,
                location="Oran",
                bio="Barista certifie, passionne par le cafe de specialite et le latte art. Experience en cafes branches d'Oran.",
                titre_poste="Barista",
                domain="Cafe & Bar",
                experience="2 ans d'experience en tant que barista dans des cafes de specialite.",
                competences=["Preparation cafe", "Latte art", "Accueil client", "Caisse"],
                note_globale=4.3,
                avatar_url=CANDIDATE_AVATARS[2],
            ),
            dict(
                email="yasmine.hadjadj@gmail.com",
                nom="Hadjadj", prenom="Yasmine",
                telephone="+213550001122",
                latitude=36.7538, longitude=3.0588,
                location="Alger",
                bio="Receptionniste hoteliere bilingue (francais/anglais), formee sur le logiciel Opera PMS. Excellent sens du service client.",
                titre_poste="Receptionniste hotel",
                domain="Hotellerie",
                experience="3 ans d'experience en reception hoteliere dans des etablissements classes.",
                competences=["Accueil", "Anglais courant", "Francais courant", "Opera PMS"],
                note_globale=4.7,
                avatar_url=CANDIDATE_AVATARS[3],
            ),
            dict(
                email="bilal.kaced@gmail.com",
                nom="Kaced", prenom="Bilal",
                telephone="+213661223300",
                latitude=36.3650, longitude=6.6147,
                location="Constantine",
                bio="Jeune commis de cuisine dynamique et motive. Premiere experience reussie dans un restaurant gastronomique de Constantine.",
                titre_poste="Commis de cuisine",
                domain="Cuisine",
                experience="1 an d'experience en tant que commis de cuisine.",
                competences=["Cuisine froide", "Epluchage", "Nettoyage", "Aide patisserie"],
                note_globale=3.9,
                avatar_url=CANDIDATE_AVATARS[4],
            ),
            dict(
                email="meriem.benzitouni@gmail.com",
                nom="Benzitouni", prenom="Meriem",
                telephone="+213771334400",
                latitude=36.9000, longitude=7.7667,
                location="Annaba",
                bio="Serveuse experimentee specialisee dans les banquets et evenements haut de gamme. Connaissance en sommellerie.",
                titre_poste="Serveuse",
                domain="Restauration",
                experience="5 ans d'experience en service, dont 3 ans en banquet et evenementiel.",
                competences=["Service banquet", "Sommellerie basique", "Encaissement", "Travail en equipe"],
                note_globale=4.5,
                avatar_url=CANDIDATE_AVATARS[5],
            ),
            dict(
                email="rami.slimani@gmail.com",
                nom="Slimani", prenom="Rami",
                telephone="+213550445500",
                latitude=36.7372, longitude=3.0865,
                location="Alger",
                bio="Chef de rang chevronn avec 7 ans d'experience dans des restaurants etoiles et etablissements VIP. Leadership reconnu.",
                titre_poste="Chef de rang",
                domain="Restauration",
                experience="7 ans d'experience en restauration de prestige, management d'equipe, service VIP.",
                competences=["Management equipe", "Service VIP", "Vins et spiritueux", "Formation junior"],
                note_globale=4.9,
                avatar_url=CANDIDATE_AVATARS[6],
            ),
            dict(
                email="lina.cherif@gmail.com",
                nom="Cherif", prenom="Lina",
                telephone="+213661556600",
                latitude=35.6987, longitude=0.6349,
                location="Oran",
                bio="Barmane creative avec 3 ans d'experience en mixologie. Maitrise des cocktails classiques et signatures. Excellente relation client.",
                titre_poste="Barman",
                domain="Cafe & Bar",
                experience="3 ans d'experience derriere le bar dans des etablissements tendance d'Oran.",
                competences=["Cocktails", "Gestion bar", "Fidelisation client", "Caisse"],
                note_globale=4.4,
                avatar_url=CANDIDATE_AVATARS[7],
            ),
        ]

        candidats = []
        for i, d in enumerate(data):
            competences = d.pop("competences")
            note = d.pop("note_globale")
            obj, created = Candidat.objects.get_or_create(
                email=d["email"],
                defaults={
                    **d,
                    "mot_de_passe": PASSWORD,
                    "est_verifie": True,
                    "statut_compte": "actif",
                    "competences": competences,
                    "note_globale": note,
                },
            )
            if not created:
                updated = False
                for field in ("bio", "titre_poste", "domain", "experience", "avatar_url"):
                    if field in d and not getattr(obj, field, None):
                        setattr(obj, field, d[field])
                        updated = True
                if not obj.competences:
                    obj.competences = competences
                    updated = True
                if updated:
                    obj.save()
            if created:
                nb = random.randint(2, 4)
                choix = random.sample(dispos, min(nb, len(dispos)))
                obj.disponibilites.set(choix)

            candidats.append(obj)
            self.stdout.write(f"   Candidat {obj.prenom} {obj.nom} — {'cree' if created else 'existant'}")

        self.stdout.write(f"   >>{len(candidats)} candidats\n")
        return candidats

    # ------------------------------------------------------------------
    # 4. Offres d'emploi
    # ------------------------------------------------------------------

    def _create_offres(self, recruteurs):
        from apps.jobs.models import Offre

        today = date.today()
        r = recruteurs

        offres_data = [
            dict(titre="Serveur en salle", description="Le Restaurant Le Zitoun recherche un serveur en salle experimente. Accueil clients, prise de commandes, service en salle dans le respect des standards de la maison.", categorie="Service en salle", date_debut=today + timedelta(days=3), date_fin=today + timedelta(days=93), salaire=45000, type_contrat="cdd", latitude=36.7372, longitude=3.0865, location="Alger Centre, Alger", candidate_count=2, image_url=JOB_IMAGES[0], schedule_label="Temps plein", recruteur=r[0]),
            dict(titre="Chef de partie patisserie", description="L'Hotel El Aurassi recrute un chef de partie patisserie pour son restaurant gastronomique. Maitrise patisserie classique et orientale, autonomie, encadrement commis.", categorie="Patisserie", date_debut=today + timedelta(days=7), date_fin=None, salaire=75000, type_contrat="cdi", latitude=36.7538, longitude=3.0588, location="Ben Aknoun, Alger", candidate_count=1, image_url=JOB_IMAGES[1], schedule_label="Temps plein", recruteur=r[1]),
            dict(titre="Receptionniste de nuit", description="Hotel El Aurassi recherche receptionniste de nuit (23h-7h). Check-in/check-out nocturnes, securite etablissement. Opera PMS requis. Anglais indispensable.", categorie="Reception", date_debut=today + timedelta(days=5), date_fin=today + timedelta(days=185), salaire=50000, type_contrat="cdd", latitude=36.7538, longitude=3.0588, location="Ben Aknoun, Alger", candidate_count=1, image_url=JOB_IMAGES[2], schedule_label="Soir uniquement", recruteur=r[1]),
            dict(titre="Barista", description="Le Cafe Literati de Constantine cherche un barista passionne. Preparation cafes de specialite, latte art, accueil client dans un cadre culturel unique.", categorie="Cafe & Bar", date_debut=today + timedelta(days=1), date_fin=today + timedelta(days=120), salaire=30000, type_contrat="cdd", latitude=36.3650, longitude=6.6147, location="Constantine", candidate_count=1, image_url=JOB_IMAGES[3], schedule_label="Temps partiel", recruteur=r[3]),
            dict(titre="Commis de cuisine", description="Brasserie Tafna d'Oran recrute un commis de cuisine. Assistance chef, preparation plats, entretien poste, normes HACCP. Debutants motives acceptes.", categorie="Cuisine", date_debut=today + timedelta(days=2), date_fin=today + timedelta(days=90), salaire=38000, type_contrat="cdd", latitude=35.6987, longitude=0.6349, location="Oran", candidate_count=2, image_url=JOB_IMAGES[4], schedule_label="Temps plein", recruteur=r[2]),
            dict(titre="Chef cuisinier", description="Traiteur Soleil d'Or d'Annaba recherche chef cuisinier confirme. Direction brigade 8 personnes, elaboration menus banquet, garantie qualite. Experience traiteur exigee.", categorie="Cuisine", date_debut=today + timedelta(days=14), date_fin=None, salaire=90000, type_contrat="cdi", latitude=36.9000, longitude=7.7667, location="Annaba", candidate_count=1, image_url=JOB_IMAGES[5], schedule_label="Temps plein", recruteur=r[4]),
            dict(titre="Serveur evenementiel", description="Traiteur Soleil d'Or recrute serveurs freelance pour mariages, galas et seminaires. Missions ponctuelles, tenue fournie. Experience banquet souhaitee.", categorie="Service en salle", date_debut=today, date_fin=today + timedelta(days=60), salaire=8000, type_contrat="freelance", latitude=36.9000, longitude=7.7667, location="Annaba", candidate_count=5, image_url=JOB_IMAGES[6], schedule_label="Week-end", recruteur=r[4]),
            dict(titre="Barman", description="Brasserie Tafna d'Oran recherche barman creatif. Gestion bar en autonomie, carte cocktails de saison, fidelisation clientele. Maitrise mixologie requise.", categorie="Cafe & Bar", date_debut=today + timedelta(days=10), date_fin=None, salaire=55000, type_contrat="cdi", latitude=35.6987, longitude=0.6349, location="Oran", candidate_count=1, image_url=JOB_IMAGES[7], schedule_label="Soir uniquement", recruteur=r[2]),
            dict(titre="Agent d'accueil", description="Cafe Literati de Constantine cherche agent d'accueil a temps partiel. Gestion entree, orientation visiteurs evenements culturels, caisse. Ideal etudiant.", categorie="Accueil", date_debut=today, date_fin=today + timedelta(days=180), salaire=25000, type_contrat="cdd", latitude=36.3650, longitude=6.6147, location="Constantine", candidate_count=1, image_url=JOB_IMAGES[8], schedule_label="Temps partiel", recruteur=r[3]),
            dict(titre="Second de cuisine", description="Restaurant Le Zitoun recrute second de cuisine. Supervision brigade, garantie constance recettes, formation commis. Experience cuisine algerienne requise.", categorie="Cuisine", date_debut=today + timedelta(days=21), date_fin=None, salaire=65000, type_contrat="cdi", latitude=36.7372, longitude=3.0865, location="Alger Centre, Alger", candidate_count=1, image_url=JOB_IMAGES[9], schedule_label="Temps plein", recruteur=r[0]),
        ]

        offres = []
        for d in offres_data:
            obj, created = Offre.objects.get_or_create(
                titre=d["titre"],
                recruteur=d["recruteur"],
                defaults={**d, "statut": "searching", "is_published": True, "view_count": 0},
            )
            offres.append(obj)
            self.stdout.write(f"   Offre '{obj.titre}' — {'creee' if created else 'existante'}")

        self.stdout.write(f"   >>{len(offres)} offres\n")
        return offres

    # ------------------------------------------------------------------
    # 5. Candidatures
    # ------------------------------------------------------------------

    def _create_candidatures(self, candidats, offres):
        from apps.applications.models import Candidature

        plans = [
            # Offre 0 — Serveur en salle (Le Zitoun / Karim)
            (0, 0, "en_attente",  "Passionne par le service en salle depuis 4 ans, je postule avec enthousiasme pour ce poste chez Le Zitoun."),
            (6, 0, "en_attente",  "Chef de rang avec 7 ans d'experience en etablissements de prestige, je serais heureux de rejoindre Le Zitoun."),
            # Offre 1 — Chef de partie patisserie (El Aurassi / Sonia)
            (1, 1, "acceptee",    "Votre offre de Chef de partie patisserie a El Aurassi correspond parfaitement a mon profil. 6 ans d'experience."),
            (4, 1, "en_attente",  "Passionne de patisserie, je souhaite evoluer vers un etablissement 5 etoiles. Maitrise parfaite des bases classiques."),
            # Offre 2 — Receptionniste de nuit (El Aurassi / Sonia)
            (3, 2, "acceptee",    "Je candidate pour le poste de Receptionniste de nuit. Maitrisant Opera PMS et bilingue."),
            (6, 2, "en_attente",  "Disponible pour les horaires de nuit, j'ai 2 ans d'experience en receptiom hoteliere et maitrise l'anglais."),
            # Offre 3 — Barista (Cafe Literati / Amira)
            (2, 3, "en_attente",  "Barista passionne par le cafe de specialite. Mon latte art et ma connaissance des origines de cafe proposeront une experience unique."),
            (0, 3, "en_attente",  "Certifie barista niveau 2, je maitrise l'espresso, le latte art et les cafes de specialite d'Afrique et d'Amerique du Sud."),
            # Offre 4 — Commis de cuisine (Brasserie Tafna / Mohamed)
            (4, 4, "refusee",     "Jeune commis motive, je cherche une opportunite a la Brasserie Tafna."),
            (5, 4, "en_attente",  "Titulaire d'un CAP cuisine, je cherche a intégrer une brigade dynamique pour progresser rapidement."),
            # Offre 5 — Chef cuisinier (Traiteur Soleil d'Or / Yacine)
            (1, 5, "refusee",     "Chef cuisiniere avec longue experience en cuisine algerienne, je postule chez Traiteur Soleil d'Or."),
            (7, 5, "en_attente",  "Chef cuisine passionne par la gastronomie algerienne, je souhaite diriger une brigade dans un contexte evenementiel."),
            # Offre 6 — Serveur evenementiel (Traiteur Soleil d'Or / Yacine)
            (5, 6, "acceptee",    "Serveuse experimentee dans les banquets et evenements, je postule pour vos missions freelance."),
            (4, 6, "en_attente",  "Disponible les week-ends et feries, j'ai effectue plusieurs missions de service en banquet."),
            # Offre 7 — Barman (Brasserie Tafna / Mohamed)
            (7, 7, "acceptee",    "Barman passionne par la mixologie, je postule pour la Brasserie Tafna."),
            (2, 7, "en_attente",  "Barman avec 3 ans d'experience en rooftop bar. Maitrise cocktails classiques et signatures."),
            # Offre 8 — Agent d'accueil (Cafe Literati / Amira)
            (3, 8, "en_attente",  "Etudiante en tourisme, je cherche un poste d'accueil a temps partiel compatible avec mes etudes."),
            (6, 8, "en_attente",  "Dynamique et souriant, j'ai une experience d'accueil lors d'evenements culturels a Alger."),
            # Offre 9 — Second de cuisine (Le Zitoun / Karim)
            (0, 9, "en_attente",  "Second de cuisine experimente, je souhaite mettre mes competences au service du Restaurant Le Zitoun."),
            (3, 9, "en_attente",  "Forte experience en cuisine algerienne traditionnelle, je cherche a evoluer vers un poste de supervision."),
        ]

        candidatures = []
        for ci, oi, statut, msg in plans:
            candidat = candidats[ci]
            offre = offres[oi]
            obj, created = Candidature.objects.get_or_create(
                candidat=candidat,
                offre=offre,
                defaults={"statut": statut, "message_personnalise": msg},
            )
            candidatures.append(obj)
            self.stdout.write(f"   Candidature {candidat.prenom} -> '{offre.titre}' [{statut}] — {'creee' if created else 'existante'}")

        self.stdout.write(f"   >>{len(candidatures)} candidatures\n")
        return candidatures

    # ------------------------------------------------------------------
    # 6. Missions  (toutes les candidatures acceptees)
    # ------------------------------------------------------------------

    def _create_missions(self, candidatures):
        from apps.jobs.models import Mission

        now = timezone.now()
        accepted = [c for c in candidatures if c.statut == "acceptee"]

        # (statut, debut_offset_days, fin_offset_days, summary_tpl)
        configs = [
            ("terminee", -15,  -5, "Mission terminee avec succes"),
            ("terminee", -20,  -8, "Mission terminee — excellent travail"),
            ("en_cours", -3,  None, "Mission en cours — bonne progression"),
            ("en_attente", None, None, "Mission planifiee — demarrage imminent"),
        ]

        missions = []
        for i, cand in enumerate(accepted):
            cfg = configs[i] if i < len(configs) else ("en_cours", -1, None, "Mission en cours")
            statut, debut_off, fin_off, summary_tpl = cfg

            date_debut = (now + timedelta(days=debut_off)) if debut_off is not None else None
            date_fin   = (now + timedelta(days=fin_off))   if fin_off   is not None else None
            duree = None
            if date_debut and date_fin:
                duree = round((date_fin - date_debut).total_seconds() / 3600, 2)

            try:
                obj = cand.mission
                self.stdout.write(f"   Mission #{obj.id} — existante")
            except Mission.DoesNotExist:
                obj = Mission.objects.create(
                    candidature=cand,
                    statut=statut,
                    date_debut=date_debut,
                    date_fin=date_fin,
                    duree_heures=duree,
                    location=cand.offre.location or "",
                    image_url=MISSION_IMAGES[i % len(MISSION_IMAGES)],
                    summary=f"{summary_tpl} — {cand.offre.titre} chez {cand.offre.recruteur.nom_structure}.",
                )
                self.stdout.write(f"   Mission #{obj.id} [{statut}] — creee")

            missions.append(obj)

        self.stdout.write(f"   >>{len(missions)} missions\n")
        return missions

    # ------------------------------------------------------------------
    # 7. Reviews / Evaluations  (missions terminees uniquement)
    # ------------------------------------------------------------------

    def _create_reviews(self, missions):
        from apps.reviews.models.evaluation import Evaluation

        # Reviews data: (mission_index, note_candidat_par_recruteur, commentaire_recruteur, note_recruteur_par_candidat, commentaire_candidat)
        reviews_data = [
            (
                0,
                # Recruteur evalue le candidat
                5, "Nadia est une professionnelle exceptionnelle. Maitrise parfaite de la patisserie orientale, rigoureuse et toujours souriante. Je la recommande sans hesitation.",
                # Candidat evalue le recruteur
                5, "Une experience incroyable a l'Hotel El Aurassi. L'equipe est soudee, le management exemplaire. Sonia est une DRH a l'ecoute et bienveillante. Je reviendrai avec plaisir !",
            ),
            (
                1,
                # Recruteur evalue le candidat
                4, "Yasmine est une excellente receptionniste, tres professionnelle et reactive. Tres bonne maitrise d'Opera PMS. Quelques petits ajustements sur la gestion des situations de crise.",
                # Candidat evalue le recruteur
                5, "Mission fantastique a El Aurassi. Equipe accueillante, formation complete a l'arrivee. Sonia Rahmani est une professionnelle exemplaire qui valorise ses employes.",
            ),
        ]

        created_reviews = []
        for mission_idx, note_cand, comm_rec, note_rec, comm_cand in reviews_data:
            if mission_idx >= len(missions):
                continue
            mission = missions[mission_idx]
            if mission.statut != "terminee":
                continue

            candidat_user = mission.candidature.candidat
            recruteur_user = mission.candidature.offre.recruteur
            recruteur_name = f"{recruteur_user.prenom} {recruteur_user.nom}"

            # Recruteur evalue le candidat
            rev1, created1 = Evaluation.objects.get_or_create(
                evaluateur=recruteur_user,
                mission=mission,
                defaults={
                    "note": note_cand,
                    "commentaire": comm_rec,
                    "evalue": candidat_user,
                    "recruiter_name": recruteur_name,
                },
            )
            created_reviews.append(rev1)
            self.stdout.write(f"   Review recruteur->candidat mission#{mission.id} [{note_cand}/5] — {'creee' if created1 else 'existante'}")

            # Candidat evalue le recruteur
            rev2, created2 = Evaluation.objects.get_or_create(
                evaluateur=candidat_user,
                mission=mission,
                defaults={
                    "note": note_rec,
                    "commentaire": comm_cand,
                    "evalue": recruteur_user,
                    "recruiter_name": recruteur_name,
                },
            )
            created_reviews.append(rev2)
            self.stdout.write(f"   Review candidat->recruteur mission#{mission.id} [{note_rec}/5] — {'creee' if created2 else 'existante'}")

        self.stdout.write(f"   >>{len(created_reviews)} reviews\n")
        return created_reviews

    # ------------------------------------------------------------------
    # 8. CV data (formations, experiences, langues, groupes de competences)
    # ------------------------------------------------------------------

    def _create_cv_data(self, candidats):
        from apps.users.models.cv_formation import CvFormation
        from apps.users.models.cv_experience import CvExperience
        from apps.users.models.candidate_language import CandidateLanguage
        from apps.users.models.candidate_skill import CandidateSkillGroup, CandidateSkill

        # (formations, experiences, langues, skill_groups)
        cv_profiles = [
            # 0 - Amine Brahimi (Serveur)
            dict(
                formations=[
                    dict(title="BTS Hotellerie-Restauration", institution="Institut de Tourisme d'Alger", location="Alger", year=2020, is_active=False),
                    dict(title="Certificat Service en Salle", institution="Centre de Formation INFAC", location="Alger", year=2019, is_active=False),
                ],
                experiences=[
                    dict(title="Serveur Chef de rang", company="Restaurant La Medina", location="Alger Centre", period="2021 - 2024", is_active=False),
                    dict(title="Commis de salle", company="Hotel Sofitel Alger", location="Alger", period="2020 - 2021", is_active=False),
                ],
                langues=[("Arabe", "Natif"), ("Francais", "Courant"), ("Anglais", "Intermediaire")],
                skill_groups=[
                    ("Service", [("Service en salle", "expert"), ("Accueil client", "expert"), ("Gestion caisse", "avance")]),
                    ("Langues", [("Francais professionnel", "avance"), ("Anglais", "intermediaire")]),
                ],
            ),
            # 1 - Nadia Ouali (Cuisiniere)
            dict(
                formations=[
                    dict(title="CAP Cuisine", institution="Lycee Professionnel Kouba", location="Alger", year=2018, is_active=False),
                    dict(title="Formation Patisserie Orientale", institution="Centre FOREM", location="Alger", year=2019, is_active=False),
                ],
                experiences=[
                    dict(title="Chef de partie patisserie", company="Hotel Sheraton Alger", location="Alger", period="2021 - present", is_active=True),
                    dict(title="Cuisiniere", company="Restaurant Dar Djillali", location="Alger", period="2018 - 2021", is_active=False),
                ],
                langues=[("Arabe", "Natif"), ("Francais", "Courant")],
                skill_groups=[
                    ("Cuisine", [("Cuisine algerienne", "expert"), ("Patisserie orientale", "expert"), ("Normes HACCP", "avance")]),
                    ("Gestion", [("Gestion des stocks", "intermediaire"), ("Encadrement equipe", "intermediaire")]),
                ],
            ),
            # 2 - Sofiane Merad (Barista)
            dict(
                formations=[
                    dict(title="Certification Barista Niveau 2", institution="SCA Algeria", location="Alger", year=2022, is_active=False),
                    dict(title="Formation Cafe de Specialite", institution="Coffee Lab Oran", location="Oran", year=2021, is_active=False),
                ],
                experiences=[
                    dict(title="Barista Senior", company="Cafe Le Grain d'Or", location="Oran", period="2022 - present", is_active=True),
                    dict(title="Barista Junior", company="Coffee Corner", location="Oran", period="2021 - 2022", is_active=False),
                ],
                langues=[("Arabe", "Natif"), ("Francais", "Courant"), ("Anglais", "Basique")],
                skill_groups=[
                    ("Cafe", [("Espresso", "expert"), ("Latte art", "avance"), ("Cupping", "intermediaire")]),
                    ("Accueil", [("Relation client", "avance"), ("Caisse", "intermediaire")]),
                ],
            ),
            # 3 - Yasmine Hadjadj (Receptionniste)
            dict(
                formations=[
                    dict(title="Licence Hotellerie et Tourisme", institution="Universite d'Alger 2", location="Alger", year=2020, is_active=False),
                    dict(title="Formation Opera PMS", institution="Hotelier School", location="Alger", year=2021, is_active=False),
                ],
                experiences=[
                    dict(title="Receptionniste", company="Hotel Mercure Alger", location="Alger", period="2021 - present", is_active=True),
                    dict(title="Stagiaire Reception", company="Hotel El Djazair", location="Alger", period="2020 - 2021", is_active=False),
                ],
                langues=[("Arabe", "Natif"), ("Francais", "Courant"), ("Anglais", "Courant")],
                skill_groups=[
                    ("Reception", [("Opera PMS", "expert"), ("Check-in/Check-out", "expert"), ("Gestion reclamations", "avance")]),
                    ("Langues", [("Francais", "expert"), ("Anglais", "avance")]),
                ],
            ),
            # 4 - Bilal Kaced (Commis)
            dict(
                formations=[
                    dict(title="CAP Cuisine", institution="Lycee Professionnel Constantine", location="Constantine", year=2023, is_active=False),
                ],
                experiences=[
                    dict(title="Commis de cuisine", company="Restaurant Le Palace", location="Constantine", period="2023 - present", is_active=True),
                ],
                langues=[("Arabe", "Natif"), ("Francais", "Intermediaire")],
                skill_groups=[
                    ("Cuisine", [("Cuisine froide", "debutant"), ("Normes hygiene", "intermediaire"), ("Aide patisserie", "debutant")]),
                ],
            ),
            # 5 - Meriem Benzitouni (Serveuse)
            dict(
                formations=[
                    dict(title="BTS Restauration", institution="Institut d'Annaba", location="Annaba", year=2019, is_active=False),
                    dict(title="Formation Sommellerie", institution="Ecole des Metiers", location="Alger", year=2021, is_active=False),
                ],
                experiences=[
                    dict(title="Cheffe de rang", company="Traiteur El Nakhla", location="Annaba", period="2021 - present", is_active=True),
                    dict(title="Serveuse", company="Restaurant El Bahia", location="Annaba", period="2019 - 2021", is_active=False),
                ],
                langues=[("Arabe", "Natif"), ("Francais", "Courant"), ("Anglais", "Basique")],
                skill_groups=[
                    ("Service", [("Service banquet", "expert"), ("Sommellerie", "intermediaire"), ("Encaissement", "avance")]),
                    ("Evenementiel", [("Organisation banquet", "avance"), ("Gestion equipe", "intermediaire")]),
                ],
            ),
            # 6 - Rami Slimani (Chef de rang)
            dict(
                formations=[
                    dict(title="BTS Hotellerie option Restauration", institution="Institut Superieur Alger", location="Alger", year=2016, is_active=False),
                    dict(title="Management Restauration", institution="ESMA", location="Alger", year=2018, is_active=False),
                ],
                experiences=[
                    dict(title="Chef de rang", company="Restaurant Panorama VIP", location="Alger", period="2020 - present", is_active=True),
                    dict(title="Chef de rang", company="Hotel Hilton Alger", location="Alger", period="2017 - 2020", is_active=False),
                    dict(title="Serveur", company="Restaurant Le Doyen", location="Alger", period="2016 - 2017", is_active=False),
                ],
                langues=[("Arabe", "Natif"), ("Francais", "Expert"), ("Anglais", "Courant"), ("Espagnol", "Basique")],
                skill_groups=[
                    ("Management", [("Encadrement equipe", "expert"), ("Formation junior", "expert"), ("Gestion conflits", "avance")]),
                    ("Service", [("Service VIP", "expert"), ("Vins et spiritueux", "avance"), ("Service a l'assiette", "expert")]),
                ],
            ),
            # 7 - Lina Cherif (Barman)
            dict(
                formations=[
                    dict(title="Formation Mixologie Avancee", institution="Bar Academy Oran", location="Oran", year=2021, is_active=False),
                    dict(title="Certificat Gestion de Bar", institution="INFAC Oran", location="Oran", year=2020, is_active=False),
                ],
                experiences=[
                    dict(title="Barmane principale", company="Sky Bar Le Meridien", location="Oran", period="2022 - present", is_active=True),
                    dict(title="Barmane", company="Club Med Oran", location="Oran", period="2020 - 2022", is_active=False),
                ],
                langues=[("Arabe", "Natif"), ("Francais", "Courant"), ("Anglais", "Intermediaire")],
                skill_groups=[
                    ("Bar", [("Cocktails classiques", "expert"), ("Cocktails signatures", "expert"), ("Gestion stock bar", "avance")]),
                    ("Client", [("Fidelisation client", "avance"), ("Animation bar", "intermediaire")]),
                ],
            ),
        ]

        for i, candidat in enumerate(candidats):
            if i >= len(cv_profiles):
                break
            profile = cv_profiles[i]

            # Formations
            if not candidat.formations.exists():
                for f in profile["formations"]:
                    CvFormation.objects.get_or_create(
                        candidat=candidat, title=f["title"],
                        defaults=f,
                    )
                self.stdout.write(f"   CV formations {candidat.prenom} — crees")

            # Experiences
            if not candidat.experiences.exists():
                for e in profile["experiences"]:
                    CvExperience.objects.get_or_create(
                        candidat=candidat, title=e["title"], company=e["company"],
                        defaults=e,
                    )
                self.stdout.write(f"   CV experiences {candidat.prenom} — creees")

            # Langues
            if not candidat.languages.exists():
                for name, proficiency in profile["langues"]:
                    CandidateLanguage.objects.get_or_create(
                        candidat=candidat, name=name,
                        defaults={"proficiency": proficiency},
                    )
                self.stdout.write(f"   Langues {candidat.prenom} — creees")

            # Groupes de competences
            if not candidat.skill_groups.exists():
                for order, (group_title, skills) in enumerate(profile["skill_groups"]):
                    group, _ = CandidateSkillGroup.objects.get_or_create(
                        candidat=candidat, title=group_title,
                        defaults={"order": order},
                    )
                    for skill_name, skill_level in skills:
                        CandidateSkill.objects.get_or_create(
                            group=group, name=skill_name,
                            defaults={"level": skill_level},
                        )
                self.stdout.write(f"   Skill groups {candidat.prenom} — crees")

        self.stdout.write("   >>CV data done\n")

    # ------------------------------------------------------------------
    # 9. Entretiens
    # ------------------------------------------------------------------

    def _create_interviews(self, candidats, recruteurs, offres):
        from apps.jobs.models import Interview

        now = timezone.now()
        # (candidat_idx, recruteur_idx, offre_idx, day_offset, status)
        plans = [
            (0, 0, 0,  3, "scheduled"),   # Amine <-> Karim, Serveur en salle
            (6, 0, 0,  5, "scheduled"),   # Rami <-> Karim, Serveur en salle
            (0, 0, 9,  8, "scheduled"),   # Amine <-> Karim, Second de cuisine
            (2, 3, 3,  4, "scheduled"),   # Sofiane <-> Amira, Barista
            (0, 3, 3,  6, "scheduled"),   # Amine <-> Amira, Barista
            (3, 3, 8, 10, "scheduled"),   # Yasmine <-> Amira, Agent d'accueil
            (4, 2, 4,  7, "scheduled"),   # Bilal <-> Mohamed (Brasserie), Commis
            (3, 1, 2, -2, "completed"),   # Yasmine <-> Sonia, Receptionniste
            (7, 2, 7, -5, "completed"),   # Lina <-> Mohamed, Barman
            (4, 2, 7, -8, "completed"),   # Bilal <-> Mohamed, Barman (other candidat)
        ]

        interviews = []
        for ci, ri, oi, offset, status in plans:
            candidat = candidats[ci]
            recruteur = recruteurs[ri]
            offre = offres[oi]
            scheduled = now + timedelta(days=offset)

            obj, created = Interview.objects.get_or_create(
                candidate=candidat,
                recruiter=recruteur,
                job=offre,
                defaults={"scheduled_date": scheduled, "status": status},
            )
            interviews.append(obj)
            self.stdout.write(f"   Entretien {candidat.prenom} <-> {recruteur.prenom} [{status}] — {'cree' if created else 'existant'}")

        self.stdout.write(f"   >>{len(interviews)} entretiens\n")
        return interviews

    # ------------------------------------------------------------------
    # 10. Commentaires sur les offres
    # ------------------------------------------------------------------

    def _create_comments(self, offres, candidats, recruteurs):
        from apps.jobs.models import JobComment
        from django.utils import timezone as tz

        now = tz.now()
        plans = [
            (0, 2, "Bonjour, est-ce que la formation est assuree pour les nouveaux ? Je debute dans votre type d'etablissement.", "Bonjour ! Oui, nous proposons une semaine d'integration avec le chef de rang. Bienvenue !"),
            (1, 0, "Est-ce que l'hotel propose un logement pour les employes venant d'autres villes ?", "Nous n'offrons pas de logement mais nous accompagnons nos employes dans leur recherche avec des partenariats."),
            (3, 2, "Quelles sont les varietes de cafe que vous utilisez ? Je suis certifie Q Grader.", "Excellent ! Nous travaillons avec des origines Ethiopie, Colombie et Yemen. Un Q Grader serait un vrai atout !"),
            (6, 6, "Le poste de second peut-il evoluer vers chef executif a terme ?", "Absolument, notre chef actuel est en fin de carriere. Nous cherchons son successeur. Belle opportunite d'evolution."),
            (7, 7, "Avez-vous un budget pour renouveler la carte cocktails chaque saison ?", "Oui, nous allouons un budget trimestriel. Carte d'ete deja en preparation !"),
        ]

        comments = []
        for oi, ci, question, reponse in plans:
            offre = offres[oi]
            auteur = candidats[ci]
            obj, created = JobComment.objects.get_or_create(
                offre=offre,
                auteur=auteur,
                question=question,
                defaults={"reponse": reponse, "date_reponse": now if reponse else None},
            )
            comments.append(obj)
            self.stdout.write(f"   Commentaire sur '{offre.titre}' — {'cree' if created else 'existant'}")

        self.stdout.write(f"   >>{len(comments)} commentaires\n")
        return comments

    # ------------------------------------------------------------------
    # 11. Conversations & Messages
    # ------------------------------------------------------------------

    def _create_conversations(self, candidats, recruteurs):
        from apps.messaging.models import Conversation, ConversationMember, Message
        from django.utils import timezone as tz

        now = tz.now()

        # Each entry: (recruteur_idx, candidat_idx, nom, messages)
        # messages: list of (expediteur_is_recruiter, contenu, minutes_ago)
        convs_data = [
            (
                0, 0,  # Karim <-> Amine
                "Karim Benali & Amine Brahimi",
                [
                    (True,  "Bonjour Amine, j'ai bien recu votre candidature pour le poste de serveur. Pouvez-vous passer un entretien mardi prochain a 10h ?", 60),
                    (False, "Bonjour Monsieur Benali, merci pour votre retour rapide ! Mardi 10h me convient parfaitement. Je serai ponctuel.", 55),
                    (True,  "Parfait. L'entretien se deroule au restaurant, 12 rue Didouche Mourad Alger. Demandez Karim a l'accueil.", 50),
                    (False, "Tres bien, je note. Dois-je apporter des documents particuliers ?", 48),
                    (True,  "Oui, votre CV et une piece d'identite suffiront. A mardi !", 45),
                    (False, "Entendu, a mardi. Bonne journee !", 44),
                ],
            ),
            (
                1, 1,  # Sonia <-> Nadia
                "Sonia Rahmani & Nadia Ouali",
                [
                    (True,  "Bonjour Nadia, felicitations ! Votre candidature pour le poste de chef de partie patisserie a ete retenue. Quand pouvez-vous commencer ?", 120),
                    (False, "Bonjour Madame Rahmani, c'est une excellente nouvelle ! Je suis disponible des la semaine prochaine si necessaire.", 115),
                    (True,  "Tres bien. Nous prevoyons votre integration le lundi 02 juin. Vous serez accueillie par le chef executif.", 110),
                    (False, "Je serai la avec plaisir. Merci pour cette opportunite !", 108),
                    (True,  "C'est nous qui vous remercions. A lundi prochain !", 105),
                ],
            ),
            (
                1, 3,  # Sonia <-> Yasmine
                "Sonia Rahmani & Yasmine Hadjadj",
                [
                    (True,  "Bonjour Yasmine, votre mission a El Aurassi est terminee. Nous avons ete tres satisfaits de votre travail.", 240),
                    (False, "Merci infiniment Madame Rahmani, c'etait une experience formidable. L'equipe est vraiment professionnelle.", 235),
                    (True,  "Votre evaluation a ete soumise. Avez-vous deja note l'hotel de votre cote ?", 230),
                    (False, "Oui, j'ai laisse une evaluation 5 etoiles. El Aurassi merite pleinement sa reputation.", 225),
                    (True,  "Nous esperons vous revoir pour de futures collaborations. Bon courage pour la suite !", 220),
                    (False, "Avec plaisir ! N'hesitez pas a me contacter si un poste correspond a mon profil.", 215),
                ],
            ),
            (
                2, 7,  # Mohamed <-> Lina
                "Mohamed Khelifi & Lina Cherif",
                [
                    (True,  "Bonjour Lina, je suis Mohamed, directeur de la Brasserie Tafna. Votre profil de barman nous interesse. Etes-vous disponible pour un entretien ?", 180),
                    (False, "Bonjour Monsieur Khelifi ! Oui, je suis disponible. Quand et ou souhaitez-vous qu'on se rencontre ?", 175),
                    (True,  "Jeudi a 14h a la Brasserie, boulevard de la Soummam, Oran. Cela vous convient ?", 170),
                    (False, "Parfait, jeudi 14h c'est note. Je serai la.", 168),
                    (True,  "Super. L'entretien durera environ 45 minutes. Il y aura un test pratique de mixologie.", 165),
                    (False, "Je suis pret ! J'apporterai mon carnet de recettes. A jeudi.", 160),
                    (True,  "A jeudi. Bonne journee Lina !", 159),
                ],
            ),
            (
                4, 2,  # Yacine <-> Sofiane
                "Yacine Messaoudi & Sofiane Merad",
                [
                    (True,  "Bonjour Sofiane, j'ai vu votre candidature pour le poste de serveur evenementiel. Avez-vous de l'experience avec les grands buffets ?", 90),
                    (False, "Bonjour Monsieur Messaoudi ! Oui, j'ai travaille sur plusieurs evenements de 200 a 500 personnes a Annaba.", 85),
                    (True,  "Tres bien. Nous avons un mariage samedi prochain de 300 convives. Seriez-vous disponible ?", 80),
                    (False, "Absolument, je suis disponible ce samedi. Quelle est la tenue requise ?", 78),
                    (True,  "Chemise blanche, pantalon noir, chaussures de ville. Nous fournissons le tablier.", 75),
                    (False, "Parfait, j'ai tout ca. A quelle heure dois-je etre present ?", 73),
                    (True,  "14h pour le briefing. Le service commence a 19h. Merci Sofiane !", 70),
                ],
            ),
        ]

        total = 0
        for ri, ci, nom, msgs in convs_data:
            recruteur = recruteurs[ri]
            candidat  = candidats[ci]

            # Create conversation if not exists (check by members)
            existing = Conversation.objects.filter(
                type='direct',
                memberships__user=recruteur,
            ).filter(memberships__user=candidat).first()

            if existing:
                self.stdout.write(f"   Conversation {recruteur.prenom}<->{candidat.prenom} — existante")
                continue

            conv = Conversation.objects.create(
                type='direct',
                nom=nom,
                created_by=recruteur,
            )
            ConversationMember.objects.create(conversation=conv, user=recruteur, role='member')
            ConversationMember.objects.create(conversation=conv, user=candidat, role='member')

            for is_recruiter, contenu, minutes_ago in msgs:
                expediteur   = recruteur if is_recruiter else candidat
                destinataire = candidat  if is_recruiter else recruteur
                Message.objects.create(
                    conversation=conv,
                    expediteur=expediteur,
                    destinataire=destinataire,
                    contenu=contenu,
                    type='text',
                    est_lu=True,
                    date_envoi=now - timedelta(minutes=minutes_ago),
                )
                total += 1

            self.stdout.write(f"   Conversation {recruteur.prenom}<->{candidat.prenom} ({len(msgs)} msgs) — creee")

        self.stdout.write(f"   >>{total} messages crees\n")
