#!/usr/bin/env python
"""
Script de test pour vérifier l'API de messagerie.
Usage: python test_messaging_api.py
"""

import os
import sys
import django

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from apps.messaging.models.message import Message
from apps.messaging.models.conversation import Conversation, ConversationMember
from apps.messaging.serializers import MessageSerializer
from apps.users.models import Utilisateur
from django.test import RequestFactory


def test_message_serializer():
    """Test que MessageSerializer retourne is_mine correctement."""
    print("\n" + "="*80)
    print("TEST: MessageSerializer avec is_mine")
    print("="*80)
    
    # Utiliser les deux premiers utilisateurs existants
    users = Utilisateur.objects.all()[:2]
    
    if len(users) < 2:
        print("❌ ERREUR: Il faut au moins 2 utilisateurs dans la base de données")
        print("Créez des utilisateurs via l'interface admin ou l'API d'inscription")
        return
    
    user1 = users[0]
    user2 = users[1]
    
    print(f"✓ User1: id={user1.id}, email={user1.email}")
    print(f"✓ User2: id={user2.id}, email={user2.email}")
    
    # Créer une conversation
    conv = Conversation.objects.create(
        type=Conversation.TYPE_DIRECT,
        created_by=user1
    )
    ConversationMember.objects.create(
        conversation=conv,
        user=user1,
        role=ConversationMember.ROLE_MEMBER
    )
    ConversationMember.objects.create(
        conversation=conv,
        user=user2,
        role=ConversationMember.ROLE_MEMBER
    )
    print(f"✓ Conversation créée: id={conv.id}")
    
    # Créer un message de user1
    msg = Message.objects.create(
        conversation=conv,
        expediteur=user1,
        contenu="Test message from user1"
    )
    print(f"✓ Message créé: id={msg.id}, expediteur_id={msg.expediteur_id}")
    
    # Créer une fausse requête avec user1
    factory = RequestFactory()
    request1 = factory.get('/')
    request1.user = user1
    
    # Sérialiser avec le contexte de user1
    serializer1 = MessageSerializer(msg, context={'request': request1})
    data1 = serializer1.data
    
    print(f"\n--- Sérialisé pour user1 (expediteur) ---")
    print(f"expediteur.id: {data1['expediteur']['id']}")
    print(f"is_mine: {data1['is_mine']}")
    print(f"Attendu: is_mine=True")
    
    if data1['is_mine'] == True:
        print("✅ PASS: is_mine est True pour l'expéditeur")
    else:
        print("❌ FAIL: is_mine devrait être True pour l'expéditeur")
    
    # Créer une fausse requête avec user2
    request2 = factory.get('/')
    request2.user = user2
    
    # Sérialiser avec le contexte de user2
    serializer2 = MessageSerializer(msg, context={'request': request2})
    data2 = serializer2.data
    
    print(f"\n--- Sérialisé pour user2 (destinataire) ---")
    print(f"expediteur.id: {data2['expediteur']['id']}")
    print(f"is_mine: {data2['is_mine']}")
    print(f"Attendu: is_mine=False")
    
    if data2['is_mine'] == False:
        print("✅ PASS: is_mine est False pour le destinataire")
    else:
        print("❌ FAIL: is_mine devrait être False pour le destinataire")
    
    # Vérifier la structure complète
    print(f"\n--- Structure complète du message ---")
    print(f"id: {data1['id']}")
    print(f"contenu: {data1['contenu']}")
    print(f"date_envoi: {data1['date_envoi']}")
    print(f"conversation_id: {data1['conversation_id']}")
    print(f"expediteur: {data1['expediteur']}")
    print(f"is_mine: {data1['is_mine']}")
    
    # Vérifier que tous les champs sont présents
    required_fields = ['id', 'contenu', 'date_envoi', 'conversation_id', 'expediteur', 'is_mine']
    missing_fields = [f for f in required_fields if f not in data1]
    
    if not missing_fields:
        print("✅ PASS: Tous les champs requis sont présents")
    else:
        print(f"❌ FAIL: Champs manquants: {missing_fields}")
    
    # Vérifier que expediteur contient id, nom, prenom
    expediteur_fields = ['id', 'nom', 'prenom']
    missing_exp_fields = [f for f in expediteur_fields if f not in data1['expediteur']]
    
    if not missing_exp_fields:
        print("✅ PASS: expediteur contient id, nom, prenom")
    else:
        print(f"❌ FAIL: expediteur manque: {missing_exp_fields}")
    
    print("\n" + "="*80)
    print("TEST TERMINÉ")
    print("="*80 + "\n")


if __name__ == '__main__':
    test_message_serializer()
