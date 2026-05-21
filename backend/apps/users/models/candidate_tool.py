from django.db import models


class CandidateTool(models.Model):
    """
    Tools/software mastered by a candidate.
    """
    candidat = models.ForeignKey(
        "users.Candidat",
        on_delete=models.CASCADE,
        related_name="tools"
    )
    name = models.CharField(max_length=100)

    class Meta:
        db_table = "candidate_tool"

    def __str__(self):
        return self.name
