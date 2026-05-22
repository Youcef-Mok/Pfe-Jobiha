# Edit Profile Screen - Testing Guide

## Prerequisites
1. Backend server running on `http://192.168.100.9:8000`
2. Flutter app connected to physical device or emulator
3. User logged in as a candidat

## Test Scenarios

### Test 1: Domain Field Loads Correctly
**Steps:**
1. Open the app and navigate to Edit Profile screen
2. Observe the Domain field

**Expected Result:**
- If user has a domain set in database, it should display that domain
- If user has no domain set, field should be empty (not "Restauration")
- Domain icon should match the selected domain

**Pass Criteria:** ✅ Domain shows user's actual domain or empty

---

### Test 2: Domain Change Persists
**Steps:**
1. Open Edit Profile screen
2. Tap on Domain field
3. Select a different domain (e.g., "Hôtellerie")
4. Tap "Terminé" to save
5. Close the app completely
6. Reopen app and navigate to Edit Profile

**Expected Result:**
- Selected domain should still be "Hôtellerie"
- Domain should also appear on the main profile view screen

**Pass Criteria:** ✅ Domain persists across app restarts

---

### Test 3: Location Placeholder Shows Algerian City
**Steps:**
1. Create a new user account (or clear location for existing user)
2. Open Edit Profile screen
3. Observe the Location field when empty

**Expected Result:**
- Placeholder text should show "Alger, Algérie" (not "Paris, France")

**Pass Criteria:** ✅ Placeholder is "Alger, Algérie"

---

### Test 4: Location Change Saves
**Steps:**
1. Open Edit Profile screen
2. Tap on Location field
3. Select a city (e.g., "Oran")
4. Tap "Terminé" to save
5. Navigate away and return to Edit Profile

**Expected Result:**
- Location field should show "Oran"
- Backend should have saved the location

**Verification:**
```bash
# Check database
curl -H "Authorization: Bearer <token>" http://192.168.100.9:8000/api/v1/users/me
# Should return: "location": "Oran"
```

**Pass Criteria:** ✅ Location persists after save

---

### Test 5: Profile Picture Upload
**Steps:**
1. Open Edit Profile screen
2. Tap "Modifier la photo de profil"
3. Select an image from gallery
4. Wait for upload to complete

**Expected Result:**
- Loading indicator appears during upload
- Success message: "Photo de profil mise à jour"
- Image appears immediately in the profile circle
- Image is a network image (not local file)

**Verification:**
```bash
# Check backend response
curl -H "Authorization: Bearer <token>" http://192.168.100.9:8000/api/v1/users/me
# Should return: "avatar_url": "/media/avatars/1_abc123.jpg"

# Check file exists
ls backend/media/avatars/
# Should show uploaded file
```

**Pass Criteria:** ✅ Image uploads and displays from server

---

### Test 6: Profile Picture Displays on Other Screens
**Steps:**
1. Upload a profile picture (Test 5)
2. Navigate to main Profile screen
3. Navigate to Messages screen
4. Check if avatar appears in conversation list

**Expected Result:**
- Avatar should display on all screens that show user profile
- Should be the same image uploaded in Edit Profile

**Pass Criteria:** ✅ Avatar consistent across all screens

---

### Test 7: All Fields Save Together
**Steps:**
1. Open Edit Profile screen
2. Change Name to "Ahmed Benali"
3. Change Bio to "Serveur expérimenté"
4. Change Domain to "Restauration"
5. Change Location to "Constantine"
6. Tap "Terminé"
7. Reopen Edit Profile

**Expected Result:**
- All fields should show the updated values
- No field should revert to old value

**Verification:**
```bash
curl -H "Authorization: Bearer <token>" http://192.168.100.9:8000/api/v1/users/me
```

Expected response:
```json
{
  "name": "Ahmed Benali",
  "bio": "Serveur expérimenté",
  "domain": "Restauration",
  "location": "Constantine",
  ...
}
```

**Pass Criteria:** ✅ All fields persist correctly

---

### Test 8: Error Handling - Network Failure
**Steps:**
1. Turn off WiFi/mobile data
2. Open Edit Profile screen
3. Change any field
4. Tap "Terminé"

**Expected Result:**
- Error message appears: "Erreur lors de la mise à jour: ..."
- Fields remain editable
- User can retry after reconnecting

**Pass Criteria:** ✅ Graceful error handling

---

### Test 9: Error Handling - Invalid Image
**Steps:**
1. Open Edit Profile screen
2. Tap "Modifier la photo de profil"
3. Try to select a very large file (>10MB) or invalid format

**Expected Result:**
- Either prevented from selecting, or
- Error message appears after upload attempt
- Previous avatar remains unchanged

**Pass Criteria:** ✅ Invalid uploads handled gracefully

---

### Test 10: Backend API Direct Test
**Steps:**
```bash
# 1. Login
curl -X POST http://192.168.100.9:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Save the token from response

# 2. Get current user
curl -H "Authorization: Bearer <token>" \
  http://192.168.100.9:8000/api/v1/users/me

# 3. Update profile
curl -X PATCH http://192.168.100.9:8000/api/v1/users/me \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "prenom": "Ahmed",
    "nom": "Benali",
    "domain": "Restauration",
    "location": "Alger",
    "experience": "5 ans d'\''expérience"
  }'

# 4. Upload avatar
curl -X POST http://192.168.100.9:8000/api/v1/users/me/avatar \
  -H "Authorization: Bearer <token>" \
  -F "avatar=@/path/to/image.jpg"

# 5. Verify changes
curl -H "Authorization: Bearer <token>" \
  http://192.168.100.9:8000/api/v1/users/me
```

**Expected Result:**
- All API calls return 200 OK
- Final GET shows all updated fields
- avatar_url points to uploaded file

**Pass Criteria:** ✅ All API endpoints work correctly

---

## Common Issues & Solutions

### Issue: Domain still shows "Restauration"
**Solution:** 
- Check if backend migration ran: `python manage.py migrate`
- Verify `domain` field exists in Candidat table
- Check serializer returns `p.domain` not `p.experience`

### Issue: Avatar upload fails
**Solution:**
- Check `backend/media/avatars/` directory exists and is writable
- Verify `MEDIA_ROOT` and `MEDIA_URL` in settings.py
- Check file size limits in Django settings

### Issue: Location doesn't save
**Solution:**
- Verify `location` field added to `base_fields` in UserMeView
- Check serializer returns `obj.location` not just lat/long
- Ensure frontend sends `location` in update payload

### Issue: Changes don't appear on other screens
**Solution:**
- Verify `refresh()` is called after save
- Check if other screens use same provider
- Clear app cache and restart

---

## Success Criteria Summary

All tests must pass:
- ✅ Domain loads from database
- ✅ Domain changes persist
- ✅ Location placeholder is Algerian
- ✅ Location changes save
- ✅ Avatar uploads successfully
- ✅ Avatar displays from network
- ✅ All fields save together
- ✅ Errors handled gracefully
- ✅ API endpoints work directly

## Rollback Plan

If issues occur, revert these commits:
1. Backend: `apps/users/views.py`, `apps/users/serializers.py`, `apps/users/urls.py`
2. Frontend: `edit_profile_screen.dart`, `api_endpoints.dart`

Or restore from `EDIT_PROFILE_FIXES.md` documentation.
