"""
Management command to fix message types for existing messages.
Updates messages with image/file URLs to have the correct type.

Usage:
    python manage.py fix_message_types
"""
from django.core.management.base import BaseCommand
from apps.messaging.models.message import Message


class Command(BaseCommand):
    help = 'Fix message types for existing messages with image/file URLs'

    def handle(self, *args, **options):
        self.stdout.write('Fixing message types...\n')
        
        # Find messages with URLs that should be images
        image_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg']
        file_extensions = ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.txt', '.zip', '.rar']
        
        # Fix image messages
        image_count = 0
        for ext in image_extensions:
            messages = Message.objects.filter(
                contenu__icontains=f'/media/chat_images/',
                type='text'
            ) | Message.objects.filter(
                contenu__iendswith=ext,
                contenu__istartswith='http',
                type='text'
            )
            count = messages.update(type='image')
            image_count += count
            if count > 0:
                self.stdout.write(f'  Updated {count} messages with {ext} to type="image"')
        
        # Fix file messages
        file_count = 0
        for ext in file_extensions:
            messages = Message.objects.filter(
                contenu__icontains=f'/media/chat_files/',
                type='text'
            ) | Message.objects.filter(
                contenu__iendswith=ext,
                contenu__istartswith='http',
                type='text'
            )
            count = messages.update(type='file')
            file_count += count
            if count > 0:
                self.stdout.write(f'  Updated {count} messages with {ext} to type="file"')
        
        # Summary
        self.stdout.write(self.style.SUCCESS(
            f'\n✅ Fixed {image_count} image messages and {file_count} file messages'
        ))
        
        if image_count == 0 and file_count == 0:
            self.stdout.write(self.style.WARNING(
                '⚠️  No messages needed fixing. All messages already have correct types.'
            ))
