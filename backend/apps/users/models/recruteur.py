from django.db import models
from .utilisateur import Utilisateur

# ---------------------------------------------------------------------------
# Recruteur (inherits Utilisateur via OneToOneField)
# ---------------------------------------------------------------------------

class Recruteur(Utilisateur):
    nom_structure = models.CharField(max_length=200)
    type_structure = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    note_globale = models.FloatField(default=0.0)
    titre_poste = models.CharField(max_length=200, blank=True, null=True)
    logo_url = models.CharField(max_length=500, blank=True, null=True)
    domain = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        db_table = "recruteur"

    def publier_offre(self, offre):
        pass

    def consulter_candidatures(self):
        pass