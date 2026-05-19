from django.db import models


class RecentSearch(models.Model):
    user = models.ForeignKey(
        "users.Utilisateur", on_delete=models.CASCADE, related_name="recent_searches"
    )
    query = models.CharField(max_length=200)
    searched_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "recent_search"
        ordering = ["-searched_at"]

    def __str__(self):
        return f"{self.user} searched '{self.query}'"
