# ⚡ Quick Image Fix - For Tomorrow's Demo

## 🎯 Fastest Solution (5 minutes)

Since your presentation is tomorrow, here's the **quickest fix** to get images working:

### Step 1: Add the Utility Files (Already Done ✅)

I've created:
- `frontend/lib/core/utils/media_utils.dart`
- `frontend/lib/core/widgets/smart_image.dart`

### Step 2: Update Backend URL for Android Emulator

If testing on Android emulator, update `media_utils.dart`:

```dart
// Change this line:
static const String _baseUrl = 'http://localhost:8000';

// To this (for Android emulator):
static const String _baseUrl = 'http://10.0.2.2:8000';
```

### Step 3: Fix the Most Critical File

The error you showed is from **"Posts sugérés"** (Suggested Posts/Jobs).

Find where job cards display images and replace:

**Before:**
```dart
Image.asset(job.imageUrl)
```

**After:**
```dart
import 'package:job_app/core/widgets/smart_image.dart';

SmartImage(
  imageUrl: job.imageUrl,
  width: double.infinity,
  height: 200,
  fit: BoxFit.cover,
)
```

---

## 🔍 Find & Replace Guide

### For Notification Images

**File:** `lib/features/notifications/widgets/notification_card.dart`

**Find:**
```dart
_ImgWithBadge(asset: n.contextImageUrl!,
```

**Replace with:**
```dart
import 'package:job_app/core/widgets/smart_image.dart';

SmartImage(
  imageUrl: n.contextImageUrl,
  width: 48,
  height: 48,
  fit: BoxFit.cover,
)
```

### For Mission Images

**Files:** 
- `lib/features/jobs/widgets/mission_card.dart`
- `lib/features/jobs/widgets/completed_mission_card.dart`
- `lib/features/jobs/screens/mission_details_screen.dart`

**Find:**
```dart
Image.asset(
  mission.imageUrl!,
```

**Replace with:**
```dart
import 'package:job_app/core/widgets/smart_image.dart';

SmartImage(
  imageUrl: mission.imageUrl,
```

---

## 🚀 Alternative: Quick Patch Function

If you don't have time to update all files, add this helper to your existing widgets:

```dart
// Add this at the top of any widget file
Widget _buildImage(String? imageUrl, {double? width, double? height}) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.image, color: Colors.grey[600]),
    );
  }
  
  // Check if it's a media URL from backend
  if (imageUrl.startsWith('/media/') || imageUrl.startsWith('media/')) {
    final fullUrl = imageUrl.startsWith('/') 
        ? 'http://localhost:8000$imageUrl'  // Change to 10.0.2.2 for Android emulator
        : 'http://localhost:8000/$imageUrl';
    
    return Image.network(
      fullUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[600]),
        );
      },
    );
  }
  
  // Otherwise use asset
  return Image.asset(
    imageUrl,
    width: width,
    height: height,
    fit: BoxFit.cover,
  );
}
```

Then use it like:
```dart
_buildImage(job.imageUrl, width: 200, height: 150)
```

---

## 🎯 Priority Files to Fix (In Order)

1. **Job/Post cards** - Where you saw the error
2. **Notification cards** - Shows logos and avatars
3. **Mission cards** - Shows mission images
4. **Profile screens** - Shows user avatars
5. **Company profiles** - Shows company logos

---

## ✅ Quick Test

After making changes:

1. **Restart Flutter app** (hot reload might not work)
```bash
flutter run
```

2. **Check Django is serving media**
Visit: `http://localhost:8000/media/logos/demo_company.png`

3. **Check Flutter console** for network requests:
```
[ApiClient] GET http://localhost:8000/media/...
```

---

## 🐛 If Still Not Working

### For Android Emulator:
```dart
// In media_utils.dart, change:
static const String _baseUrl = 'http://10.0.2.2:8000';
```

### For iOS Simulator:
```dart
// In media_utils.dart, use:
static const String _baseUrl = 'http://localhost:8000';
```

### For Physical Device:
```dart
// In media_utils.dart, use your computer's IP:
static const String _baseUrl = 'http://192.168.1.X:8000';  // Replace X with your IP
```

To find your IP:
```bash
# Windows
ipconfig

# Mac/Linux
ifconfig
```

---

## 💡 Last Resort: Use Placeholder Assets

If you can't fix it in time, temporarily use local placeholder images:

1. Add placeholder images to `assets/images/`
2. In your models, return asset paths instead of media URLs
3. Demo will work with placeholders

---

## 🎉 Expected Result

After fix:
- ✅ Job images load from Django backend
- ✅ Company logos display correctly
- ✅ User avatars show up
- ✅ Mission images visible
- ✅ No more "Asset not found" errors

---

## ⏰ Time Estimate

- **Minimal fix** (just job cards): 5 minutes
- **Fix all critical screens**: 15 minutes
- **Complete fix** (all images): 30 minutes

**For tomorrow's demo, focus on the minimal fix first!**
