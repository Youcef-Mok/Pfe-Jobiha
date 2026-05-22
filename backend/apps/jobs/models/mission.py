from django.db import models
from django.utils import timezone
from django.core.exceptions import ValidationError

# ---------------------------------------------------------------------------
# Mission
# ---------------------------------------------------------------------------

class Mission(models.Model):

    STATUT_CHOICES = [
        ("en_attente", "En attente"),
        ("en_cours",   "En cours"),
        ("terminee",   "Terminée"),
        ("annulee",    "Annulée"),
    ]

    candidature = models.OneToOneField(
        "applications.Candidature", on_delete=models.CASCADE, related_name="mission"
    )
    # Nullable until valider_debut() is called.
    date_debut   = models.DateTimeField(blank=True, null=True)
    date_fin     = models.DateTimeField(blank=True, null=True)
    duree_heures = models.FloatField(blank=True, null=True)
    statut       = models.CharField(
        max_length=50, choices=STATUT_CHOICES, default="en_attente"
    )
    location     = models.CharField(max_length=200, blank=True)
    image_url    = models.CharField(max_length=500, blank=True, null=True)
    # New field from DB-CHANGES.md section 5
    summary      = models.TextField(blank=True, null=True)

    class Meta:
        db_table = "mission"

    def __str__(self):
        return f"Mission #{self.id}"

    def valider_debut(self, date_debut=None):
        """
        Confirm mission start.
        Sets date_debut (defaults to now) and transitions statut to en_cours.
        Raises ValidationError if the mission is not in en_attente.
        """
        if self.statut != "en_attente":
            raise ValidationError(
                f"Cannot validate start: mission is already '{self.statut}'."
            )
        self.date_debut = date_debut or timezone.now()
        self.statut = "en_cours"
        self.save(update_fields=["date_debut", "statut"])

    def valider_fin(self, date_fin=None):
        """
        Confirm mission end.
        Sets date_fin, computes duree_heures, and transitions statut to terminee.
        Raises ValidationError if the mission is not en_cours.
        """
        if self.statut != "en_cours":
            raise ValidationError(
                f"Cannot validate end: mission is not en_cours (current: '{self.statut}')."
            )
        self.date_fin = date_fin or timezone.now()
        if self.date_debut:
            delta = self.date_fin - self.date_debut
            self.duree_heures = round(delta.total_seconds() / 3600, 2)
        self.statut = "terminee"
        self.save(update_fields=["date_fin", "duree_heures", "statut"])

    def generer_attestation(self):
        """
        Return a dict with the data needed to render the PDF attestation.
        The actual PDF rendering (e.g. with ReportLab / WeasyPrint) should be
        done in the view that calls this method.
        Raises ValidationError if the mission is not terminee.
        """
        if self.statut != "terminee":
            raise ValidationError("Attestation is only available for completed missions.")
        candidature = self.candidature
        return {
            "mission_id":    self.id,
            "candidat":      f"{candidature.candidat.prenom} {candidature.candidat.nom}",
            "offre":         candidature.offre.titre,
            "recruteur":     candidature.offre.recruteur.nom_structure,
            "date_debut":    self.date_debut,
            "date_fin":      self.date_fin,
            "duree_heures":  self.duree_heures,
        }