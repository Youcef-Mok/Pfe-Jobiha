# Profile Picture Fix - Summary

## Issues Fixed

### Issue 1: Mock Image Displayed Instead of Real Avatar
**Problem:** Avatar always showed hardcoded asset image `'assets/images/imageannonc(3).jpg'`

**Root Cause:**
- `_buildProfileImage()` had fallback logic that tried to use avatarUrl as an asset path
- When avatarUrl was null/empty, it used the hardcoded mock image

**Fix Applied:**
- Removed all asset image logic
- Simplified to only two cases:
  1. If avatarUrl is a valid http/https URL → show network image
  2. Otherwise → show default person icon
- Removed local file support (not needed since we upload immediately)

**Code Changed:**
```dart
// Before: Complex logic with local files and asset fallback
Widget _buildProfileImage(String? avatarUrl) {
  if (local file) return Image.file(...);
  if (network) return Image.network(...);
  return Image.asset('assets/images/imageannonc(3).jpg'); // MOCK
}

// After: Simple network-only logic
Widget _buildProfileImage(String? avatarUrl) {
  if (avatarUrl != null && avatarUrl.isNotEmpty && avatarUrl.startsWith('http')) {
    return Image.network(avatarUrl, ...);
  }
  return const Icon(Icons.person, size: 48, color: Colors.grey);
}
```

### Issue 2: Avatar URL Not Absolute
**Problem:** Backend returned relative URL `/media/avatars/1_abc.jpg` which Flutter couldn't load

**Root Cause:**
- `UserAvatarUploadView` saved relative path to database
- Flutter needs absolute URL like `http://192.168.100.9:8000/media/avatars/1_abc.jpg`

**Fix Applied:**
- Updated backend to use `request.build_absolute_uri()` to generate full URL
- This automatically includes the protocol, host, and port

**Code Changed:**
```python
# Before:
avatar_url = f"{settings.MEDIA_URL}avatars/{filename}"  # /media/avatars/1_abc.jpg

# After:
avatar_url = request.build_absolute_uri(f"{settings.MEDIA_URL}avatars/{filename}")
# http://192.168.100.9:8000/media/avatars/1_abc.jpg
```

### Issue 3: Avatar Not Refreshing Immediately After Upload
**Problem:** After upload, user had to close and reopen screen to see new avatar

**Root Cause:**
- Upload updated local state but didn't refresh from server
- Potential race condition between local update and server state

**Fix Applied:**
- Added `refresh()` call after successful upload
- This ensures we get the latest data from server including the absolute URL
- Widget already uses `ref.watch()` so it rebuilds automatically

**Code Changed:**
```dart
// After upload success:
if (avatarUrl != null) {
  ref.read(candidateCurrentUserProvider.notifier).updateProfilePhoto(avatarUrl);
}

// Added this line:
await ref.read(candidateCurrentUserProvider.notifier).refresh();
```

## Files Modified

### Frontend:
**`frontend/lib/features/profile/screens/edit_profile_screen.dart`**
- Simplified `_buildProfileImage()` to remove mock asset
- Added `refresh()` call after avatar upload

### Backend:
**`backend/apps/users/views.py`**
- Updated `UserAvatarUploadView.post()` to use `request.build_absolute_uri()`

## Testing Checklist

### Test 1: Default Avatar Shows Icon
- [ ] Open Edit Profile with no avatar set
- [ ] Should show grey person icon (not mock image)

### Test 2: Upload New Avatar
- [ ] Tap "Modifier la photo de profil"
- [ ] Select an image from gallery
- [ ] Should see loading indicator
- [ ] Should see success message
- [ ] Avatar should appear immediately (no restart needed)

### Test 3: Avatar Persists
- [ ] Upload avatar (Test 2)
- [ ] Close Edit Profile screen
- [ ] Reopen Edit Profile
- [ ] Avatar should still be visible

### Test 4: Avatar Shows on Other Screens
- [ ] Upload avatar
- [ ] Navigate to main Profile screen
- [ ] Avatar should appear there too
- [ ] Check Messages screen
- [ ] Avatar should appear in conversation list

### Test 5: Network Error Handling
- [ ] Turn off WiFi
- [ ] Try to upload avatar
- [ ] Should show error message
- [ ] Previous avatar (or icon) should remain

### Test 6: Backend URL Format
```bash
# After upload, check database:
curl -H "Authorization: Bearer <token>" http://192.168.100.9:8000/api/v1/users/me

# Should return:
{
  "avatar_url": "http://192.168.100.9:8000/media/avatars/1_abc123.jpg"
  // NOT: "/media/avatars/1_abc123.jpg"
}
```

### Test 7: File Actually Saved
```bash
# Check file exists on server:
ls backend/media/avatars/
# Should show: 1_abc123.jpg (or similar)
```

## API Behavior

### Endpoint: POST /api/v1/users/me/avatar

**Request:**
```
Content-Type: multipart/form-data
Authorization: Bearer <token>

Body:
- avatar: <image file>
```

**Response:**
```json
{
  "id": "1",
  "name": "John Doe",
  "avatar_url": "http://192.168.100.9:8000/media/avatars/1_abc123.jpg",
  ...
}
```

**Success Flow:**
1. Flutter picks image from gallery
2. Uploads via multipart form data to `/users/me/avatar`
3. Backend saves file to `media/avatars/` with unique name
4. Backend updates `utilisateur.avatar_url` with absolute URL
5. Backend returns full user data via `UserMeSerializer`
6. Flutter updates local state with new avatar URL
7. Flutter refreshes from server to ensure consistency
8. Widget rebuilds automatically (using `ref.watch`)
9. New avatar appears immediately

## Differences from Previous Implementation

### Before:
- ❌ Showed hardcoded mock asset image
- ❌ Supported local file paths (unnecessary complexity)
- ❌ Backend returned relative URLs
- ❌ No refresh after upload

### After:
- ✅ Shows real avatar from network or default icon
- ✅ Simple network-only logic
- ✅ Backend returns absolute URLs
- ✅ Refreshes after upload for consistency

## Notes

- Avatar files stored in `backend/media/avatars/`
- Filename format: `{user_id}_{uuid}.{ext}`
- Default icon: Material Icons person icon (grey)
- No UI changes: avatar size, shape, border unchanged
- "Modifier la photo de profil" text unchanged
