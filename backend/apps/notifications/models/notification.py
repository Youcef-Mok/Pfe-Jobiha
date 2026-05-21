from django.db import models


# ---------------------------------------------------------------------------
# Notification
# ---------------------------------------------------------------------------

class Notification(models.Model):
    utilisateur = models.ForeignKey(
       "users.Utilisateur", on_delete=models.CASCADE, related_name="notifications"
    )
    contenu = models.TextField()
    type = models.CharField(max_length=50)
    date_envoi = models.DateTimeField(auto_now_add=True)
    est_lue = models.BooleanField(default=False)
    title = models.CharField(max_length=200, blank=True)
    job_title = models.CharField(max_length=200, blank=True, null=True)
    sender_name = models.CharField(max_length=200, blank=True, null=True)
    avatar_url = models.CharField(max_length=500, blank=True, null=True)
    # Changed from default=1 to nullable (DB-CHANGES.md section 9)
    count = models.IntegerField(blank=True, null=True)
    # New field from DB-CHANGES.md section 9
    context_image_url = models.CharField(max_length=500, blank=True, null=True)

    class Meta:
        db_table = "notification"

    def __str__(self):
        return f"Notif [{self.type}] → {self.utilisateur}"

    def envoyer(self):
        pass