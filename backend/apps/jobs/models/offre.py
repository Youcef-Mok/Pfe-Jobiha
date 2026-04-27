from django.db import models


# ---------------------------------------------------------------------------
# Offre
# ---------------------------------------------------------------------------

class Offre(models.Model):
    STATUT_CHOICES = [
        ("ouverte", "Ouverte"),
        ("fermee",  "Fermée"),
        ("pourvue", "Pourvue"),
    ]

    titre        = models.CharField(max_length=200)
    description  = models.TextField()
    categorie    = models.CharField(max_length=100)
    date_debut   = models.DateField()
    date_fin     = models.DateField(blank=True, null=True)
    salaire      = models.FloatField(blank=True, null=True)
    type_contrat = models.CharField(max_length=50)
    latitude     = models.FloatField(blank=True, null=True)
    longitude    = models.FloatField(blank=True, null=True)
    statut       = models.CharField(
        max_length=50, choices=STATUT_CHOICES, default="ouverte"
    )
    recruteur    = models.ForeignKey(
        "users.Recruteur", on_delete=models.CASCADE, related_name="offres"
    )

    class Meta:
        db_table = "offre"

    def __str__(self):
        return self.titre

    def publier(self):
        pass

    def fermer(self):
        pass

    def modifier(self):
        pass