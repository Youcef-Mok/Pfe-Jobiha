from django.db import models


# ---------------------------------------------------------------------------
# Media
# ---------------------------------------------------------------------------

class Media(models.Model):
    TYPE_CHOICES = [
        ('image', 'Image'),
        ('video', 'Video'),
        ('document', 'Document'),
    ]

    candidat   = models.ForeignKey(
        'users.Candidat',
        on_delete=models.CASCADE,
        related_name='medias'
    )
    url        = models.URLField(blank=True)
    type_media = models.CharField(max_length=50, choices=TYPE_CHOICES)
    description = models.CharField(max_length=300, blank=True, null=True)
    created_at  = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'media'

    def __str__(self):
        return f"{self.type_media}: {self.url}"