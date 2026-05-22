from django.db import models


# ---------------------------------------------------------------------------
# Administrateur
# ---------------------------------------------------------------------------

class Administrateur(models.Model):
    nom = models.CharField(max_length=100)
    email = models.EmailField(unique=True)

    class Meta:
        db_table = "administrateur"

    def __str__(self):
        return self.nom

    def examiner_signalement(self, signalement):
        pass

    def sanctionner_utilisateur(self, utilisateur):
        pass

    def bloquer_utilisateur(self, utilisateur):
        pass