from django.db import models
from django.utils import timezone


# ---------------------------------------------------------------------------
# SavedJob — a candidate bookmarks an offre
# ---------------------------------------------------------------------------

class SavedJob(models.Model):
    candidat   = models.ForeignKey(
        "users.Candidat", on_delete=models.CASCADE, related_name="saved_jobs"
    )
    offre      = models.ForeignKey(
        "jobs.Offre", on_delete=models.CASCADE, related_name="saved_by"
    )
    saved_at   = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "saved_job"
        unique_together = ("candidat", "offre")   # one bookmark per offer

    def __str__(self):
        return f"SavedJob(candidat={self.candidat_id}, offre={self.offre_id})"
