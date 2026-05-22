from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('messaging', '0005_conversationmember_is_invitation'),
    ]

    operations = [
        migrations.AddField(
            model_name='message',
            name='type',
            field=models.CharField(
                choices=[('text', 'Text'), ('image', 'Image'), ('file', 'File')],
                default='text',
                max_length=20,
            ),
        ),
    ]
