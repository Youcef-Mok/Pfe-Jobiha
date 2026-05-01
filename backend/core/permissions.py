"""
Permissions for the Jobiha platform.

Architecture note — Multi-Table Inheritance (MTI):
  Candidat and Recruteur are NOT linked to Utilisateur via OneToOneField.
  They ARE Utilisateur rows — they share the same primary key.
  This means:

    - candidature.candidat  IS a Candidat  (which IS a Utilisateur)
    - offre.recruteur        IS a Recruteur (which IS a Utilisateur)
    - request.user           IS a Utilisateur (base type, fetched by JWT)

  Because Django model equality checks both class AND pk, comparing a
  Recruteur instance to a Utilisateur instance will always return False
  even when they represent the same person.

  Correct pattern: compare PKs explicitly.
    ✓  obj.recruteur.pk == request.user.pk
    ✗  obj.recruteur == request.user        ← always False (different classes)
    ✗  obj.recruteur.user                   ← AttributeError (no .user on MTI child)
"""

from django.core.exceptions import ObjectDoesNotExist
from rest_framework.permissions import BasePermission, SAFE_METHODS


# ── Internal helper ────────────────────────────────────────────────────────────

def _is_authenticated(user) -> bool:
    """
    Safe check that works for both AnonymousUser and real Utilisateur instances.
    AnonymousUser has pk=None; every real user has a numeric pk.
    """
    return hasattr(user, 'pk') and user.pk is not None


# ── Role permissions ───────────────────────────────────────────────────────────

class IsCandidat(BasePermission):
    """Allow access only to users with a Candidat profile (MTI subclass)."""

    def has_permission(self, request, view):
        if not _is_authenticated(request.user):
            return False
        try:
            # MTI reverse accessor: raises ObjectDoesNotExist if not a Candidat.
            request.user.candidat
            return True
        except ObjectDoesNotExist:
            return False


class IsRecruteur(BasePermission):
    """Allow access only to users with a Recruteur profile (MTI subclass)."""

    def has_permission(self, request, view):
        if not _is_authenticated(request.user):
            return False
        try:
            request.user.recruteur
            return True
        except ObjectDoesNotExist:
            return False


class IsAdmin(BasePermission):
    """Allow access only to admin users (linked to Administrateur by email)."""

    def has_permission(self, request, view):
        if not _is_authenticated(request.user):
            return False
        from apps.users.models import Administrateur
        return Administrateur.objects.filter(email=request.user.email).exists()


class IsVerifiedUser(BasePermission):
    """
    Requires the user to have verified their email (est_verifie=True on
    Utilisateur) before performing sensitive actions such as publishing
    an offre or submitting a candidature.

    est_verifie lives on Utilisateur, so no profile lookup is needed.
    """

    def has_permission(self, request, view):
        if not _is_authenticated(request.user):
            return False
        return bool(request.user.est_verifie)


# ── Offer permissions ──────────────────────────────────────────────────────────

class IsOffreOwner(BasePermission):
    """
    Object-level: only the recruteur who created the offre can modify it.

    obj.recruteur is a Recruteur (MTI subclass of Utilisateur).
    request.user  is a Utilisateur (base type fetched by JWT).
    They share the same pk, so we compare pks — NOT instances.

    Safe methods (GET, HEAD, OPTIONS) are always allowed.
    Used in: OffreViewSet update / destroy actions.
    """

    def has_object_permission(self, request, view, obj):
        if request.method in SAFE_METHODS:
            return True
        return obj.recruteur.pk == request.user.pk


class IsOffreOwnerForCandidature(BasePermission):
    """
    Object-level: only the recruteur who owns the related offre
    can view or action a candidature.

    obj is a Candidature instance.
    obj.offre.recruteur is a Recruteur (MTI); compare by pk.

    Used in: CandidatureViewSet retrieve / update (accept/reject) actions.
    """

    def has_object_permission(self, request, view, obj):
        return obj.offre.recruteur.pk == request.user.pk


# ── Mission permissions ────────────────────────────────────────────────────────

