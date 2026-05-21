# API Quick Reference - Recruiter Endpoints

## Base URL
```
http://localhost:8000/api/v1
```

## Authentication
All endpoints require Bearer token:
```
Authorization: Bearer <your_token>
```

---

## 📋 Jobs (Offres)

### GET /jobs/mine
Get recruiter's own jobs with filters.

**Query Params:**
- `status`: `draft`, `searching`, `closed`
- `posted_within`: `3d`, `7d`, `30d`, `90d`, `180d`
- `department`: Department name

**Response:**
```json
{
  "results": [{
    "id": "1",
    "title": "Backend Developer",
    "company_name": "Tech Corp",
    "recruiter_id": "5",
    "recruiter_name": "John Doe",
    "recruiter_role": "HR Manager",
    "recruiter_avatar_asset": "https://...",
    "department": "IT",
    "contract_type": "cdi",
    "posted_at": "2024-01-15T10:30:00Z",
    "status": "searching",
    "candidate_count": 5,
    "view_count": 120,
    "logo_asset": "https://...",
    "is_published": true,
    "location": "Paris",
    "schedule_label": "9h-17h"
  }]
}
```

### GET /jobs/:id
Get job details with candidates and comments.

**Response includes:**
- All fields from list view
- `candidates[]`: Array of candidate summaries
- `comments[]`: Array of Q&A comments

### POST /jobs
Create a new job.

**Body:**
```json
{
  "title": "Backend Developer",
  "contract_type": "cdi",
  "description": "Job description...",
  "candidate_count": 1,
  "salary": 50000.0,
  "is_published": false,
  "department": "IT",
  "location": "Paris",
  "schedule_label": "9h-17h"
}
```

### PUT /jobs/:id
Update a job (all fields optional).

### DELETE /jobs/:id
Delete a job.

---

## 🎯 Missions

### GET /missions
Get missions for recruiter.

**Query Params:**
- `status`: `unconfirmed`, `in_progress`, `completed`, `cancelled`
- `job_id`: Filter by job
- `max_duration`: `7d`, `14d`, `30d`, `90d`, `180d`
- `department`: Department name

**Response:**
```json
{
  "results": [{
    "id": "1",
    "job_id": "5",
    "job_title": "Backend Developer",
    "company_name": "Tech Corp",
    "department": "IT",
    "start_date": "2024-01-20T09:00:00Z",
    "end_date": "2024-02-20T18:00:00Z",
    "location": "Paris",
    "recruiter_name": "John Doe",
    "candidate_name": "Jane Smith",
    "candidate_rating": 4.5,
    "recruiter_rating": 4.8,
    "candidate_feedback": "Great experience!",
    "recruiter_feedback": "Excellent work!",
    "status": "in_progress",
    "summary": "Mission summary...",
    "image_url": "https://...",
    "team": [
      {
        "name": "Bob Johnson",
        "role": "Team Lead",
        "rating": 4.7,
        "avatar_url": "https://..."
      }
    ]
  }]
}
```

### POST /missions
Create a new mission.

**Body:**
```json
{
  "job_id": "5",
  "candidate_name": "Jane Smith",
  "start_date": "2024-01-20T09:00:00Z",
  "end_date": "2024-02-20T18:00:00Z",
  "location": "Paris",
  "image_url": "https://..."
}
```

### PATCH /missions/:id/confirm
Confirm an unconfirmed mission (changes status to `in_progress`).

### PUT /missions/:id/review
Submit review for a mission.

**Body:**
```json
{
  "rating": 4.5,
  "feedback": "Great work!"
}
```

---

## 👥 Candidates

### GET /jobs/:jobId/candidates
Get candidates who applied to a job.

**Query Params:**
- `status`: `nouveau`, `examine`, `archive`
- `sort`: `recent`, `best`

**Response:**
```json
{
  "results": [{
    "id": "10",
    "name": "Jane Smith",
    "title": "Backend Developer",
    "photo_url": "https://...",
    "rating": 4.8,
    "reviews_count": 12,
    "is_top_rated": true,
    "cover_letter": "I am interested...",
    "status": "nouveau"
  }]
}
```

### PUT /candidates/:candidateId/status
Update candidate status.

**Body:**
```json
{
  "status": "examine"
}
```

