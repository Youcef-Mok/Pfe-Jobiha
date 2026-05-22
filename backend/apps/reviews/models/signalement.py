from django.db import models


# ---------------------------------------------------------------------------
# Signalement
# ---------------------------------------------------------------------------

class Signalement(models.Model):
    auteur = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="signalements_emis",
    )
    cible = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="signalements_recus",
    )
    administrateur = models.ForeignKey(
        "users.Administrateur",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="signalements_traites",
    )
    raison = models.CharField(max_length=200)
    description = models.TextField(blank=True, null=True)
    date_signalement = models.DateTimeField(auto_now_add=True)
    statut = models.CharField(max_length=50, default="ouvert")
    decision = models.TextField(blank=True, null=True)

    class Meta:
        db_table = "signalement"

    def __str__(self):
        return f"Signalement #{self.id} ({self.statut})"

    def soumettre(self):
        pass

    def traiter(self):
        pass

    def cloturer(self):
        pass