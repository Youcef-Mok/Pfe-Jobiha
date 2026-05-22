# Edit Profile Screen Fixes - Complete Summary

## Issues Fixed

### 1. ✅ Domain Field Always Shows "Restauration"
**Problem:** Domain was hardcoded to 'Restauration' as default value.

**Root Cause:** 
- Line 27: `String _selectedDomain = 'Restauration';`
- Backend was returning `experience` field instead of actual `domain` field

**Fixes Applied:**
- **Frontend:** Changed default to empty string: `String _selectedDomain = '';`
- **Backend Serializer:** Updated `UserMeSerializer.get_domain()` to return `p.domain` instead of `p.experience` for candidats
- **Backend View:** Added `domain` field to accepted fields in `UserMeView.put()` method
- **Frontend Save:** Added `domain` to update payload: `if (_selectedDomain.isNotEmpty) updateData['domain'] = _selectedDomain;`

### 2. ✅ Location Placeholder Shows "Paris, France"
**Problem:** Placeholder text was hardcoded to French city.

**Fix Applied:**
- Changed placeholder from `'Paris, France'` to `'Alger, Algérie'` (line 673)

### 3. ✅ Location Changes Don't Save
**Problem:** Location field was not being sent to backend on save.

**Root Cause:**
- Backend has both `location` (text) and `latitude`/`longitude` (coordinates) fields
- Frontend was not sending location data

**Fixes Applied:**
- **Backend View:** Added `'location'` and `'bio'` to accepted base fields in `UserMeView.put()`
- **Backend Serializer:** Updated `get_location()` to prioritize `obj.location` text field over lat/long
- **Frontend Save:** Added location to update payload: `if (_locationController.text.isNotEmpty) updateData['location'] = _locationController.text;`

### 4. ✅ Profile Picture Shows Mock Asset
**Problem:** Avatar always showed local asset image, no network image support.

**Root Cause:**
- Backend serializer returned `None` for `avatar_url`
- No upload endpoint existed
- Frontend didn't support network images

**Fixes Applied:**

**Backend:**
- Updated `UserMeSerializer.get_avatar_url()` to return actual `obj.avatar_url` value
- Created new `UserAvatarUploadView` endpoint at `POST /users/me/avatar`
- Added multipart file upload support with unique filename generation
- Files saved to `media/avatars/` directory
- Added URL route: `path('users/me/avatar', views.UserAvatarUploadView.as_view())`

**Frontend:**
- Updated `_buildProfileImage()` to support three image types:
  1. Local file paths (newly picked images)
  2. Network URLs (http/https)
  3. Asset images (fallback)
- Added network image loading with error handling and loading indicator
- Updated `_pickImage()` to upload file to backend via multipart form data
- Added `ApiEndpoints.meAvatar` constant
- Imported `dio` package for `FormData` and `MultipartFile`

### 5. ✅ Field Initialization from Real User Data
**Problem:** Fields were being initialized but domain wasn't loading correctly.

**Fix Applied:**
- Domain now loads from actual `user.domain` field (which now returns correct data from backend)
- All other fields already loading correctly: name, bio, location

### 6. ✅ Auth State Refresh After Save
**Problem:** After saving profile, other screens wouldn't see updated data immediately.

**Fix Applied:**
- Added refresh call after successful save: `await ref.read(candidateCurrentUserProvider.notifier).refresh();`
- This reloads user data from server to ensure consistency

## Files Modified

### Backend Files:
1. **`backend/apps/users/serializers.py`**
   - Fixed `get_domain()` to return actual domain field
   - Fixed `get_avatar_url()` to return actual avatar URL
   - Fixed `get_location()` to prioritize location text field

2. **`backend/apps/users/views.py`**
   - Added `domain` to candidat update fields
   - Added `avatar_url`, `location`, `bio` to base user update fields
   - Created new `UserAvatarUploadView` class for avatar uploads

3. **`backend/apps/users/urls.py`**
   - Added route: `path('users/me/avatar', views.UserAvatarUploadView.as_view())`

### Frontend Files:
1. **`frontend/lib/features/profile/screens/edit_profile_screen.dart`**
   - Changed domain default from 'Restauration' to empty string
   - Changed location placeholder from 'Paris, France' to 'Alger, Algérie'
   - Added domain and location to save payload
   - Added refresh call after save
   - Updated `_buildProfileImage()` to support network images
   - Updated `_pickImage()` to upload to backend
   - Added Dio import for multipart upload

2. **`frontend/lib/core/api/api_endpoints.dart`**
   - Added `meAvatar` constant: `'$_base/users/me/avatar'`

## API Changes

### New Endpoint:
```
POST /api/v1/users/me/avatar
Content-Type: multipart/form-data

Body:
- avatar: <file>

Response: UserMeSerializer (includes new avatar_url)
```

### Updated Endpoint:
```
PATCH /api/v1/users/me

Now accepts additional fields:
- domain: string (for candidats)
- location: string (city name)
- avatar_url: string (URL)
- bio: string
```

### Updated Response:
```json
GET /api/v1/users/me

{
  "id": "1",
  "name": "John Doe",
  "role": "candidat",
  "domain": "Restauration",  // Now returns actual domain, not experience
  "location": "Alger",        // Now returns location text, not just lat/long
  "avatar_url": "/media/avatars/1_abc123.jpg",  // Now returns actual URL
  "bio": "...",
  ...
}
```

## Testing Checklist

- [ ] Domain dropdown loads user's actual domain on screen open
- [ ] Changing domain and saving updates the backend
- [ ] Location field shows user's current location
- [ ] Changing location and saving persists the change
- [ ] Picking a new profile picture uploads to backend
- [ ] Profile picture displays from network URL after upload
- [ ] All changes persist after closing and reopening the screen
- [ ] Other screens (profile view) show updated data immediately

## Notes

- Avatar files are stored in `backend/media/avatars/` with format: `{user_id}_{uuid}.{ext}`
- Location is stored as text (city name), not coordinates
- Domain field is specific to Candidat model
- All changes follow zero-UI-modification rule - only data loading/saving was fixed
