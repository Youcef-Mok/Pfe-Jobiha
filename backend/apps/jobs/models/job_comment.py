from django.db import models


class JobComment(models.Model):
    """
    Questions and answers on job postings.
    Displayed in the job detail page comments section.
    """
    offre = models.ForeignKey(
        "jobs.Offre",
        on_delete=models.CASCADE,
        related_name="comments"
    )
    auteur = models.ForeignKey(
        "users.Utilisateur",
        on_delete=models.CASCADE,
        related_name="job_comments"
    )
    question = models.TextField()
    reponse = models.TextField(blank=True)
    date_question = models.DateTimeField(auto_now_add=True)
    date_reponse = models.DateTimeField(blank=True, null=True)

    class Meta:
        db_table = "job_comment"
        ordering = ["-date_question"]

    def __str__(self):
        return f"Comment on {self.offre.titre} by {self.auteur}"