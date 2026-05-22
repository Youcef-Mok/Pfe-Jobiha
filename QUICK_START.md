# 🚀 Quick Start Guide - Jobiha Seed Data Setup

## Step 1: Generate Placeholder Images (2 minutes)

Navigate to the backend directory and run the image generator:

```bash
cd backend
python create_placeholder_images.py
```

This will create **41 placeholder images** in the correct folders:
- ✅ 15 user avatars
- ✅ 6 company logos  
- ✅ 15 job images
- ✅ 5 mission images

## Step 2: Verify Media Files

Check that the media folder structure looks like this:

```
backend/media/
├── avatars/
│   ├── user_7.jpg
│   ├── user_8.jpg
│   └── ... (15 files)
├── logos/
│   ├── tech_solutions.png
│   ├── design_studio.png
│   └── ... (6 files)
├── jobs/
│   ├── job_5.jpg
│   ├── job_6.jpg
│   └── ... (15 files)
└── missions/
    ├── mission_3.jpg
    ├── mission_4.jpg
    └── ... (5 files)
```

## Step 3: Run the Seed Data SQL

1. Open your **Neon SQL Editor** (or pgAdmin/DBeaver)
2. Copy the entire content of `seed_data.sql`
3. Paste and execute it

## Step 4: Verify Django Media Serving

Make sure your Django `urls.py` serves media files in development:

```python
# config/urls.py
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    # ... your existing urls
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

## Step 5: Test the Setup

Start your Django server:

```bash
python manage.py runserver
```

Test media access:
- Visit: `http://localhost:8000/media/avatars/user_7.jpg`
- You should see the placeholder image

## ✅ Done!

Your database now has:
- 15 new users with avatars
- 15 job offers with images
- 20 candidatures
- 5 missions with images
- 10 conversations with 30 messages
- 10 interviews
- 8 evaluations
- 25 notifications with proper images
- 10 saved jobs
- 8 job alerts
- 15 recent searches

All images are served locally from `/media/` and will display in your app!

---

## 🎨 Optional: Replace with Real Images

If you want to use real images instead of placeholders:

1. Download professional images from:
   - https://unsplash.com/
   - https://pexels.com/
   - https://thispersondoesnotexist.com/ (for avatars)

2. Replace the placeholder files with your downloaded images
3. Keep the same filenames (e.g., `user_7.jpg`, `job_5.jpg`, etc.)

---

## 🔧 Troubleshooting

**Images not showing?**
- Check that `MEDIA_URL = '/media/'` in settings.py
- Check that `MEDIA_ROOT = BASE_DIR / 'media'` in settings.py
- Verify media URL patterns are added in urls.py
- Restart Django server after changes

**PIL/Pillow not installed?**
```bash
pip install Pillow
```

**Need to regenerate images?**
Just run the script again - it will overwrite existing files.
