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
    push_notif_enabled = models.BooleanField(default=True)
    # New fields from DB-CHANGES.md section 1
    avatar_url = models.CharField(max_length=500, blank=True, null=True)
    location = models.CharField(max_length=200, blank=True)
    bio = models.TextField(blank=True)

    class Meta:
        db_table = "utilisateur"

    def __str__(self):
        return f"{self.prenom} {self.nom}"

    # ---- DRF / JWT compatibility properties (no DB changes) ----

    @property
    def is_authenticated(self):
        """Required by DRF's IsAuthenticated permission."""
        return True

    @property
    def is_anonymous(self):
        """Required by DRF internals."""
        return False

    @property
    def role(self):
        """
        Determine user role by checking which child profile exists
        via multi-table inheritance reverse accessors.
        """
        try:
            self.candidat
            return 'candidat'
        except Exception:
            pass
        try:
            self.recruteur
            return 'recruteur'
        except Exception:
            pass
        return None

    def sinscrire(self):
        pass

    def se_connecter(self):
        pass

    def modifier_profil(self):
        pass
