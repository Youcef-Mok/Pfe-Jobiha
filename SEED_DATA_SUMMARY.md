# 📊 Jobiha Seed Data - Complete Summary

## 🎯 What Was Created

### 1. **SQL Seed File** (`seed_data.sql`)
Complete PostgreSQL seed data with:
- ✅ All IDs start from existing max IDs (no conflicts)
- ✅ Realistic Algerian data (names, cities, phone numbers)
- ✅ Local media URLs (no external dependencies)
- ✅ Proper relationships between all tables

### 2. **Image Generator Script** (`backend/create_placeholder_images.py`)
Python script that automatically creates:
- 15 user avatars (300x300px)
- 6 company logos (200x200px)
- 15 job images (800x600px)
- 5 mission images (800x600px)

### 3. **Documentation**
- `MEDIA_SETUP_GUIDE.md` - Detailed image setup instructions
- `QUICK_START.md` - Fast setup guide (< 5 minutes)
- `SEED_DATA_SUMMARY.md` - This file

---

## 📦 Data Breakdown

### Users (15 new users, IDs 7-21)

**Candidats (9):**
| ID | Name | City | Role | Avatar |
|----|------|------|------|--------|
| 7 | Amina Benali | Alger | Développeuse Full Stack | `/media/avatars/user_7.jpg` |
| 8 | Yacine Khelifi | Bejaia | Designer UI/UX | `/media/avatars/user_8.jpg` |
| 9 | Salima Meziane | Oran | Architecte | `/media/avatars/user_9.jpg` |
| 10 | Karim Boudiaf | Constantine | Ingénieur Génie Civil | `/media/avatars/user_10.jpg` |
| 11 | Nadia Hamidi | Alger | Data Analyst | `/media/avatars/user_11.jpg` |
| 12 | Mehdi Saidi | Oran | Graphiste | `/media/avatars/user_12.jpg` |
| 13 | Fatima Larbi | Bejaia | Chef de Projet IT | `/media/avatars/user_13.jpg` |
| 14 | Riad Cherif | Constantine | Développeur Mobile | `/media/avatars/user_14.jpg` |
| 15 | Leila Bouzid | Alger | Marketing Digital | `/media/avatars/user_15.jpg` |

**Recruteurs (6):**
| ID | Company | Contact | City | Logo |
|----|---------|---------|------|------|
| 16 | Tech Solutions DZ | Ahmed | Alger | `/media/logos/tech_solutions.png` |
| 17 | Design Studio Algérie | Samira | Oran | `/media/logos/design_studio.png` |
| 18 | BTP Algérie Construction | Rachid | Constantine | `/media/logos/btp_algerie.png` |
| 19 | Digital Agency DZ | Yasmine | Alger | `/media/logos/digital_agency.png` |
| 20 | Construction Plus | Sofiane | Bejaia | `/media/logos/construction_plus.png` |
| 21 | Web Innovate | Meriem | Oran | `/media/logos/web_innovate.png` |

---

### Job Offers (15 new offers, IDs 5-19)

**Informatique (5 jobs):**
- Backend Python/Django (CDI, 80k DA)
- Chef de Projet IT (CDI, 120k DA)
- Mobile Flutter (CDD, 60k DA)
- Data Analyst (CDI, 70k DA)
- Full Stack React/Node (Mission, 45k DA)

**Design (4 jobs):**
- UI/UX Senior (CDD, 65k DA)
- Graphiste Print/Digital (CDI, 55k DA)
- Motion Designer (Freelance, 40k DA)
- Designer Produit (CDI, 75k DA)

**BTP (6 jobs):**
- Ingénieur Génie Civil (CDI, 90k DA)
- Architecte Résidentiel (CDI, 100k DA)
- Chef de Chantier (CDD, 70k DA)
- Conducteur de Travaux (CDI, 85k DA)
- Dessinateur Projeteur (Mission, 35k DA)
- Métreur Vérificateur (CDD, 60k DA)

---

### Candidatures (20 applications, IDs 6-25)

**Status Distribution:**
- 🟡 **en_attente**: 7 applications
- 🟢 **acceptee**: 5 applications
- 🔴 **refusee**: 8 applications

---

### Missions (5 missions, IDs 3-7)

| ID | Status | Candidat | Type | Duration |
|----|--------|----------|------|----------|
| 3 | en_cours | Amina | SaaS Dev | Ongoing |
| 4 | en_cours | Fatima | Team Coord | Ongoing |
| 5 | terminee | Yacine | Video Prod | 200h |
| 6 | terminee | Salima | Architecture | 280h |
| 7 | en_attente | Karim | Infrastructure | Not started |

---

### Conversations & Messages

**10 Conversations:**
- 7 Direct Messages (DM)
- 3 Group Conversations

**30 Messages:**
- Realistic conversation flows
- Mix of job inquiries, interview scheduling, mission updates
- Group discussions for team projects

---

### Interviews (10 interviews, IDs 1-10)