---

## 📝 Applications (Candidatures)

### GET /applications
Get applications (recruiter sees received applications).

**Query Params:**
- `status`: `pending`, `accepted`, `rejected`
- `applied_within`: `today`, `3d`, `7d`, `30d`
- `department`: Department name

**Response:**
```json
{
  "results": [{
    "id": "15",
    "job_id": "5",
    "job_title": "Backend Developer",
    "company_name": "Tech Corp",
    "department": "IT",
    "logo_asset": "https://...",
    "status": "pending",
    "applied_at": "2024-01-15T14:30:00Z",
    "location": "Paris",
    "contract_type": "cdi",
    "schedule_label": "9h-17h",
    "interview_date": "Entretien prévu le 18 Jan.",
    "candidate_name": "Jane Smith",
    "candidate_avatar": "https://...",
    "candidate_domain": "Web Development",
    "candidate_rating": 4.5,
    "motivation_letter": "I am very interested..."
  }]
}
```

### PUT /applications/:id/accept
Accept an application.

### PUT /applications/:id/reject
Reject an application.

---

## 📅 Interviews

### GET /interviews
Get interviews for recruiter.

**Query Params:**
- `upcoming`: `true` (only future interviews)
- `status`: `scheduled`, `completed`, `cancelled`
- `scheduled_within`: `today`, `this_week`, `this_month`, `next_month`
- `department`: Department name

**Response:**
```json
[{
  "id": "20",
  "candidate_id": "10",
  "candidate_name": "Jane Smith",
  "candidate_avatar": "https://...",
  "job_id": "5",
  "job_title": "Backend Developer",
  "department": "IT",
  "scheduled_date": "2024-01-18T10:00:00Z",
  "status": "scheduled",
  "notes": "Phone interview"
}]
```

### POST /interviews
Schedule an interview.

**Body:**
```json
{
  "candidate_id": "10",
  "job_id": "5",
  "scheduled_date": "2024-01-18T10:00:00Z",
  "notes": "Phone interview"
}
```

### PUT /interviews/:id
Update an interview.

**Body:**
```json
{
  "scheduled_date": "2024-01-19T10:00:00Z",
  "notes": "Updated notes"
}
```

### DELETE /interviews/:id
Cancel an interview.

### PUT /interviews/:id/complete
Mark interview as completed.

**Body:**
```json
{
  "notes": "Candidate performed well"
}
```

---

## 🔑 Key Points

### Field Naming
- ✅ All fields are **snake_case** (e.g., `candidate_name`, `posted_at`)
- ❌ No camelCase (e.g., ~~`candidateName`~~, ~~`postedAt`~~)

### Status Values

**Jobs:** `draft`, `searching`, `closed`

**Missions:**
- DB: `en_attente`, `en_cours`, `terminee`, `annulee`
- API: `unconfirmed`, `in_progress`, `completed`, `cancelled`

**Applications:**
- DB: `en_attente`, `acceptee`, `refusee`
- API: `pending`, `accepted`, `rejected`

**Interviews:** `scheduled`, `completed`, `cancelled`

### Data Types
- IDs: Returned as **strings** (e.g., `"1"`, not `1`)
- Ratings: Returned as **floats** (e.g., `4.5`, not `4`)
- Dates: ISO8601 format (e.g., `"2024-01-15T10:30:00Z"`)
- Null values: Returned as `null`, not empty strings

### Arrays
- Always returned as arrays, never `null`
- Empty arrays: `[]`
- Examples: `candidates`, `comments`, `team`

---

## 🧪 Testing

Run the test script:
```bash
python test_recruiter_endpoints.py
```

Or use curl:
```bash
# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"recruiter@test.com","password":"password123"}'

# Get jobs
curl http://localhost:8000/api/v1/jobs/mine \
  -H "Authorization: Bearer <token>"

# Create job
curl -X POST http://localhost:8000/api/v1/jobs \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Job",
    "contract_type": "cdi",
    "description": "Test",
    "candidate_count": 1,
    "is_published": false
  }'
```

---

## 📚 Additional Resources

- Full implementation details: `RECRUITER_API_IMPLEMENTATION.md`
- API specification: `API_SPEC.md`
- Database changes: `DB_CHANGES_APPLIED.md`
