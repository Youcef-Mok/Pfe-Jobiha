from django.db import models


# ---------------------------------------------------------------------------
# Media
# ---------------------------------------------------------------------------

class Media(models.Model):
    url = models.URLField()
    type = models.CharField(max_length=50)
    date_ajout = models.DateField(auto_now_add=True)

    class Meta:
        db_table = "media"

    def __str__(self):
        return f"{self.type}: {self.url}"