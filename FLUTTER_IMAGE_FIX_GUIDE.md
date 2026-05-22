# 🖼️ Flutter Image Fix Guide

## Problem

Your Flutter app shows "Unable to load asset" errors because it's trying to load Django backend images as local assets.

## Solution

I've created two utility files to handle images from your Django backend:

1. **`lib/core/utils/media_utils.dart`** - Converts relative paths to full URLs
2. **`lib/core/widgets/smart_image.dart`** - Smart widgets that handle both network and asset images

---

## 🚀 Quick Fix

### Option 1: Use SmartImage Widget (Recommended)

Replace `Image.asset()` with `SmartImage()`:

**Before:**
```dart
Image.asset(
  mission.imageUrl!,
  width: 75,
  height: 75,
  fit: BoxFit.cover,
)
```

**After:**
```dart
import 'package:job_app/core/widgets/smart_image.dart';

SmartImage(
  imageUrl: mission.imageUrl,
  width: 75,
  height: 75,
  fit: BoxFit.cover,
  fallbackAsset: 'assets/images/default_mission.png', // optional
)
```

### Option 2: Use MediaUtils Directly

**Before:**
```dart
Image.asset(notification.avatarUrl!)
```

**After:**
```dart
import 'package:job_app/core/utils/media_utils.dart';

Image.network(
  MediaUtils.getMediaUrl(notification.avatarUrl)!,
  errorBuilder: (context, error, stackTrace) {
    return Image.asset('assets/images/default_avatar.png');
  },
)
```

---

## 📝 Specific Fixes Needed

### 1. **Notification Cards** (`notification_card.dart`)

**Find:**
```dart
_ImgWithBadge(asset: n.contextImageUrl!, ...)
_AvatarWithBadge(asset: n.avatarUrl, ...)
```

**Replace with:**
```dart
import 'package:job_app/core/widgets/smart_image.dart';

// For context images
SmartImage(
  imageUrl: n.contextImageUrl,
  width: 48,
  height: 48,
  fit: BoxFit.cover,
)

// For avatars
SmartAvatar(
  imageUrl: n.avatarUrl,
  radius: 20,
)
```

### 2. **Mission Cards** (`mission_card.dart`, `completed_mission_card.dart`)

**Find:**
```dart
Image.asset(
  mission.imageUrl!,
  width: size,
  height: size,
  fit: BoxFit.cover,
)
```

**Replace with:**
```dart
import 'package:job_app/core/widgets/smart_image.dart';

SmartImage(
  imageUrl: mission.imageUrl,
  width: size,
  height: size,
  fit: BoxFit.cover,
  fallbackAsset: 'assets/images/default_mission.png',
)
```

### 3. **Mission Details** (`mission_details_screen.dart`, `mission_in_progress_sheet.dart`)

**Find:**
```dart
Image.asset(
  mission.imageUrl!,
  width: 75,
  height: 75,
  fit: BoxFit.cover,
)
```

**Replace with:**
```dart
import 'package:job_app/core/widgets/smart_image.dart';

SmartImage(
  imageUrl: mission.imageUrl,
  width: 75,
  height: 75,
  fit: BoxFit.cover,
)
```

### 4. **Job Cards** (wherever job images are displayed)

**Find:**
```dart
Image.asset(job.imageUrl!)
```

**Replace with:**
```dart
import 'package:job_app/core/widgets/smart_image.dart';

SmartImage(
  imageUrl: job.imageUrl,
  width: double.infinity,
  height: 200,
  fit: BoxFit.cover,
  fallbackAsset: 'assets/images/default_job.png',
)
```

### 5. **Company Logos**

**Find:**
```dart
Image.asset(company.logoUrl!)
```

**Replace with:**
```dart
import 'package:job_app/core/widgets/smart_image.dart';

SmartLogo(
  imageUrl: company.logoUrl,
  size: 50,
  borderRadius: 8,
)
```

### 6. **User Avatars**

**Find:**
```dart
CircleAvatar(
  backgroundImage: AssetImage(user.avatarUrl!),
)
```

**Replace with:**
```dart
import 'package:job_app/core/widgets/smart_image.dart';

SmartAvatar(
  imageUrl: user.avatarUrl,
  radius: 20,
)
```

---

## 🎯 Smart Widget Features

### SmartImage
- ✅ Automatically detects network vs asset images
- ✅ Shows loading indicator while fetching
- ✅ Falls back to placeholder on error
- ✅ Handles null/empty URLs gracefully

### SmartAvatar
- ✅ Circular avatar with automatic image handling
- ✅ Default avatar fallback
- ✅ Customizable radius

### SmartLogo
- ✅ Rounded rectangle logo
- ✅ Default logo fallback
- ✅ Customizable size and border radius

---

## 🔧 Configuration

### Change Backend URL

Edit `lib/core/utils/media_utils.dart`:

```dart
// For local development
static const String _baseUrl = 'http://localhost:8000';

// For production (change to your deployed backend)
static const String _baseUrl = 'https://your-backend.com';

// For Android emulator accessing localhost
static const String _baseUrl = 'http://10.0.2.2:8000';
```

---

## 📱 Testing

### 1. **Start Django Backend**
```bash
cd backend
python manage.py runserver
```

### 2. **Verify Media Serving**
Visit: `http://localhost:8000/media/avatars/demo_candidat.jpg`

Should show the image (not 404)

### 3. **Run Flutter App**
```bash
cd frontend
flutter run
```

### 4. **Check Logs**
Look for successful image loads in console:
```
[ApiClient] GET http://localhost:8000/media/avatars/demo_candidat.jpg
```

---

## 🐛 Troubleshooting

### Images Still Not Loading?

**1. Check Django Media Serving**
```python
# config/urls.py
from django.conf import settings
from django.conf.urls.static import static

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

**2. Check Django Settings**
```python
# config/settings.py
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'
```

**3. Verify Images Exist**
```bash
cd backend
ls media/avatars/
ls media/logos/
ls media/jobs/
ls media/missions/
```

**4. Check Network Permissions (Android)**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
```

**5. Allow HTTP in Development (Android)**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="true"
    ...>
```

---

## ✅ Quick Checklist

- [ ] Created `lib/core/utils/media_utils.dart`
- [ ] Created `lib/core/widgets/smart_image.dart`
- [ ] Replaced `Image.asset()` with `SmartImage()` in notification cards
- [ ] Replaced `Image.asset()` with `SmartImage()` in mission cards
- [ ] Replaced `Image.asset()` with `SmartImage()` in job cards
- [ ] Updated avatar displays to use `SmartAvatar()`
- [ ] Updated logo displays to use `SmartLogo()`
- [ ] Verified Django media serving is configured
- [ ] Generated placeholder images
- [ ] Tested image loading in app

---

## 🎉 Result

After applying these fixes:
- ✅ Images load from Django backend
- ✅ No more "Asset not found" errors
- ✅ Automatic fallback to placeholders
- ✅ Loading indicators while fetching
- ✅ Works with both network and local images

---

## 💡 Pro Tips

1. **Use SmartImage everywhere** - It handles all edge cases automatically
2. **Always provide fallbackAsset** - Better UX when images fail to load
3. **Test with slow network** - Verify loading indicators work
4. **Check Django logs** - See which images are being requested
5. **Use Chrome DevTools** - Inspect network requests from Flutter web

---

## 📞 Need More Help?

If images still don't load:
1. Check Django server is running
2. Check media files exist in `backend/media/`
3. Check Flutter console for network errors
4. Verify `baseUrl` in `media_utils.dart` matches your Django server
5. Check Android permissions for internet access
