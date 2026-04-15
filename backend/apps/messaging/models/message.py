from django.db import models



# ---------------------------------------------------------------------------
# Message
# ---------------------------------------------------------------------------

class Message(models.Model):
    contenu = models.TextField()
    date_envoi = models.DateTimeField(auto_now_add=True)
    est_lu = models.BooleanField(default=False)
    expediteur = models.ForeignKey(
        "users.Utilisateur", on_delete=models.CASCADE, related_name="messages_envoyes"
    )
    destinataire = models.ForeignKey(
        "users.Utilisateur", on_delete=models.CASCADE, related_name="messages_recus"
    )

    class Meta:
        db_table = "message"

    def __str__(self):
        return f"Msg de {self.expediteur} à {self.destinataire}"

    def envoyer(self):
        pass

    def marquer_lu(self):
        pass