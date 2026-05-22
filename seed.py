from __future__ import annotations

import os
import sys
from datetime import date, datetime, timedelta, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parent
BACKEND_DIR = ROOT / "backend"
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

import django  # noqa: E402

django.setup()

from django.contrib.auth.hashers import make_password  # noqa: E402
from django.db import transaction  # noqa: E402

from apps.applications.models import Candidature  # noqa: E402
from apps.jobs.models import Interview, Mission, Offre  # noqa: E402
from apps.messaging.models import (  # noqa: E402
    Conversation,
    ConversationMember,
    Message,
)
from apps.notifications.models import Notification  # noqa: E402
from apps.users.models import (  # noqa: E402
    CandidateLanguage,
    CandidateSkill,
    CandidateSkillGroup,
    CandidateTool,
    Candidat,
    Recruteur,
    Utilisateur,
)


PASSWORD = "Test1234!"
SEED_EMAILS = [
    "recruteur1@test.com",
    "recruteur2@test.com",
    "candidat1@test.com",
    "candidat2@test.com",
    "candidat3@test.com",
]


def _create_recruiter(
    email: str,
    prenom: str,
    nom: str,
    telephone: str,
    company: str,
    company_type: str,
    title: str,
    domain: str,
    location: str,
    lat: float,
    lng: float,
    avatar: str,
    bio: str,
) -> Recruteur:
    return Recruteur.objects.create(
        email=email,
        prenom=prenom,
        nom=nom,
        mot_de_passe=make_password(PASSWORD),
        telephone=telephone,
        est_verifie=True,
        statut_compte="actif",
        push_notif_enabled=True,
        latitude=lat,
        longitude=lng,
        avatar_url=avatar,
        location=location,
        bio=bio,
        nom_structure=company,
        type_structure=company_type,
        description=f"{company} - {bio}",
        note_globale=4.6,
        titre_poste=title,
        logo_url=avatar,
        domain=domain,
    )


def _create_candidate(
    email: str,
    prenom: str,
    nom: str,
    telephone: str,
    title: str,
    domain: str,
    location: str,
    lat: float,
    lng: float,
    avatar: str,
    bio: str,
    competences: list[str],
    experience: str,
) -> Candidat:
    return Candidat.objects.create(
        email=email,
        prenom=prenom,
        nom=nom,
        mot_de_passe=make_password(PASSWORD),
        telephone=telephone,
        est_verifie=True,
        statut_compte="actif",
        push_notif_enabled=True,
        latitude=lat,
        longitude=lng,
        avatar_url=avatar,
        location=location,
        bio=bio,
        competences=competences,
        experience=experience,
        note_globale=4.2,
        titre_poste=title,
        domain=domain,
    )