class IsMissionParticipant(BasePermission):
    """
    Object-level: only the recruteur and the candidat involved in a mission
    can access it.

    Mission has no direct candidat/recruteur fields — the participants are
    reached through:
      obj.candidature.candidat          → Candidat (MTI, pk == Utilisateur pk)
      obj.candidature.offre.recruteur   → Recruteur (MTI, pk == Utilisateur pk)

    We compare pks because instances are of different subclasses.

    Used for: mission validation, time tracking, attestation download.
    """

    def has_object_permission(self, request, view, obj):
        candidat_pk  = obj.candidature.candidat.pk
        recruteur_pk = obj.candidature.offre.recruteur.pk
        return request.user.pk in (candidat_pk, recruteur_pk)


class IsRecruteurOfMission(BasePermission):
    """
    Object-level: restricts an action to the recruteur side of a mission only.
    Reaches the recruteur via the candidature chain (Mission has no direct FK).

    Used for: generating the attestation numérique.
    """

    def has_object_permission(self, request, view, obj):
        return obj.candidature.offre.recruteur.pk == request.user.pk


# ── Message permissions ────────────────────────────────────────────────────────

class IsMessageParticipant(BasePermission):
    """
    Object-level: only the expediteur or the destinataire of a message
    can read or modify it.

    The Message model stores direct FK references (expediteur, destinataire),
    not a participants M2M. There is no separate Conversation model.

    Used in: MessageViewSet retrieve / update actions.
    """

    def has_object_permission(self, request, view, obj):
        return request.user.pk in (obj.expediteur.pk, obj.destinataire.pk)


# ── Review / notation ──────────────────────────────────────────────────────────

class CanLaisserEvaluation(BasePermission):
    """
    View-level POST guard: an evaluation can only be submitted when:
      1. The requesting user participated in the mission.
      2. The mission statut is 'terminee' (matches Mission.STATUT_CHOICES value).
      3. The user has not already reviewed that mission.

    Mission participants are reached via the candidature chain:
      mission.candidature.candidat          → Candidat (MTI)
      mission.candidature.offre.recruteur   → Recruteur (MTI)

    Non-POST requests pass through — the view handles list/retrieve permissions.
    """

    def has_permission(self, request, view):
        if not _is_authenticated(request.user):
            return False

        if request.method != 'POST':
            return True

        mission_id = request.data.get('mission_id')
        if not mission_id:
            return False

        from apps.jobs.models import Mission  # local import avoids circular deps
        try:
            mission = Mission.objects.select_related(
                'candidature__candidat',
                'candidature__offre__recruteur',
            ).get(pk=mission_id)
        except Mission.DoesNotExist:
            return False

        candidat_pk  = mission.candidature.candidat.pk
        recruteur_pk = mission.candidature.offre.recruteur.pk
        is_participant = request.user.pk in (candidat_pk, recruteur_pk)

        already_reviewed = mission.evaluations.filter(
            evaluateur=request.user
        ).exists()

        return (
            is_participant
            and mission.statut == 'terminee'   # matches Mission.STATUT_CHOICES value
            and not already_reviewed
        )

#__ Candidature ownership _____________________________________________________________________

class IsCandidatureOwner(BasePermission):
    """
    Object-level: only the candidat who submitted a candidature can
    withdraw (delete) it.
    obj is a Candidature instance. obj.candidat is a Candidat (MTI).
    """

    def has_object_permission(self, request, view, obj):
        return obj.candidat.pk == request.user.pk


#__ signalement ___________________________________________________________

class IsSignalementAuthorOrAdmin(BasePermission):
    """
    Object-level: the author of a signalement can view their own,
    admins can view all.
    Used for: GET /signalements and GET /signalements/{id}.
    """

    def has_object_permission(self, request, view, obj):
        if not _is_authenticated(request.user):
            return False
        from apps.users.models import Administrateur
        is_admin = Administrateur.objects.filter(email=request.user.email).exists()
        return is_admin or obj.auteur.pk == request.user.pk


#__ notification _______________________________________________________________________________

class IsNotificationOwner(BasePermission):
    """
    Object-level: a user can only read or mark-as-read their own notifications.
    Used for: GET /notifications and PATCH /notifications/{id}.
    """

    def has_object_permission(self, request, view, obj):
        return obj.utilisateur.pk == request.user.pk        