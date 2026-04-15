from django.db import models


# ---------------------------------------------------------------------------
# Evaluation
# ---------------------------------------------------------------------------

class Evaluation(models.Model):
    mission = models.ForeignKey(
        "jobs.Mission", on_delete=models.CASCADE, related_name="evaluations"
    )
    note = models.IntegerField()
    commentaire = models.TextField(blank=True, null=True)
    evaluateur = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="evaluations_donnees",
    )
    evalue = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="evaluations_recues",
    )
    date_evaluation = models.DateField(auto_now_add=True)

    class Meta:
        db_table = "evaluation"

    def __str__(self):
        return f"Eval {self.note}/5 par {self.evaluateur}"

    def soumettre(self):
        pass