from django.db import models
from .utilisateur import Utilisateur
from .disponibilite import Disponibilite

# ---------------------------------------------------------------------------
# Candidat (inherits Utilisateur via OneToOneField)
# ---------------------------------------------------------------------------

class Candidat(Utilisateur):
    competences = models.JSONField(default=list)          # List<String>
    experience = models.TextField(blank=True, null=True)
    note_globale = models.FloatField(default=0.0)
    disponibilites = models.ManyToManyField(
        Disponibilite, blank=True, related_name="candidats"
    )
    portfolio = models.ManyToManyField(
        "uploads.Media", blank=True, related_name="candidats"
    )

    class Meta:
        db_table = "candidat"

    def postuler(self, offre):
        pass

    def consulter_historique(self):
        pass