from django.db import models


class MissionTeamMember(models.Model):
    mission = models.ForeignKey(
        "jobs.Mission", on_delete=models.CASCADE, related_name="team"
    )
    name = models.CharField(max_length=200)
    role = models.CharField(max_length=100)
    rating = models.FloatField(default=0.0)
    avatar_url = models.CharField(max_length=500, blank=True, null=True)

    class Meta:
        db_table = "mission_team_member"

    def __str__(self):
        return f"{self.name} ({self.role})"
