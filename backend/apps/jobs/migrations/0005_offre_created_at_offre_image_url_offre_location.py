from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('jobs', '0004_mission_image_url_mission_location_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='offre',
            name='created_at',
            field=models.DateTimeField(auto_now_add=True, null=True),
        ),
        migrations.AddField(
            model_name='offre',
            name='image_url',
            field=models.CharField(blank=True, max_length=500, null=True),
        ),
        migrations.AddField(
            model_name='offre',
            name='location',
            field=models.CharField(blank=True, max_length=200, null=True),
        ),
    ]
