from django.db import models


class CandidateLanguage(models.Model):
    """
    Languages spoken by a candidate with proficiency level.
    """
    candidat = models.ForeignKey(
        "users.Candidat",
        on_delete=models.CASCADE,
        related_name="languages"
    )
    name = models.CharField(max_length=50)
    proficiency = models.CharField(max_length=50)  # e.g., "Natif", "Avancé", "Intermédiaire"

    class Meta:
        db_table = "candidate_language"

    def __str__(self):
        return f"{self.name} - {self.proficiency}"
