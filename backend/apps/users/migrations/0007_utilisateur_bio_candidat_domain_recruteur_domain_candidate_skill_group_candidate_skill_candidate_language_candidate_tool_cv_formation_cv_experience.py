from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0006_utilisateur_avatar_url_utilisateur_location_candidat_titre_poste_recruteur_logo_url_recruteur_titre_poste_restricteduser'),
    ]

    operations = [
        # Fields on existing models
        migrations.AddField(
            model_name='utilisateur',
            name='bio',
            field=models.TextField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='candidat',
            name='domain',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
        migrations.AddField(
            model_name='recruteur',
            name='domain',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),

        # CandidateSkillGroup
        migrations.CreateModel(
            name='CandidateSkillGroup',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=100)),
                ('order', models.IntegerField(default=0)),
                ('candidat', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='skill_groups', to='users.candidat')),
            ],
            options={'db_table': 'candidate_skill_group', 'ordering': ['order']},
        ),

        # CandidateSkill
        migrations.CreateModel(
            name='CandidateSkill',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('level', models.CharField(choices=[('debutant', 'Débutant'), ('intermediaire', 'Intermédiaire'), ('avance', 'Avancé'), ('expert', 'Expert')], max_length=20)),
                ('group', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='skills', to='users.candidateskillgroup')),
            ],
            options={'db_table': 'candidate_skill'},
        ),

        # CandidateLanguage
        migrations.CreateModel(
            name='CandidateLanguage',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
                ('proficiency', models.CharField(max_length=50)),
                ('candidat', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='languages', to='users.candidat')),
            ],
            options={'db_table': 'candidate_language'},
        ),

        # CandidateTool
        migrations.CreateModel(
            name='CandidateTool',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('candidat', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='tools', to='users.candidat')),
            ],
            options={'db_table': 'candidate_tool'},
        ),

        # CvFormation
        migrations.CreateModel(
            name='CvFormation',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=200)),
                ('institution', models.CharField(max_length=200)),
                ('location', models.CharField(max_length=200)),
                ('year', models.IntegerField()),
                ('is_active', models.BooleanField(default=False)),
                ('file_name', models.CharField(blank=True, max_length=200, null=True)),
                ('file_path', models.CharField(blank=True, max_length=500, null=True)),
                ('candidat', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='formations', to='users.candidat')),
            ],
            options={'db_table': 'cv_formation', 'ordering': ['-year']},
        ),

        # CvExperience
        migrations.CreateModel(
            name='CvExperience',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=200)),
                ('company', models.CharField(max_length=200)),
                ('location', models.CharField(max_length=200)),
                ('period', models.CharField(blank=True, max_length=100, null=True)),
                ('end_date', models.CharField(blank=True, max_length=50, null=True)),
                ('is_app_mission', models.BooleanField(default=False)),
                ('is_active', models.BooleanField(default=False)),
                ('candidat', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='experiences', to='users.candidat')),
            ],
            options={'db_table': 'cv_experience'},
        ),
    ]