**Status Distribution:**
- 📅 **scheduled**: 4 (upcoming)
- ✅ **completed**: 3 (with notes)
- ❌ **cancelled**: 3 (with reasons)

---

### Evaluations (8 evaluations, IDs 1-8)

**Rating Distribution:**
- ⭐⭐⭐⭐⭐ (5 stars): 2 evaluations
- ⭐⭐⭐⭐ (4 stars): 3 evaluations
- ⭐⭐⭐ (3 stars): 3 evaluations

Some include recruiter replies!

---

### Notifications (25 notifications, IDs 1-25)

**Recruiter Notifications (10):**
- newApplicants
- interviewAccepted
- newMessage
- missionExpiring
- missionCompleted
- jobQuestion
- announcementCreated

**Candidate Notifications (13):**
- applicationAccepted
- applicationRejected
- applicationViewed
- newNearbyOffer
- jobMatchingPreferences
- savedJobExpiring
- newJobInCategory
- profileViewed
- profileIncomplete

**System Notifications (2):**
- App updates
- Welcome messages

---

### Additional Data

**Saved Jobs (10):** Candidates bookmarking interesting offers

**Job Alerts (8):** Active job search alerts with criteria

**Recent Searches (15):** User search history

**Read Cursors (24):** Conversation read status tracking

---

## 🔐 Login Credentials

**All users have the same password:**
```
password123
```

**Example logins:**
- Candidat: `amina.benali@gmail.com` / `password123`
- Recruteur: `ahmed@techsolutions.dz` / `password123`

---

## 📁 Media Files Structure

```
backend/media/
├── avatars/          # 15 user profile pictures
│   ├── user_7.jpg
│   ├── user_8.jpg
│   └── ... (user_21.jpg)
│
├── logos/            # 6 company logos
│   ├── tech_solutions.png
│   ├── design_studio.png
│   └── ... (web_innovate.png)
│
├── jobs/             # 15 job offer images
│   ├── job_5.jpg
│   ├── job_6.jpg
│   └── ... (job_19.jpg)
│
└── missions/         # 5 mission images
    ├── mission_3.jpg
    ├── mission_4.jpg
    └── ... (mission_7.jpg)
```

**Total: 41 images**

---

## 🚀 Setup Instructions

### Quick Setup (< 5 minutes)

1. **Generate images:**
   ```bash
   cd backend
   python create_placeholder_images.py
   ```

2. **Run SQL seed:**
   - Open Neon SQL Editor
   - Copy/paste `seed_data.sql`
   - Execute

3. **Start Django:**
   ```bash
   python manage.py runserver
   ```

4. **Test:**
   - Visit: `http://localhost:8000/media/avatars/user_7.jpg`
   - Login to app with any user credentials

### Detailed Setup

See `QUICK_START.md` for step-by-step instructions.

---

## ✅ Verification Checklist

- [ ] All 41 images generated in `backend/media/`
- [ ] SQL seed executed without errors
- [ ] Django server running
- [ ] Media files accessible at `/media/` URLs
- [ ] Can login with test credentials
- [ ] User avatars showing in app
- [ ] Job images displaying
- [ ] Company logos visible
- [ ] Notifications showing with images

---

## 🎨 Customization

### Replace Placeholder Images

To use real images instead of placeholders:

1. Download images from:
   - **Avatars**: https://thispersondoesnotexist.com/
   - **Jobs/Missions**: https://unsplash.com/ or https://pexels.com/
   - **Logos**: Create with https://logo.com/ or https://looka.com/

2. Replace files keeping the same names:
   - `user_7.jpg`, `user_8.jpg`, etc.
   - `job_5.jpg`, `job_6.jpg`, etc.
   - `tech_solutions.png`, etc.

3. Recommended sizes:
   - Avatars: 300x300px
   - Logos: 200x200px
   - Jobs/Missions: 800x600px

---

## 🔧 Troubleshooting

**Images not showing in app?**
1. Check Django settings:
   - `MEDIA_URL = '/media/'`
   - `MEDIA_ROOT = BASE_DIR / 'media'`
2. Verify `config/urls.py` has media static serving
3. Restart Django server

**PIL/Pillow error?**
```bash
pip install Pillow
```

**Need to regenerate images?**
```bash
python create_placeholder_images.py
```
(Will overwrite existing files)

**Database conflicts?**
- The seed data starts IDs from existing max IDs
- If you get conflicts, check current max IDs:
  ```sql
  SELECT MAX(id) FROM utilisateur;
  SELECT MAX(id) FROM offre;
  -- etc.
  ```

---

## 📞 Support

If you encounter issues:
1. Check `QUICK_START.md` for common solutions
2. Verify all files are in correct locations
3. Ensure Django media serving is configured
4. Check database sequences are updated

---

## 🎉 Success!

You now have a fully populated Jobiha database with:
- ✅ 15 realistic Algerian users
- ✅ 15 diverse job offers
- ✅ Complete application workflow data
- ✅ Active conversations and messages
- ✅ Interviews and evaluations
- ✅ Rich notifications
- ✅ All images served locally

**Ready to demo your app!** 🚀
