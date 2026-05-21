from django.db import models


class CvExperience(models.Model):
    """
    Work experiences for candidate CV.
    """
    candidat = models.ForeignKey(
        "users.Candidat",
        on_delete=models.CASCADE,
        related_name="experiences"
    )
    title = models.CharField(max_length=200)
    company = models.CharField(max_length=200)
    location = models.CharField(max_length=200)
    period = models.CharField(max_length=100, blank=True, null=True)  # e.g., "Sep 2021 - Août 2023"
    end_date = models.CharField(max_length=50, blank=True, null=True)  # e.g., "Août 2021"
    is_app_mission = models.BooleanField(default=False)  # Whether this is from the app's missions
    is_active = models.BooleanField(default=False)

    class Meta:
        db_table = "cv_experience"

    def __str__(self):
        return f"{self.title} at {self.company}"
