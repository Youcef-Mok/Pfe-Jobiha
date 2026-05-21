from django.db import models


class CvFormation(models.Model):
    """
    Educational background/formations for candidate CV.
    """
    candidat = models.ForeignKey(
        "users.Candidat",
        on_delete=models.CASCADE,
        related_name="formations"
    )
    title = models.CharField(max_length=200)
    institution = models.CharField(max_length=200)
    location = models.CharField(max_length=200)
    year = models.IntegerField()
    is_active = models.BooleanField(default=False)
    file_name = models.CharField(max_length=200, blank=True, null=True)
    file_path = models.CharField(max_length=500, blank=True, null=True)

    class Meta:
        db_table = "cv_formation"
        ordering = ["-year"]

    def __str__(self):
        return f"{self.title} - {self.institution} ({self.year})"
