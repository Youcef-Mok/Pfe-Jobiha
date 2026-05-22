# Location Field Pre-fill Fix - Complete

## Problem
The location field in `edit_profile_screen.dart` was not being pre-filled with data from the recruiter profile screen (`recruiter_profile_screen.dart`). The `_location` field captured during auth was not being saved to the backend or retrieved when editing the profile.

## Root Cause Analysis

### What We Found:
1. ✅ **Django Model** (`utilisateur.py`): Has `location` field
2. ✅ **Django View** (`views.py`): Accepts `location` in PATCH /users/me
3. ❌ **Frontend Profile Repository**: Did NOT send `location` in `updateRecruteurProfile()`
4. ❌ **Frontend Auth Screen**: Did NOT pass `_location` to `saveRecruteurProfile()`
5. ❌ **Frontend Profile Notifier**: Did NOT accept `localisation` parameter
6. ❌ **Frontend Edit Profile**: Did NOT pre-fill from real user data
7. ✅ **UserEntity**: Already has `location` field

## Changes Made

### 1. Profile Notifier (`auth_providers.dart`)
**File**: `frontend/lib/features/auth/providers/auth_providers.dart`

Added `localisation` parameter to `saveRecruteurProfile()` method:

```dart
Future<bool> saveRecruteurProfile({
  required String nomStructure,
  required String typeStructure,
  String? description,
  String? localisation,  // ← ADDED
}) async {
  state = const AsyncLoading();
  try {
    await _repo.updateRecruteurProfile(
      nomStructure:  nomStructure,
      typeStructure: typeStructure,
      description:   description,
      localisation:  localisation,  // ← ADDED
    );
    state = const AsyncData(null);
    return true;
  } catch (e, st) {
    state = AsyncError(e, st);
    return false;
  }
}
```

### 2. Recruiter Profile Screen (`recruiter_profile_screen.dart`)
**File**: `frontend/lib/features/auth/screens/recruiter_profile_screen.dart`

Pass `_location` to the save call:

```dart
final success = await ref.read(profileProvider.notifier).saveRecruteurProfile(
  nomStructure:  _companyName!,
  typeStructure: _industry!,
  description:   _aboutUs,
  localisation:  _location,  // ← ADDED
);
```

### 3. Profile Repository (`profile_repository.dart`)
**File**: `frontend/lib/features/auth/data/profile_repository.dart`

Added `localisation` parameter and send it as `location` to backend:

```dart
Future<void> updateRecruteurProfile({
  required String nomStructure,
  required String typeStructure,
  String? description,
  String? localisation,  // ← ADDED
}) async {
  await _dio.patch(
    ApiEndpoints.me,
    data: {
      'nom_structure':  nomStructure,
      'type_structure': typeStructure,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (localisation != null && localisation.isNotEmpty)
        'location': localisation,  // ← ADDED (maps to backend 'location' field)
    },
  );
}
```

### 4. Edit Profile Screen (`edit_profile_screen.dart`)
**File**: `frontend/lib/features/profile/screens/edit_profile_screen.dart`

The location field was already being pre-filled correctly in `initState()`:

```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    final userAsync = ref.read(candidateCurrentUserProvider);
    userAsync.whenData((user) {
      if (mounted) {
        setState(() {
          _nameController.text = user.name;
          _usernameController.text = user.name.toLowerCase().replaceAll(' ', '_');
          _bioController.text = user.bio;
          _locationController.text = user.location;  // ← Already correct
          _selectedDomain = user.domain;
          _selectedDomainIcon = _getDomainIcon(user.domain);
        });
      }
    });
  });
}
```

## Data Flow (After Fix)

### Registration Flow:
1. User enters location in `recruiter_profile_screen.dart` → stored in `_location`
2. User clicks "Enregistrer mon profil"
3. `saveRecruteurProfile()` called with `localisation: _location`
4. `updateRecruteurProfile()` sends `location: localisation` to backend
5. Backend saves to `Utilisateur.location` field via PATCH /users/me

### Edit Profile Flow:
1. User opens `edit_profile_screen.dart`
2. `initState()` loads user data from `candidateCurrentUserProvider`
3. `_locationController.text = user.location` pre-fills the field
4. User can view/edit the location
5. On save, location is sent to backend via PATCH /users/me

## Field Name Mapping

| Frontend (Auth) | Frontend (Notifier) | Frontend (Repository) | Backend (API) | Backend (Model) |
|----------------|---------------------|----------------------|---------------|-----------------|
| `_location` | `localisation` | `localisation` → `location` | `location` | `location` |

## Testing Checklist

- [x] No compilation errors in modified files
- [ ] Test recruiter registration flow:
  1. Register as recruiter
  2. Enter location in profile screen
  3. Save profile
  4. Verify location saved to backend
- [ ] Test edit profile flow:
  1. Login as recruiter
  2. Open edit profile
  3. Verify location field is pre-filled
  4. Edit location
  5. Save and verify update

## Backend Verification

The Django backend already supports this:
- ✅ `Utilisateur` model has `location` field (CharField, max_length=200)
- ✅ `UserMeView.put()` accepts and saves `location` field
- ✅ `UserMeSerializer.get_location()` returns the location in GET /users/me

## Notes

- No UI changes were made
- No field names on forms were changed
- Only data wiring was fixed
- The fix applies to recruiters; candidates may need similar treatment if they also have location fields
- The backend field name is `location` (not `localisation`)
