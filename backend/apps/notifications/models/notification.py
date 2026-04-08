from django.db import models
from apps.uploads.models import Utilisateur


# ---------------------------------------------------------------------------
# Notification
# ---------------------------------------------------------------------------
 
class Notification(models.Model):
    utilisateur = models.ForeignKey(
        Utilisateur, on_delete=models.CASCADE, related_name="notifications"
    )
    contenu = models.TextField()
    type = models.CharField(max_length=50)
    date_envoi = models.DateTimeField(auto_now_add=True)
    est_lue = models.BooleanField(default=False)
 
    class Meta:
        db_table = "notification"
 
    def __str__(self):
        return f"Notif [{self.type}] → {self.utilisateur}"
 
    def envoyer(self):
        pass