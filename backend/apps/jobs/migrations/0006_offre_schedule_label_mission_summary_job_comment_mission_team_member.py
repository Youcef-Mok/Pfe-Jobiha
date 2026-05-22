from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('jobs', '0005_offre_created_at_offre_image_url_offre_location'),
        ('users', '0007_utilisateur_bio_candidat_domain_recruteur_domain_candidate_skill_group_candidate_skill_candidate_language_candidate_tool_cv_formation_cv_experience'),
    ]

    operations = [
        migrations.AddField(
            model_name='offre',
            name='schedule_label',
            field=models.CharField(blank=True, max_length=50, null=True),
        ),
        migrations.AddField(
            model_name='mission',
            name='summary',
            field=models.TextField(blank=True, null=True),
        ),
        migrations.CreateModel(
            name='JobComment',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('question', models.TextField()),
                ('reponse', models.TextField(blank=True)),
                ('date_question', models.DateTimeField(auto_now_add=True)),
                ('date_reponse', models.DateTimeField(blank=True, null=True)),
                ('auteur', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='job_comments', to='users.utilisateur')),
                ('offre', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='comments', to='jobs.offre')),
            ],
            options={'db_table': 'job_comment', 'ordering': ['-date_question']},
        ),
        migrations.CreateModel(
            name='MissionTeamMember',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('role', models.CharField(max_length=100)),
                ('rating', models.FloatField(default=0.0)),
                ('avatar_url', models.CharField(blank=True, max_length=500, null=True)),
                ('mission', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='team', to='jobs.mission')),
            ],
            options={'db_table': 'mission_team_member'},
        ),
    ]
