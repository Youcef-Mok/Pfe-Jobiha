from django.db import models


# ---------------------------------------------------------------------------
# Utilisateur (base user)
# ---------------------------------------------------------------------------

class Utilisateur(models.Model):
    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    mot_de_passe = models.CharField(max_length=255)
    telephone = models.CharField(max_length=20, blank=True, null=True)
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)
    date_inscription = models.DateField(auto_now_add=True)
    est_verifie = models.BooleanField(default=False)
    statut_compte = models.CharField(max_length=50, default="actif")

    class Meta:
        db_table = "utilisateur"

    def __str__(self):
        return f"{self.prenom} {self.nom}"

    def sinscrire(self):
        pass

    def se_connecter(self):
        pass

    def modifier_profil(self):
        pass
