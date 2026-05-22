from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0007_utilisateur_bio_candidat_domain_recruteur_domain_candidate_skill_group_candidate_skill_candidate_language_candidate_tool_cv_formation_cv_experience'),
    ]

    operations = [
        migrations.AddField(
            model_name='utilisateur',
            name='push_token',
            field=models.CharField(blank=True, max_length=500, null=True),
        ),
    ]
