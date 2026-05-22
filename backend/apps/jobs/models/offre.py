from django.db import models


# ---------------------------------------------------------------------------
# Offre
# ---------------------------------------------------------------------------

class Offre(models.Model):
    STATUT_CHOICES = [
        ("searching", "Searching"),
        ("draft",     "Draft"),
        ("closed",    "Closed"),
    ]

    titre        = models.CharField(max_length=200)
    description  = models.TextField()
    categorie    = models.CharField(max_length=100)
    date_debut   = models.DateField(null=True, blank=True)
    date_fin     = models.DateField(blank=True, null=True)
    salaire      = models.FloatField(blank=True, null=True)
    type_contrat = models.CharField(max_length=50)
    latitude     = models.FloatField(blank=True, null=True)
    longitude    = models.FloatField(blank=True, null=True)
    location     = models.CharField(max_length=200, blank=True, null=True)
    statut       = models.CharField(
        max_length=50, choices=STATUT_CHOICES, default="searching"
    )
    candidate_count = models.IntegerField(default=1)
    view_count      = models.IntegerField(default=0)
    is_published    = models.BooleanField(default=False)
    created_at     = models.DateTimeField(auto_now_add=True, null=True)
    image_url      = models.CharField(max_length=500, blank=True, null=True)
    schedule_label = models.CharField(max_length=50, blank=True, null=True)
    recruteur    = models.ForeignKey(
        "users.Recruteur", on_delete=models.CASCADE, related_name="offres"
    )
    # New fields from DB-CHANGES.md section 4
    created_at     = models.DateTimeField(auto_now_add=True)
    logo_url       = models.CharField(max_length=500, blank=True, null=True)
    location       = models.CharField(max_length=200, blank=True)
    schedule_label = models.CharField(max_length=50, blank=True, null=True)

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