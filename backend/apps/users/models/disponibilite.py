from django.db import models



# ---------------------------------------------------------------------------
# Disponibilite
# ---------------------------------------------------------------------------
 
class Disponibilite(models.Model):
    jour = models.CharField(max_length=20)
    heure_debut = models.TimeField()
    heure_fin = models.TimeField()
 
    class Meta:
        db_table = "disponibilite"
 
    def __str__(self):
        return f"{self.jour} {self.heure_debut}-{self.heure_fin}"