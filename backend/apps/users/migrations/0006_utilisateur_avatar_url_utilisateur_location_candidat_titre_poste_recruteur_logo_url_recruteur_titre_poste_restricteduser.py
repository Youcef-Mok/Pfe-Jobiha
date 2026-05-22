from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0005_recentsearch_usersettings'),
    ]

    operations = [
        # Utilisateur — avatar_url + location
        migrations.AddField(
            model_name='utilisateur',
            name='avatar_url',
            field=models.CharField(blank=True, max_length=500, null=True),
        ),
        migrations.AddField(
            model_name='utilisateur',
            name='location',
            field=models.CharField(blank=True, max_length=200, null=True),
        ),

        # Candidat — titre_poste
        migrations.AddField(
            model_name='candidat',
            name='titre_poste',
            field=models.CharField(blank=True, max_length=200, null=True),
        ),

        # Recruteur — titre_poste + logo_url
        migrations.AddField(
            model_name='recruteur',
            name='titre_poste',
            field=models.CharField(blank=True, max_length=200, null=True),
        ),
        migrations.AddField(
            model_name='recruteur',
            name='logo_url',
            field=models.CharField(blank=True, max_length=500, null=True),
        ),

        # RestrictedUser — new model
        migrations.CreateModel(
            name='RestrictedUser',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('date_restriction', models.DateTimeField(default=django.utils.timezone.now)),
                ('restricteur', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='restrictions_donnees',
                    to='users.utilisateur',
                )),
                ('restreint', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='restrictions_recues',
                    to='users.utilisateur',
                )),
            ],
            options={
                'db_table': 'restricted_user',
                'unique_together': {('restricteur', 'restreint')},
            },
        ),
    ]
