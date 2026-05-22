from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('reviews', '0002_alter_evaluation_note_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='evaluation',
            name='recruiter_reply',
            field=models.TextField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='evaluation',
            name='recruiter_reply_date',
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
