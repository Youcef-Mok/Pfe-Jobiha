# Next Steps - Backend Implementation

All database migrations have been successfully applied. Here's what needs to be done next to complete the backend implementation:

## ✅ Completed
- All database schema changes from DB-CHANGES.md
- 6 migration files created and applied
- 13 new models created
- All existing models updated with required fields
- Database integrity verified (no Django check issues)

---

## 🔄 Next Steps

### 1. Update Serializers

You need to update/create serializers for all modified models. Key serializers to update:

#### Priority 1 - Core User Serializers
- **UtilisateurSerializer** - Add avatar_url, location, bio, computed name field
- **RecruteurSerializer** - Add titre_poste, domain
- **CandidatSerializer** - Add titre_poste, domain
- Create serializers for new models:
  - RestrictedUserSerializer
  - CandidateSkillGroupSerializer, CandidateSkillSerializer
  - CandidateLanguageSerializer
  - CandidateToolSerializer
  - CvFormationSerializer, CvExperienceSerializer

#### Priority 2 - Jobs Serializers
- **OffreSerializer** - Add created_at, logo_url, location, schedule_label
  - Add computed fields: company_name, recruiter_name, recruiter_role, recruiter_avatar_asset
- **MissionSerializer** - Add summary field
  - Add computed fields: job_id, job_title, company_name, department, recruiter_name, candidate_name, ratings, feedback
  - Map status values (en_attente → unconfirmed, etc.)
- **InterviewSerializer** - Add candidature field
  - Add computed fields: candidate_name, candidate_avatar, job_title, department
- Create serializers for:
  - JobCommentSerializer
  - MissionTeamMemberSerializer

#### Priority 3 - Applications Serializers
- **CandidatureSerializer** - Update for DateTimeField
  - Map status values (en_attente → pending, etc.)
  - Add computed fields: job_title, company_name, department, logo_asset, location, contract_type, schedule_label, interview_date, candidate info

#### Priority 4 - Messaging & Notifications
- **MessageSerializer** - Add type field, is_mine computed field
- **NotificationSerializer** - Add context_image_url, update count to nullable

#### Priority 5 - Reviews
- **EvaluationSerializer** - Add recruiter_reply, recruiter_name, recruiter_reply_date
  - Add computed fields: author_name, author_role, author_avatar
  - Cast rating to float
- **SignalementSerializer** - Add target_type, message fields

### 2. Update Views/ViewSets

Update views to handle new fields and relationships:

- **Users views** - Handle new profile fields, restricted users endpoints
- **Jobs views** - Handle job comments, mission team members
- **Applications views** - Handle updated candidature datetime field
- **Reviews views** - Handle evaluation replies

### 3. Update Admin Panel

Register new models in admin.py files:
- apps/users/admin.py - Add RestrictedUser, CandidateSkillGroup, CandidateSkill, CandidateLanguage, CandidateTool, CvFormation, CvExperience
- apps/jobs/admin.py - Add JobComment, MissionTeamMember

### 4. API Endpoints to Implement/Update

Based on API_SPEC.md, ensure these endpoints work with new fields:

#### Users
- GET/PUT /users/me - Include new fields
- GET /users/:id - Include new fields
- GET/POST/DELETE /users/me/restricted - New endpoint for RestrictedUser
- GET /candidates/:id/profile - Use new skill, language, tool models
- GET /users/:userId/cv - Use new CvFormation, CvExperience models

#### Jobs
- GET /jobs - Include new offre fields
- GET /jobs/:id - Include comments[] from JobComment model
- GET /missions/:id - Include team[] from MissionTeamMember model

#### Applications
- GET /applications - Handle datetime field properly

#### Reviews
- POST /reviews/:id/reply - Handle recruiter_reply fields

### 5. Testing

Create/update tests for:
- New model creation and validation
- Serializer field mapping
- Status value mapping (Mission, Candidature)
- Computed fields in serializers
- New API endpoints

### 6. Data Migration (if needed)

If you have existing data:
- Existing Offre records will have created_at set to migration time
- Existing Candidature records will have date_postulation converted to datetime
- Existing Notification count values remain as-is (can be null for new records)

---

## Important Reminders

### Status Mapping
Always map database status values to API values in serializers:

**Mission:**
- en_attente → unconfirmed
- en_cours → in_progress
- terminee → completed
- annulee → cancelled

**Candidature:**
- en_attente → pending
- acceptee → accepted
- refusee → rejected

**Account Type:**
- candidat → candidate
- recruteur → recruiter

### Computed Fields
Many API fields are computed from relationships, not stored in DB. Implement these in serializers using SerializerMethodField:
- User name (prenom + nom)
- Company names (via recruteur.nom_structure)
- Ratings (via Evaluation queries)
- Counts (via aggregations)

### File Uploads
For avatar_url, logo_url, image_url fields - ensure your file upload handling is configured properly in Django settings.

---

## Quick Verification Commands

```bash
# Check for any issues
python manage.py check

# View all migrations
python manage.py showmigrations

# Create a superuser to test admin panel
python manage.py createsuperuser

# Run development server
python manage.py runserver

# Run tests (once created)
python manage.py test
```

---

## Documentation

- See `DB_CHANGES_APPLIED.md` for complete list of changes
- See `DB-CHANGES.md` for original requirements
- See `API_SPEC.md` for API endpoint specifications
