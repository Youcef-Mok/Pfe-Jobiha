#!/usr/bin/env python
"""Quick script to verify message types are correct."""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from apps.messaging.models import Message

print('\n📋 Recent messages with URLs:\n')
msgs = Message.objects.filter(contenu__istartswith='http').order_by('-date_envoi')[:5]
for m in msgs:
    print(f'  ID: {m.id:3} | Type: {m.type:8} | Content: {m.contenu[:60]}...')

print(f'\n📊 Message Type Summary:')
print(f'  ✅ Image messages: {Message.objects.filter(type="image").count()}')
print(f'  ✅ File messages:  {Message.objects.filter(type="file").count()}')
print(f'  ✅ Text messages:  {Message.objects.filter(type="text").count()}')
print(f'  📝 Total messages: {Message.objects.count()}\n')
