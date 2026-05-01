# apps/users/models/blocked_user.py
from django.db import models

class BlockedUser(models.Model):
    bloqueur = models.ForeignKey(
        'users.Utilisateur', on_delete=models.CASCADE, related_name='utilisateurs_bloques'
    )
    bloque = models.ForeignKey(
        'users.Utilisateur', on_delete=models.CASCADE, related_name='bloque_par'
    )
    date_blocage = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'blocked_user'
        unique_together = [('bloqueur', 'bloque')]

    def __str__(self):
        return f"{self.bloqueur} blocked {self.bloque}"