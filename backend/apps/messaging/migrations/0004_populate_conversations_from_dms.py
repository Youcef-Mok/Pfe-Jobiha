# Data migration: wrap every existing DM pair into a Conversation.

from django.db import migrations


def forwards(apps, schema_editor):
    Message = apps.get_model('messaging', 'Message')
    Conversation = apps.get_model('messaging', 'Conversation')
    ConversationMember = apps.get_model('messaging', 'ConversationMember')
    ReadCursor = apps.get_model('messaging', 'ReadCursor')

    # 1. Collect unique DM pairs (order-independent)
    pairs = set()
    for exp_id, dest_id in (
        Message.objects
        .values_list('expediteur_id', 'destinataire_id')
        .distinct()
    ):
        if exp_id and dest_id:
            pairs.add(tuple(sorted([exp_id, dest_id])))

    # 2. For each pair, create Conversation + members + link messages
    for user_a, user_b in pairs:
        conv = Conversation.objects.create(type='direct')
        ConversationMember.objects.create(
            conversation=conv, user_id=user_a, role='member',
        )
        ConversationMember.objects.create(
            conversation=conv, user_id=user_b, role='member',
        )

        # Link messages to this conversation
        Message.objects.filter(
            expediteur_id__in=[user_a, user_b],
            destinataire_id__in=[user_a, user_b],
            conversation__isnull=True,
        ).update(conversation=conv)

        # Create ReadCursors from est_lu
        for uid in [user_a, user_b]:
            last_read = (
                Message.objects
                .filter(conversation=conv, destinataire_id=uid, est_lu=True)
                .order_by('-date_envoi')
                .first()
            )
            if last_read:
                ReadCursor.objects.create(
                    conversation=conv,
                    user_id=uid,
                    last_read_message=last_read,
                )


def backwards(apps, schema_editor):
    # Reverse: clear conversation FK, delete created conversations
    Message = apps.get_model('messaging', 'Message')
    Conversation = apps.get_model('messaging', 'Conversation')
    Message.objects.all().update(conversation=None)
    Conversation.objects.filter(type='direct').delete()


class Migration(migrations.Migration):

    dependencies = [
        ('messaging', '0003_add_conversation_models'),
    ]

    operations = [
        migrations.RunPython(forwards, backwards),
    ]
