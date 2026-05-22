from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('reviews', '0003_evaluation_recruiter_reply_evaluation_recruiter_reply_date'),
    ]

    operations = [
        migrations.AddField(
            model_name='evaluation',
            name='recruiter_name',
            field=models.CharField(blank=True, max_length=200, null=True),
        ),
    ]
