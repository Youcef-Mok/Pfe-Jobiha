# 📸 Media Files Setup Guide for Jobiha Seed Data

This guide shows you exactly which images to download and where to place them for the seed data to work properly.

## 📁 Directory Structure

Create these folders in `backend/media/`:

```
backend/media/
├── avatars/           # User profile pictures
├── logos/             # Company logos
├── jobs/              # Job offer images
└── missions/          # Mission images
```

## 🎯 Quick Setup Commands

Run these commands from the `backend` directory:

```bash
mkdir media\avatars
mkdir media\logos
mkdir media\jobs
mkdir media\missions
```

---

## 👤 AVATARS (User Profile Pictures)

**Location:** `backend/media/avatars/`

Download any profile pictures (or use placeholder images) and name them as follows:

### Candidats:
- `user_7.jpg` - Amina Benali (female, professional)
- `user_8.jpg` - Yacine Khelifi (male, creative)
- `user_9.jpg` - Salima Meziane (female, architect)
- `user_10.jpg` - Karim Boudiaf (male, engineer)
- `user_11.jpg` - Nadia Hamidi (female, analyst)
- `user_12.jpg` - Mehdi Saidi (male, designer)
- `user_13.jpg` - Fatima Larbi (female, project manager)
- `user_14.jpg` - Riad Cherif (male, developer)
- `user_15.jpg` - Leila Bouzid (female, marketing)

### Recruteurs:
- `user_16.jpg` - Ahmed (male, HR)
- `user_17.jpg` - Samira (female, creative director)
- `user_18.jpg` - Rachid (male, construction)
- `user_19.jpg` - Yasmine (female, CEO)
- `user_20.jpg` - Sofiane (male, operations)
- `user_21.jpg` - Meriem (female, recruitment)

**Suggested sources:**
- Use https://thispersondoesnotexist.com/ (AI-generated faces)
- Use https://randomuser.me/photos (free random user photos)
- Use https://unsplash.com/s/photos/professional-portrait
- Or use any placeholder service like https://i.pravatar.cc/300

---

## 🏢 LOGOS (Company Logos)

**Location:** `backend/media/logos/`

Create or download simple logo images:

- `tech_solutions.png` - Tech company logo (blue/tech theme)
- `design_studio.png` - Creative agency logo (colorful/artistic)
- `btp_algerie.png` - Construction company logo (orange/yellow/industrial)
- `digital_agency.png` - Digital agency logo (modern/gradient)
- `construction_plus.png` - Construction logo (solid/professional)
- `web_innovate.png` - Tech startup logo (innovative/modern)

**Suggested approach:**
- Use https://logo.com/ or https://looka.com/ (free logo generators)
- Use simple colored squares with company initials
- Use https://unsplash.com/s/photos/company-logo
- Or create simple 200x200px colored rectangles with text

---

## 💼 JOB IMAGES (Job Offer Cover Images)

**Location:** `backend/media/jobs/`

Download relevant images for each job category:

### Informatique (IT Jobs):
- `job_5.jpg` - Backend development (code on screen, dark theme)
- `job_6.jpg` - Project management (team meeting, whiteboard)
- `job_7.jpg` - Mobile development (phone with app, Flutter logo)
- `job_8.jpg` - Data analysis (charts, graphs, analytics)
- `job_9.jpg` - Full stack (laptop with code, modern workspace)

### Design Jobs:
- `job_10.jpg` - UI/UX design (Figma interface, design mockups)
- `job_11.jpg` - Graphic design (Adobe tools, creative workspace)
- `job_12.jpg` - Motion design (video editing, After Effects)
- `job_13.jpg` - Product design (mobile app screens, prototypes)

### BTP (Construction Jobs):
- `job_14.jpg` - Civil engineering (construction site, blueprints)
- `job_15.jpg` - Architecture (building plans, modern architecture)
- `job_16.jpg` - Site manager (construction site, hard hat)
- `job_17.jpg` - Works supervisor (infrastructure, roads)
- `job_18.jpg` - Draftsman (AutoCAD, technical drawings)
- `job_19.jpg` - Quantity surveyor (construction documents)

**Suggested sources:**
- https://unsplash.com/s/photos/programming
- https://unsplash.com/s/photos/design-workspace
- https://unsplash.com/s/photos/construction
- https://pexels.com/ (free stock photos)

---

## 🎯 MISSION IMAGES

**Location:** `backend/media/missions/`

- `mission_3.jpg` - SaaS development (modern office, coding)
- `mission_4.jpg` - Team coordination (agile board, sprint planning)
- `mission_5.jpg` - Video production (video editing workspace)
- `mission_6.jpg` - Architecture project (building design, plans)
- `mission_7.jpg` - Infrastructure supervision (construction site)

---

## 🚀 Quick Setup with Placeholder Images

If you want to quickly test without downloading images, you can use this Python script:

```python
# Run from backend directory: python create_placeholder_images.py

from PIL import Image, ImageDraw, ImageFont
import os

def create_placeholder(path, text, color, size=(800, 600)):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img = Image.new('RGB', size, color=color)
    draw = ImageDraw.Draw(img)
    
    # Add text in center
    bbox = draw.textbbox((0, 0), text)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    position = ((size[0] - text_width) // 2, (size[1] - text_height) // 2)
    draw.text(position, text, fill='white')
    
    img.save(path)
    print(f"Created: {path}")

# Create avatars
colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12', '#9b59b6']
for i in range(7, 22):
    color = colors[(i - 7) % len(colors)]
    create_placeholder(f'media/avatars/user_{i}.jpg', f'User {i}', color, (300, 300))

# Create logos
logo_names = ['tech_solutions', 'design_studio', 'btp_algerie', 'digital_agency', 'construction_plus', 'web_innovate']
for name in logo_names:
    create_placeholder(f'media/logos/{name}.png', name.replace('_', ' ').title(), '#2c3e50', (200, 200))

# Create job images
for i in range(5, 20):
    create_placeholder(f'media/jobs/job_{i}.jpg', f'Job {i}', '#34495e')

# Create mission images
for i in range(3, 8):
    create_placeholder(f'media/missions/mission_{i}.jpg', f'Mission {i}', '#16a085')

print("\n✅ All placeholder images created!")
```

---

## 📝 After Creating Images

Once you've placed all images in their folders, update the seed data SQL file to use local URLs instead of external ones.

The updated SQL file will use paths like:
- `/media/avatars/user_7.jpg`
- `/media/logos/tech_solutions.png`
- `/media/jobs/job_5.jpg`
- `/media/missions/mission_3.jpg`

---

## ✅ Verification

After setup, your media folder should look like:

```
media/
├── avatars/
│   ├── user_7.jpg
│   ├── user_8.jpg
│   ├── ... (15 files total)
│   └── user_21.jpg
├── logos/
│   ├── tech_solutions.png
│   ├── design_studio.png
│   ├── ... (6 files total)
│   └── web_innovate.png
├── jobs/
│   ├── job_5.jpg
│   ├── job_6.jpg
│   ├── ... (15 files total)
│   └── job_19.jpg
└── missions/
    ├── mission_3.jpg
    ├── mission_4.jpg
    ├── ... (5 files total)
    └── mission_7.jpg
```

**Total files needed:** 41 images (15 avatars + 6 logos + 15 jobs + 5 missions)
