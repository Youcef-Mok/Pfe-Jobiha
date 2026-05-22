from django.db import models


class Interview(models.Model):
    STATUS_CHOICES = [
        ("scheduled", "Scheduled"),
        ("completed", "Completed"),
        ("cancelled", "Cancelled"),
    ]

    candidate = models.ForeignKey(
        "users.Utilisateur", on_delete=models.CASCADE, related_name="interviews_as_candidate"
    )
    recruiter = models.ForeignKey(
        "users.Utilisateur", on_delete=models.CASCADE, related_name="interviews_as_recruiter"
    )
    job = models.ForeignKey(
        "jobs.Offre", on_delete=models.CASCADE, related_name="interviews"
    )
    scheduled_date = models.DateTimeField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="scheduled")
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "interview"

    def __str__(self):
        return f"Interview #{self.pk} – {self.status}"
