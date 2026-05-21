#!/usr/bin/env python
"""
Script de test pour vérifier les endpoints de messagerie.
Usage: python test_messaging_endpoints.py
"""

import requests
import json
from typing import Dict, Any

# Configuration
BASE_URL = "http://localhost:8000/api/v1"
TOKEN = ""  # À remplir avec un token valide

HEADERS = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}


def print_response(title: str, response: requests.Response):
    """Affiche une réponse de manière formatée."""
    print(f"\n{'='*80}")
    print(f"TEST: {title}")
    print(f"{'='*80}")
    print(f"Status: {response.status_code}")
    try:
        data = response.json()
        print(f"Response:\n{json.dumps(data, indent=2, ensure_ascii=False)}")
    except:
        print(f"Response: {response.text}")


def test_get_conversations():
    """Test GET /conversations"""
    response = requests.get(f"{BASE_URL}/conversations", headers=HEADERS)
    print_response("GET /conversations", response)
    
    if response.status_code == 200:
        data = response.json()
        if isinstance(data, list) and len(data) > 0:
            conv = data[0]
            required_fields = [
                'id', 'contact_name', 'contact_role', 'contact_avatar',
                'is_online', 'last_message', 'last_message_time',
                'is_unread', 'is_invitation', 'is_group', 'group_name',
                'member_avatars', 'member_names'
            ]
            missing = [f for f in required_fields if f not in conv]
            if missing:
                print(f"❌ Champs manquants: {missing}")
            else:
                print("✅ Tous les champs requis sont présents")
    return response


def test_create_conversation(contact_id: int):
    """Test POST /conversations"""
    payload = {"contact_id": contact_id}
    response = requests.post(
        f"{BASE_URL}/conversations",
        headers=HEADERS,
        json=payload
    )
    print_response(f"POST /conversations (contact_id={contact_id})", response)
    
    if response.status_code in [200, 201]:
        data = response.json()
        required_fields = [
            'id', 'contact_name', 'contact_role', 'contact_avatar',
            'is_online', 'last_message', 'last_message_time',
            'is_unread', 'is_invitation', 'is_group', 'group_name',
            'member_avatars', 'member_names'
        ]
        missing = [f for f in required_fields if f not in data]
        if missing:
            print(f"❌ Champs manquants: {missing}")
        else:
            print("✅ Tous les champs requis sont présents")
        return data.get('id')
    return None


def test_get_messages(conversation_id: int):
    """Test GET /conversations/:id (messages)"""
    response = requests.get(
        f"{BASE_URL}/conversations/{conversation_id}",
        headers=HEADERS
    )
    print_response(f"GET /conversations/{conversation_id}", response)
    
    if response.status_code == 200:
        data = response.json()
        required_fields = ['count', 'next', 'previous', 'results']
        missing = [f for f in required_fields if f not in data]
        if missing:
            print(f"❌ Champs manquants: {missing}")
        else:
            print("✅ Structure de pagination correcte")
            
            if data['results']:
                msg = data['results'][0]
                msg_fields = ['id', 'contenu', 'date_envoi', 'conversation_id', 'expediteur']
                msg_missing = [f for f in msg_fields if f not in msg]
                if msg_missing:
                    print(f"❌ Champs message manquants: {msg_missing}")
                else:
                    print("✅ Structure de message correcte")
    return response


def test_send_message(conversation_id: int, content: str):
    """Test POST /conversations/:id/messages"""
    payload = {"contenu": content}
    response = requests.post(
        f"{BASE_URL}/conversations/{conversation_id}/messages",
        headers=HEADERS,
        json=payload
    )
    print_response(f"POST /conversations/{conversation_id}/messages", response)
    
    if response.status_code == 201:
        data = response.json()
        required_fields = ['id', 'contenu', 'date_envoi', 'conversation_id', 'expediteur']
        missing = [f for f in required_fields if f not in data]
        if missing:
            print(f"❌ Champs manquants: {missing}")
        else:
            print("✅ Message créé avec tous les champs requis")
    return response


def test_mark_read(conversation_id: int):
    """Test POST /conversations/:id/read-all"""
    response = requests.post(
        f"{BASE_URL}/conversations/{conversation_id}/read-all",
        headers=HEADERS
    )
    print_response(f"POST /conversations/{conversation_id}/read-all", response)
    return response


def test_create_group(group_name: str, member_ids: list):
    """Test POST /conversations/group"""
    payload = {
        "group_name": group_name,
        "member_ids": member_ids
    }
    response = requests.post(
        f"{BASE_URL}/conversations/group",
        headers=HEADERS,
        json=payload
    )
    print_response("POST /conversations/group", response)
    
    if response.status_code == 201:
        data = response.json()
        if data.get('is_group'):
            print("✅ Groupe créé avec is_group=True")
        if data.get('group_name') == group_name:
            print(f"✅ Nom du groupe correct: {group_name}")
        if data.get('member_names'):
            print(f"✅ Membres présents: {data['member_names']}")
    return response


def main():
    """Exécute tous les tests."""
    print("="*80)
    print("TESTS DES ENDPOINTS DE MESSAGERIE")
    print("="*80)
    
    if not TOKEN:
        print("\n❌ ERREUR: Veuillez définir un TOKEN valide dans le script")
        print("   1. Connectez-vous via POST /auth/login")
        print("   2. Copiez le access_token")
        print("   3. Définissez TOKEN = 'votre_token' dans ce script")
        return
    
    # Test 1: Liste des conversations
    print("\n\n📋 TEST 1: Liste des conversations")
    test_get_conversations()
    
    # Test 2: Créer une conversation (remplacer 2 par un ID utilisateur valide)
    print("\n\n💬 TEST 2: Créer une conversation")
    print("⚠️  Remplacez contact_id=2 par un ID utilisateur valide")
    # conv_id = test_create_conversation(contact_id=2)
    
    # Test 3: Récupérer les messages (remplacer 1 par un ID conversation valide)
    print("\n\n📨 TEST 3: Récupérer les messages")
    print("⚠️  Remplacez conversation_id=1 par un ID valide")
    # test_get_messages(conversation_id=1)
    
    # Test 4: Envoyer un message
    print("\n\n✉️  TEST 4: Envoyer un message")
    print("⚠️  Remplacez conversation_id=1 par un ID valide")
    # test_send_message(conversation_id=1, content="Test message")
    
    # Test 5: Marquer comme lu
    print("\n\n✅ TEST 5: Marquer comme lu")
    print("⚠️  Remplacez conversation_id=1 par un ID valide")
    # test_mark_read(conversation_id=1)
    
    # Test 6: Créer un groupe
    print("\n\n👥 TEST 6: Créer un groupe")
    print("⚠️  Remplacez member_ids=[2, 3] par des IDs valides")
    # test_create_group(group_name="Test Group", member_ids=[2, 3])
    
    print("\n\n" + "="*80)
    print("TESTS TERMINÉS")
    print("="*80)
    print("\n💡 Décommentez les tests dans main() pour les exécuter")
    print("💡 Remplacez les IDs par des valeurs valides de votre base de données")


if __name__ == "__main__":
    main()
