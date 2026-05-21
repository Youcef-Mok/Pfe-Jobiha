"""
Quick test for GET /users endpoint
"""
import requests

BASE_URL = 'http://localhost:8000/api/v1'

# First, login to get a token
login_response = requests.post(
    f'{BASE_URL}/auth/login',
    json={
        'email': 'test@test.com',
        'mot_de_passe': 'test123'
    }
)

if login_response.status_code != 200:
    print(f"Login failed: {login_response.status_code}")
    print(login_response.json())
    exit(1)

token = login_response.json()['access']
headers = {'Authorization': f'Bearer {token}'}

print("✓ Login successful\n")

# Test 1: Get all users
print("Test 1: GET /users (all users)")
response = requests.get(f'{BASE_URL}/users', headers=headers)
print(f"Status: {response.status_code}")
if response.status_code == 200:
    data = response.json()
    print(f"Total users: {len(data['results'])}")
    for user in data['results']:
        print(f"  - {user['prenom']} {user['nom']} ({user['role']})")
else:
    print(f"Error: {response.json()}")
print()

# Test 2: Get only recruiters
print("Test 2: GET /users?role=recruteur")
response = requests.get(f'{BASE_URL}/users?role=recruteur', headers=headers)
print(f"Status: {response.status_code}")
if response.status_code == 200:
    data = response.json()
    print(f"Total recruiters: {len(data['results'])}")
    for user in data['results']:
        print(f"  - {user['prenom']} {user['nom']} ({user['role']})")
else:
    print(f"Error: {response.json()}")
print()

# Test 3: Get only candidates
print("Test 3: GET /users?role=candidat")
response = requests.get(f'{BASE_URL}/users?role=candidat', headers=headers)
print(f"Status: {response.status_code}")
if response.status_code == 200:
    data = response.json()
    print(f"Total candidates: {len(data['results'])}")
    for user in data['results']:
        print(f"  - {user['prenom']} {user['nom']} ({user['role']})")
else:
    print(f"Error: {response.json()}")
