from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('notifications', '0002_notification_avatar_url_notification_count_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='notification',
            name='context_image_url',
            field=models.CharField(blank=True, max_length=500, null=True),
        ),
    ]
