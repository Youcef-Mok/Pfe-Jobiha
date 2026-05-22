# 🧪 Test Location Fixes - Quick Guide

## ⚠️ IMPORTANT: Full Restart Required
**You MUST fully restart the Flutter app** (not just hot reload) for these changes to take effect!

## What Was Fixed
All French locations (Lyon, Paris) have been replaced with Algerian locations (Alger, Oran, Constantine, Bejaia).

## Quick Test Steps

### 1. Restart Flutter App
```bash
# Stop the app completely
# Then restart it
flutter run
```

### 2. Test "Posts sugérés" (Suggested Jobs)
**What to check:**
- ✅ Job cards should show Algerian cities from your seed data
- ✅ Location icon should display cities like:
  - "Alger, Birkhadem"
  - "Oran, Es Senia"
  - "Constantine, Centre-ville"
  - "Bejaia, Ville"

**Expected behavior:**
- If the job has a location in the database → shows that location
- If the job has no location → shows "Alger, Algérie" as fallback

### 3. Test Job Details Screen
**What to check:**
- ✅ Subtitle should show: `[Company Name] • [Algerian City]`
- ✅ Map should display Algiers coordinates (36.7538, 3.0588)
- ✅ Map label should say "Alger, Algérie" instead of "Lyon"

### 4. Test Candidate Profile
**What to check:**
- ✅ Location chip should show "Alger, Algérie" instead of "Paris, France"

### 5. Test Map Screen
**What to check:**
- ✅ Job cards on map should show "Alger, Algérie" instead of "Lyon, FR"

## Seed Data Locations
Your demo accounts have these locations:

### Demo Seed Data (`demo_seed_data.sql`)
- **Offre ID 100**: "Alger, Birkhadem"
- **Offre ID 101**: "Oran, Es Senia"
- **Offre ID 102**: "Constantine, Centre-ville"
- **Offre ID 103**: "Bejaia, Ville"
- **Offre ID 104**: "Alger, Hydra"

### Regular Seed Data (`seed_data.sql`)
- Multiple jobs across Alger, Oran, Constantine, Bejaia

## Demo Accounts for Testing
Use these accounts to test:

### Candidat Account
- **Email**: amina.demo@gmail.com
- **Password**: password123
- **Has**: 5 candidatures, 3 interviews, 2 missions

### Recruteur Account
- **Email**: tech.demo@company.dz
- **Password**: password123
- **Has**: 5 published job offers

## Troubleshooting

### Problem: Still seeing French locations
**Solution**: 
1. Stop the Flutter app completely
2. Run `flutter clean`
3. Run `flutter pub get`
4. Restart the app with `flutter run`

### Problem: Locations show as null or empty
**Solution**:
1. Check that you've loaded the seed data into your database
2. Verify the backend is running: `http://10.0.2.2:8000/api/jobs/`
3. Check the API response includes the `location` field

### Problem: Map still shows Lyon coordinates
**Solution**:
1. Full restart required (not hot reload)
2. The default coordinates are now Algiers (36.7538, 3.0588)

## API Response Example
The backend should return jobs with location field:
```json
{
  "id": "100",
  "title": "Développeur Full Stack Senior",
  "company_name": "Tech Innovate Algeria",
  "location": "Alger, Birkhadem",
  "contract_type": "cdi",
  ...
}
```

## Files That Were Modified
1. `frontend/lib/features/jobs/domain/job_entity.dart` - Added location field
2. `frontend/lib/features/jobs/data/models/job_model.dart` - Added location parsing
3. `frontend/lib/features/jobs/widgets/candidate_job_card.dart` - Uses dynamic location
4. `frontend/lib/features/candidates/screens/candidate_profile_screen.dart` - Changed to Alger
5. `frontend/lib/features/jobs/screens/candidate_job_details_screen.dart` - Changed to Alger + coordinates
6. `frontend/lib/features/profile/data/repositories/user_repository_mock.dart` - Changed to Alger
7. `frontend/lib/features/map/screens/map_screen.dart` - Changed to Alger

---
**Ready for presentation**: ✅ YES
**Restart required**: ⚠️ YES (full restart, not hot reload)
