from django.db.models.signals import post_save
from django.dispatch import receiver


@receiver(post_save, sender='users.Utilisateur')
def create_user_settings(sender, instance, created, **kwargs):
    """Auto-create UserSettings for every new user."""
    if created:
        from apps.users.models.settings import UserSettings
        UserSettings.objects.get_or_create(user=instance)
