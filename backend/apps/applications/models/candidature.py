from django.db import models


# ---------------------------------------------------------------------------
# Candidature
# ---------------------------------------------------------------------------

class Candidature(models.Model):
    STATUT_CHOICES = [
        ("en_attente", "Pending"),
        ("acceptee",   "Accepted"),
        ("refusee",    "Rejected"),
    ]
    
    candidat = models.ForeignKey(
        "users.Candidat", on_delete=models.CASCADE, related_name="candidatures"
    )
    offre = models.ForeignKey(
        "jobs.Offre", on_delete=models.CASCADE, related_name="candidatures"
    )
    # Changed from DateField to DateTimeField (DB-CHANGES.md section 6)
    date_postulation = models.DateTimeField(auto_now_add=True)
    message_personnalise = models.TextField(blank=True, null=True)
    # Added choices to statut field
    statut = models.CharField(max_length=50, choices=STATUT_CHOICES, default="en_attente")

    class Meta:
        db_table = "candidature"

    def __str__(self):
        return f"{self.candidat} → {self.offre}"

    def accepter(self):
        pass

    def refuser(self):
        pass
