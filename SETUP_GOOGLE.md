# Fix Google Sign-In — À faire avant la présentation

## Étape unique (2 minutes)

1. Va sur https://console.cloud.google.com
2. **APIs & Services** → **Identifiants**
3. Clique sur ton **OAuth 2.0 Client ID**
4. Dans **"Origines JavaScript autorisées"** → clique **Ajouter une origine**
5. Ajoute : `http://localhost:58750`
6. Clique **Enregistrer**

> ⚠️ Si au lancement le port est différent (ex: 58751), note-le et répète l'étape avec le bon port.
