from django.db import models
from django.utils import timezone


class RestrictedUser(models.Model):
    """
    A user who has been restricted (muted/limited) by another user.
    Restricted contacts can still send messages but notifications are silenced.
    Distinct from BlockedUser where all communication is blocked.
    """
    restricteur = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="restrictions_donnees",
    )
    restreint = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="restrictions_recues",
    )
    date_restriction = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "restricted_user"
        unique_together = [("restricteur", "restreint")]

    def __str__(self):
        return f"{self.restricteur} → restricted → {self.restreint}"
