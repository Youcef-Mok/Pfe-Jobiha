from django.db import models


class RestrictedUser(models.Model):
    """
    Contacts restreints - allows users to restrict other users.
    Similar to BlockedUser but for restricted contacts.
    """
    restricteur = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="utilisateurs_restreints"
    )
    restreint = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="restreint_par"
    )
    date_restriction = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "restricted_user"
        unique_together = [("restricteur", "restreint")]

    def __str__(self):
        return f"{self.restricteur} restricted {self.restreint}"
