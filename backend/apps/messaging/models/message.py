from django.db import models



# ---------------------------------------------------------------------------
# Message
# ---------------------------------------------------------------------------

class Message(models.Model):
    contenu = models.TextField()
    date_envoi = models.DateTimeField(auto_now_add=True)

    # ── New: unified conversation FK ──────────────────────────────────────
    conversation = models.ForeignKey(
        'messaging.Conversation',
        on_delete=models.CASCADE,
        related_name='messages',
        null=True,       # nullable during migration only
        blank=True,
    )

    expediteur = models.ForeignKey(
        "users.Utilisateur", on_delete=models.CASCADE, related_name="messages_envoyes"
    )

    # ── Legacy fields — kept for backward-compat during migration ─────────
    type = models.CharField(
        max_length=20,
        choices=[('text', 'Text'), ('image', 'Image'), ('file', 'File')],
        default='text',
    )
    est_lu = models.BooleanField(default=False)
    destinataire = models.ForeignKey(
        "users.Utilisateur", on_delete=models.CASCADE, related_name="messages_recus",
        null=True, blank=True,
    )

    class Meta:
        db_table = "message"
        ordering = ["date_envoi"]
        indexes = [
            models.Index(
                fields=["conversation", "date_envoi"],
                name="idx_msg_conv_date",
            ),
            models.Index(
                fields=["expediteur", "date_envoi"],
                name="idx_msg_exp_date",
            ),
        ]

    def __str__(self):
        return f"Msg #{self.pk} in conv {self.conversation_id}"

    def envoyer(self):
        pass

    def marquer_lu(self):
        """Legacy — kept for backward compat during migration."""
        if not self.est_lu:
            self.est_lu = True
            self.save(update_fields=["est_lu"])