@transaction.atomic
def run_seed() -> None:
    print("Seeding database...")

    # Cleanup previous seeded dataset.
    Utilisateur.objects.filter(email__in=SEED_EMAILS).delete()

    # 1) Users + 2) Profiles
    recruiters = [
        _create_recruiter(
            "recruteur1@test.com",
            "Nadia",
            "Brahimi",
            "+213555000001",
            "Atlas Hospitality",
            "Hotellerie",
            "Responsable recrutement",
            "Hotellerie",
            "Alger",
            36.7538,
            3.0588,
            "https://i.pravatar.cc/150?img=12",
            "Nous recrutons des talents operationnels pour des hotels et restaurants premium.",
        ),
        _create_recruiter(
            "recruteur2@test.com",
            "Yacine",
            "Mansouri",
            "+213555000002",
            "Eventia Pro",
            "Evenementiel",
            "Talent acquisition lead",
            "Evenementiel",
            "Oran",
            35.6971,
            -0.6308,
            "https://i.pravatar.cc/150?img=33",
            "Agence evenementielle specialisee dans les operations terrain et staffing.",
        ),
    ]

    candidates = [
        _create_candidate(
            "candidat1@test.com",
            "Sami",
            "Haddad",
            "+213666100001",
            "Serveur polyvalent",
            "Restauration",
            "Alger",
            36.75,
            3.06,
            "https://i.pravatar.cc/150?img=5",
            "3 ans d'experience en service et gestion des flux clients.",
            ["Service en salle", "Relation client", "Encaissement"],
            "3 ans en restauration rapide et bistronomie.",
        ),
        _create_candidate(
            "candidat2@test.com",
            "Lina",
            "Kaci",
            "+213666100002",
            "Hotesse evenementielle",
            "Evenementiel",
            "Oran",
            35.70,
            -0.62,
            "https://i.pravatar.cc/150?img=47",
            "Specialisee dans l'accueil VIP et la coordination sur evenement.",
            ["Accueil VIP", "Orientation", "Gestion des invites"],
            "2 ans en salons professionnels et conferences.",
        ),
        _create_candidate(
            "candidat3@test.com",
            "Ilyes",
            "Benali",
            "+213666100003",
            "Commis de cuisine",
            "Restauration",
            "Constantine",
            36.365,
            6.6147,
            "https://i.pravatar.cc/150?img=14",
            "Rigoureux et rapide en cuisine de production.",
            ["Mise en place", "Hygiene HACCP", "Preparation froide"],
            "4 ans entre traiteur et restauration collective.",
        ),
    ]

    # 3) Candidate skills, languages, tools
    skill_templates = [
        ("Service", ["Prise de commande", "Gestion de salle", "Upselling"]),
        ("Soft Skills", ["Communication", "Gestion du stress", "Travail d'equipe"]),
        ("Technique", ["HACCP", "Caisse POS", "Inventaire"]),
    ]
    levels = ["debutant", "intermediaire", "avance", "expert"]

    for idx, cand in enumerate(candidates):
        for g_idx, (group_title, skills) in enumerate(skill_templates):
            group = CandidateSkillGroup.objects.create(
                candidat=cand,
                title=group_title,
                order=g_idx,
            )
            for s_idx, skill_name in enumerate(skills):
                CandidateSkill.objects.create(
                    group=group,
                    name=skill_name,
                    level=levels[(idx + s_idx + g_idx) % len(levels)],
                )

        CandidateLanguage.objects.bulk_create(
            [
                CandidateLanguage(candidat=cand, name="Francais", proficiency="Courant"),
                CandidateLanguage(candidat=cand, name="Arabe", proficiency="Natif"),
                CandidateLanguage(candidat=cand, name="Anglais", proficiency="Intermediaire"),
            ]
        )
        CandidateTool.objects.bulk_create(
            [
                CandidateTool(candidat=cand, name="Excel"),
                CandidateTool(candidat=cand, name="Google Sheets"),
                CandidateTool(candidat=cand, name="Slack"),
            ]
        )

    # 4) Jobs: 3 per recruiter
    statuses = ["searching", "draft", "closed"]
    contract_types = ["cdi", "freelance", "mission"]
    categories = ["Restauration", "Evenementiel", "Hotellerie"]
    jobs: list[Offre] = []
    for r_idx, recruteur in enumerate(recruiters):
        for j_idx in range(3):
            job = Offre.objects.create(
                titre=f"{categories[j_idx]} - Poste {j_idx + 1} ({recruteur.nom_structure})",
                description=f"Annonce test {j_idx + 1} pour {recruteur.nom_structure}.",
                categorie=categories[j_idx],
                date_debut=date.today() + timedelta(days=7 + j_idx),
                date_fin=date.today() + timedelta(days=45 + j_idx),
                salaire=45000.0 + (j_idx * 8000),
                type_contrat=contract_types[j_idx],
                latitude=(recruteur.latitude or 36.75) + (0.01 * j_idx),
                longitude=(recruteur.longitude or 3.05) + (0.01 * j_idx),
                location=recruteur.location,
                statut=statuses[j_idx],
                candidate_count=0,
                view_count=10 + j_idx,
                is_published=statuses[j_idx] != "draft",
                image_url="https://picsum.photos/600/400",
                schedule_label="Journee",
                recruteur=recruteur,
            )
            jobs.append(job)

    # 5) Applications: each candidate applies to 2-3 jobs
    app_statuses = ["nouveau", "examine", "archive"]
    applications: list[Candidature] = []
    for c_idx, cand in enumerate(candidates):
        target_jobs = jobs[c_idx : c_idx + 3]
        if len(target_jobs) < 3:
            target_jobs = jobs[:3]
        for j_idx, job in enumerate(target_jobs):
            app = Candidature.objects.create(
                candidat=cand,
                offre=job,
                message_personnalise=(
                    f"Bonjour, je candidate au poste '{job.titre}'. "
                    f"Mon profil correspond aux besoins."
                ),
                statut=app_statuses[(c_idx + j_idx) % len(app_statuses)],
            )
            applications.append(app)

    # 6) Missions: 2 completed, 1 in progress
    now = datetime.now(timezone.utc)
    mission_apps = applications[:3]
    Mission.objects.create(
        candidature=mission_apps[0],
        date_debut=now - timedelta(days=10),
        date_fin=now - timedelta(days=9, hours=16),
        duree_heures=8.0,
        statut="terminee",
        location=mission_apps[0].offre.location or "Alger",
        image_url="https://picsum.photos/seed/m1/600/300",
        summary="Mission completee avec succes.",
    )
    Mission.objects.create(
        candidature=mission_apps[1],
        date_debut=now - timedelta(days=7),
        date_fin=now - timedelta(days=6, hours=18),
        duree_heures=6.0,
        statut="terminee",
        location=mission_apps[1].offre.location or "Oran",
        image_url="https://picsum.photos/seed/m2/600/300",
        summary="Mission terminee, excellent retour client.",
    )
    Mission.objects.create(
        candidature=mission_apps[2],
        date_debut=now - timedelta(hours=5),
        date_fin=None,
        duree_heures=None,
        statut="en_cours",
        location=mission_apps[2].offre.location or "Constantine",
        image_url="https://picsum.photos/seed/m3/600/300",
        summary="Mission en cours.",
    )

    # 7) Interviews: 2 upcoming, 1 past
    Interview.objects.create(
        candidate=candidates[0],
        recruiter=recruiters[0],
        job=jobs[0],
        scheduled_date=now + timedelta(days=2),
        status="scheduled",
        notes="Entretien RH visio.",
    )
    Interview.objects.create(
        candidate=candidates[1],
        recruiter=recruiters[1],
        job=jobs[4],
        scheduled_date=now + timedelta(days=4),
        status="scheduled",
        notes="Entretien operationnel sur site.",
    )
    Interview.objects.create(
        candidate=candidates[2],
        recruiter=recruiters[0],
        job=jobs[1],
        scheduled_date=now - timedelta(days=3),
        status="completed",
        notes="Entretien passe, feedback positif.",
    )

    # 8) Messaging: 2 conversations, 3-4 messages each
    conv1 = Conversation.objects.create(type=Conversation.TYPE_DIRECT, created_by=recruiters[0])
    ConversationMember.objects.create(conversation=conv1, user=recruiters[0], role="admin")
    ConversationMember.objects.create(conversation=conv1, user=candidates[0], role="member")
    Message.objects.create(
        conversation=conv1,
        expediteur=recruiters[0],
        destinataire=candidates[0],
        type="text",
        contenu="Bonjour, votre candidature nous interesse.",
    )
    Message.objects.create(
        conversation=conv1,
        expediteur=candidates[0],
        destinataire=recruiters[0],
        type="text",
        contenu="Merci, je suis disponible demain.",
    )
    Message.objects.create(
        conversation=conv1,
        expediteur=recruiters[0],
        destinataire=candidates[0],
        type="text",
        contenu="Parfait, rendez-vous confirme a 10h.",
    )

    conv2 = Conversation.objects.create(type=Conversation.TYPE_GROUP, nom="Equipe Mission", created_by=recruiters[1])
    ConversationMember.objects.create(conversation=conv2, user=recruiters[1], role="admin")
    ConversationMember.objects.create(conversation=conv2, user=candidates[1], role="member")
    ConversationMember.objects.create(conversation=conv2, user=candidates[2], role="member")
    Message.objects.create(conversation=conv2, expediteur=recruiters[1], type="text", contenu="Bienvenue dans le groupe mission.")
    Message.objects.create(conversation=conv2, expediteur=candidates[1], type="text", contenu="Merci, prete pour le brief.")
    Message.objects.create(conversation=conv2, expediteur=candidates[2], type="text", contenu="Present aussi.")
    Message.objects.create(conversation=conv2, expediteur=recruiters[1], type="text", contenu="Debut mission samedi 8h.")

    # 9) Notifications: 3-4 per user
    notif_types = ["candidature", "mission", "message", "evaluation"]
    all_users = [*recruiters, *candidates]
    for u_idx, user in enumerate(all_users):
        for n_idx in range(4):
            Notification.objects.create(
                utilisateur=user,
                contenu=f"Notification test {n_idx + 1} pour {user.email}",
                type=notif_types[(u_idx + n_idx) % len(notif_types)],
                est_lue=(n_idx % 2 == 0),
                title=f"Notif {n_idx + 1}",
                job_title=jobs[(u_idx + n_idx) % len(jobs)].titre,
                sender_name=f"{user.prenom} {user.nom}",
                avatar_url=user.avatar_url,
                count=n_idx + 1,
                context_image_url="https://picsum.photos/seed/notif/200/100",
            )

    print("Seed completed successfully.")
    print("Users created:")
    for email in SEED_EMAILS:
        print(f" - {email} / {PASSWORD}")


if __name__ == "__main__":
    run_seed()
