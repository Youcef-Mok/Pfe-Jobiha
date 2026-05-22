from django.db import models


class CandidateSkillGroup(models.Model):
    """
    Skill groups for candidate profile (e.g., "Technical Skills", "Soft Skills").
    """
    candidat = models.ForeignKey(
        "users.Candidat",
        on_delete=models.CASCADE,
        related_name="skill_groups"
    )
    title = models.CharField(max_length=100)
    order = models.IntegerField(default=0)

    class Meta:
        db_table = "candidate_skill_group"
        ordering = ["order"]

    def __str__(self):
        return f"{self.candidat} - {self.title}"


class CandidateSkill(models.Model):
    """
    Individual skills within a skill group.
    """
    LEVEL_CHOICES = [
        ("debutant",      "Débutant"),
        ("intermediaire", "Intermédiaire"),
        ("avance",        "Avancé"),
        ("expert",        "Expert"),
    ]

    group = models.ForeignKey(
        CandidateSkillGroup,
        on_delete=models.CASCADE,
        related_name="skills"
    )
    name = models.CharField(max_length=100)
    level = models.CharField(max_length=20, choices=LEVEL_CHOICES)

    class Meta:
        db_table = "candidate_skill"

    def __str__(self):
        return f"{self.name} ({self.level})"