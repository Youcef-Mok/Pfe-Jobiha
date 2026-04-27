from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.db.models import Avg


# ---------------------------------------------------------------------------
# Evaluation
# ---------------------------------------------------------------------------

class Evaluation(models.Model):
    mission = models.ForeignKey(
        "jobs.Mission", on_delete=models.CASCADE, related_name="evaluations"
    )
    note = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    commentaire     = models.TextField(blank=True, null=True)
    evaluateur      = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="evaluations_donnees",
    )
    evalue          = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="evaluations_recues",
    )
    date_evaluation = models.DateField(auto_now_add=True)

    class Meta:
        db_table = "evaluation"
        # One evaluation per (evaluateur, mission) pair — prevents duplicates.
        unique_together = [("evaluateur", "mission")]

    def __str__(self):
        return f"Eval {self.note}/5 par {self.evaluateur}"

    def soumettre(self):
        pass


# ---------------------------------------------------------------------------
# Signal — recompute note_globale whenever an Evaluation is saved
# ---------------------------------------------------------------------------

@receiver(post_save, sender=Evaluation)
def update_note_globale(sender, instance, **kwargs):
    """
    Recompute and persist the average rating for the evaluated user.
    Works for both Candidat and Recruteur because both have a note_globale
    field and both are subclasses of Utilisateur.
    """
    evalue = instance.evalue
    avg = Evaluation.objects.filter(evalue=evalue).aggregate(
        moyenne=Avg("note")
    )["moyenne"]

    nouvelle_note = round(avg, 2) if avg is not None else 0.0

    # Try Candidat first, then Recruteur.
    for attr in ("candidat", "recruteur"):
        try:
            profile = getattr(evalue, attr)
            profile.note_globale = nouvelle_note
            profile.save(update_fields=["note_globale"])
            break
        except Exception:
            continue