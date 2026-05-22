from django.db import models


class CvExperience(models.Model):
    candidat = models.ForeignKey(
        "users.Candidat", on_delete=models.CASCADE, related_name="experiences"
    )
    title = models.CharField(max_length=200)
    company = models.CharField(max_length=200)
    location = models.CharField(max_length=200)
    period = models.CharField(max_length=100, blank=True, null=True)
    end_date = models.CharField(max_length=50, blank=True, null=True)
    is_app_mission = models.BooleanField(default=False)
    is_active = models.BooleanField(default=False)

    class Meta:
        db_table = "cv_experience"

    def __str__(self):
        return f"{self.title} — {self.company}"
