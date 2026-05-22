# 🔍 Debug Saved Jobs Issue

## Problem
When clicking "Jobs enregistrés" badge, it shows all posts sugérés instead of only saved jobs.

## Expected Behavior
1. Click "Jobs enregistrés" chip in home screen
2. Navigate to SavedJobsScreen (new screen with back button)
3. Show only 3 saved jobs:
   - Senior Full Stack Developer React/Node
   - Mobile Developer Flutter Senior
   - UI/UX Designer Senior

## Seed Data Verification
The demo_seed_data.sql includes saved jobs:
```sql
INSERT INTO saved_job (id, candidat_id, offre_id, saved_at) VALUES
(100, 100, 200, NOW() - INTERVAL '16 days'),  -- Senior Full Stack
(101, 100, 201, NOW() - INTERVAL '6 days'),   -- Mobile Flutter
(102, 100, 203, NOW() - INTERVAL '4 days');   -- UI/UX Designer
```

## Debug Steps

### Step 1: Verify Seed Data Loaded
```sql
-- In Neon SQL Editor, run:
SELECT * FROM saved_job WHERE candidat_id = 100;

-- Should return 3 rows with offre_ids: 200, 201, 203
```

### Step 2: Test Backend API
```bash
# Get auth token first (login as amina.demo@gmail.com)
# Then test the saved jobs endpoint:

curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/candidats/me/saved

# Should return:
# {
#   "results": [
#     { "id": 102, "offre": {...job 203...}, "saved_at": "..." },
#     { "id": 101, "offre": {...job 201...}, "saved_at": "..." },
#     { "id": 100, "offre": {...job 200...}, "saved_at": "..." }
#   ]
# }
```

### Step 3: Check Flutter Navigation
When you click "Jobs enregistrés":
- [ ] Does it navigate to a NEW screen?
- [ ] Does the new screen have a back arrow?
- [ ] Does the title say "Saved jobs"?
- [ ] Or does it stay on the same screen?

### Step 4: Check What's Displayed
On the SavedJobsScreen:
- [ ] How many jobs are shown?
- [ ] Are they the 3 saved jobs or all 5 demo jobs?
- [ ] Do you see "3 Jobs enregistrés" at the top?
- [ ] Or do you see "Erreur de chargement"?

## Possible Issues

### Issue 1: Not Navigating to SavedJobsScreen
**Symptom**: Clicking badge doesn't navigate, stays on home screen

**Solution**: Check if there's a different "Jobs enregistrés" filter that's supposed to filter the current list instead of navigating.

### Issue 2: SavedJobsScreen Shows All Jobs
**Symptom**: Navigates to new screen but shows all 5 jobs instead of 3

**Cause**: Provider might be using wrong data source

**Solution**: Check if `savedJobsDisplayProvider` is actually being used

### Issue 3: Seed Data Not Loaded
**Symptom**: Shows "Aucun job enregistré" or error

**Solution**: 
```sql
-- Reload demo seed data:
\i demo_seed_data.sql
```

### Issue 4: Backend Returns Wrong Data
**Symptom**: API returns all jobs instead of saved ones

**Solution**: Check backend logs for errors

### Issue 5: Flutter Caching Issue
**Symptom**: Old data is cached

**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

## Quick Test

### Test 1: Save a Job Manually
1. Login as amina.demo@gmail.com
2. Go to "Posts sugérés"
3. Tap bookmark icon on "DevOps Engineer" (job 202)
4. Icon should fill (become solid)
5. Click "Jobs enregistrés" chip
6. Should now see 4 jobs (including DevOps)

### Test 2: Check Backend Directly
```bash
# In Django shell:
python manage.py shell

from apps.users.models import Candidat
from apps.jobs.models import SavedJob

candidat = Candidat.objects.get(id=100)
saved = SavedJob.objects.filter(candidat=candidat)
print(f"Saved jobs count: {saved.count()}")
for s in saved:
    print(f"  - {s.offre.titre}")

# Should print:
# Saved jobs count: 3
#   - Senior Full Stack Developer React/Node
#   - Mobile Developer Flutter Senior
#   - UI/UX Designer Senior
```

## Files to Check

### Backend:
- `backend/apps/jobs/views.py` - SavedJobsView.get()
- `backend/apps/jobs/serializers.py` - SavedJobSerializer
- `backend/apps/jobs/urls.py` - /candidats/me/saved route

### Frontend:
- `frontend/lib/features/jobs/screens/saved_jobs_screen.dart` - The screen
- `frontend/lib/features/applications/data/providers/applications_provider.dart` - savedJobsDisplayProvider
- `frontend/lib/features/jobs/data/repositories/jobs_repository_http.dart` - getSavedJobs()
- `frontend/lib/core/api/api_endpoints.dart` - savedJobs endpoint

## Expected Flow

```
User clicks "Jobs enregistrés" chip
  ↓
Navigator.push(SavedJobsScreen())
  ↓
SavedJobsScreen watches savedJobsDisplayProvider
  ↓
savedJobsDisplayProvider watches savedJobsRemoteProvider
  ↓
savedJobsRemoteProvider calls jobsRepository.getSavedJobs()
  ↓
getSavedJobs() calls GET /candidats/me/saved
  ↓
Backend filters SavedJob.objects.filter(candidat=request.user.candidat)
  ↓
Returns 3 saved jobs with nested offre data
  ↓
Flutter extracts offre field from each saved job
  ↓
Displays 3 job cards
```

## What to Tell Me

Please check and tell me:

1. **Navigation**: When you click "Jobs enregistrés", does it:
   - [ ] Navigate to a new screen with back button?
   - [ ] Stay on the same screen?

2. **Screen Title**: What title do you see at the top?
   - [ ] "Saved jobs"
   - [ ] "Posts sugérés"
   - [ ] Something else?

3. **Job Count**: How many jobs are displayed?
   - [ ] 0 jobs (empty)
   - [ ] 3 jobs (correct - the saved ones)
   - [ ] 5 jobs (wrong - all demo jobs)
   - [ ] Error message

4. **Job Titles**: Which job titles do you see?
   - [ ] Senior Full Stack Developer
   - [ ] Mobile Developer Flutter
   - [ ] DevOps Engineer
   - [ ] UI/UX Designer
   - [ ] Chef de Projet Digital

5. **Backend Logs**: Any errors in Django console?

6. **Flutter Logs**: Any errors in Flutter console?

---

Once you provide this information, I can pinpoint the exact issue and fix it!
