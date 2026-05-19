from django.db import models


class UserSettings(models.Model):
    user = models.OneToOneField(
        "users.Utilisateur", on_delete=models.CASCADE, related_name="settings"
    )
    notifications_enabled = models.BooleanField(default=True)
    dark_mode = models.BooleanField(default=False)
    language_code = models.CharField(max_length=10, default="fr")

    class Meta:
        db_table = "user_settings"

    def __str__(self):
        return f"Settings for {self.user}"
