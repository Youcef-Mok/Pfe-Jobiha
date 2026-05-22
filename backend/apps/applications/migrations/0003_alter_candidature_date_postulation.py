from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('applications', '0002_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='candidature',
            name='date_postulation',
            field=models.DateTimeField(auto_now_add=True),
        ),
    ]
