# Fix date_debut nullable - POST /api/v1/jobs

## 🎯 Problème

POST /api/v1/jobs échouait avec l'erreur :
```
NotNullViolation: colonne « date_debut » dans la relation « offre »
```

La spec API ne demande pas `date_debut` à la création d'une annonce, mais le modèle Django l'exigeait comme champ obligatoire.

## ✅ Solution appliquée

### 1. Modification du modèle Offre

**Fichier :** `backend/apps/jobs/models/offre.py`

**Avant :**
```python
date_debut = models.DateField()
```

**Après :**
```python
date_debut = models.DateField(null=True, blank=True)
```

### 2. Création et application de la migration

**Migration créée :** `0006_alter_offre_date_debut.py`

```python
class Migration(migrations.Migration):
    dependencies = [
        ('jobs', '0005_interview_candidature_mission_summary_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='offre',
            name='date_debut',
            field=models.DateField(blank=True, null=True),
        ),
    ]
```

**Commandes exécutées :**
```bash
python manage.py makemigrations jobs
python manage.py migrate jobs
```

**Résultat :**
```
Applying jobs.0006_alter_offre_date_debut... OK
```

## 📝 Fichiers modifiés

1. **`backend/apps/jobs/models/offre.py`**
   - Champ `date_debut` rendu nullable avec `null=True, blank=True`

2. **`backend/apps/jobs/migrations/0006_alter_offre_date_debut.py`**
   - Migration créée et appliquée avec succès

## ✅ Vérifications effectuées

- ✅ Aucune erreur de syntaxe Python
- ✅ Migration créée avec succès
- ✅ Migration appliquée avec succès
- ✅ La colonne `date_debut` est maintenant nullable dans la base de données

## 🎯 Résultat

POST /api/v1/jobs peut maintenant créer des annonces sans fournir `date_debut`. Le champ est optionnel comme spécifié dans l'API spec.

## 📚 Contexte

La spec API définit `date_debut` comme un champ optionnel dans `CreateOffreSerializer` :
```python
date_debut = serializers.DateField(required=False, allow_null=True)
```

Le modèle Django doit correspondre à cette spécification pour éviter les erreurs de contrainte NOT NULL.
