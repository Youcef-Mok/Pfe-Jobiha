from django.db import models
from apps.uploads.models import Candidature


# ---------------------------------------------------------------------------
# Mission
# ---------------------------------------------------------------------------
 
class Mission(models.Model):
    candidature = models.OneToOneField(
        Candidature, on_delete=models.CASCADE, related_name="mission"
    )
    date_debut = models.DateTimeField()
    date_fin = models.DateTimeField(blank=True, null=True)
    duree_heures = models.FloatField(blank=True, null=True)
    statut = models.CharField(max_length=50, default="en_cours")
 
    class Meta:
        db_table = "mission"
 
    def __str__(self):
        return f"Mission #{self.id}"
 
    def valider_debut(self):
        pass
 
    def valider_fin(self):
        pass
 
    def generer_attestation(self):
        pass