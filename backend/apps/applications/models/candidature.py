from django.db import models


# ---------------------------------------------------------------------------
# Candidature
# ---------------------------------------------------------------------------

class Candidature(models.Model):
    candidat = models.ForeignKey(
        "users.Candidat", on_delete=models.CASCADE, related_name="candidatures"
    )
    offre = models.ForeignKey(
        "jobs.Offre", on_delete=models.CASCADE, related_name="candidatures"
    )
    date_postulation = models.DateField(auto_now_add=True)
    message_personnalise = models.TextField(blank=True, null=True)
    statut = models.CharField(max_length=50, default="en_attente")

    class Meta:
        db_table = "candidature"

    def __str__(self):
        return f"{self.candidat} → {self.offre}"

    def accepter(self):
        pass

    def refuser(self):
        pass
