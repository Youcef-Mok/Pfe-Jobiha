from django.db import models


# ---------------------------------------------------------------------------
# Alerte — candidate sets a saved-search / job alert
# ---------------------------------------------------------------------------

class Alerte(models.Model):
    candidat     = models.ForeignKey(
        "users.Candidat", on_delete=models.CASCADE, related_name="alertes"
    )
    titre        = models.CharField(max_length=200, blank=True)
    categorie    = models.CharField(max_length=100, blank=True)
    type_contrat = models.CharField(max_length=50,  blank=True)
    salaire_min  = models.FloatField(blank=True, null=True)
    localisation = models.CharField(max_length=200, blank=True)
    actif        = models.BooleanField(default=True)
    cree_le      = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "alerte"

    def __str__(self):
        return f"Alerte #{self.id} — {self.candidat}"
