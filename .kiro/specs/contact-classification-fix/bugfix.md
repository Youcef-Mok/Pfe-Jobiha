# Bugfix Requirements Document

## Introduction

The create_group_screen.dart incorrectly classifies contacts as recruiters or non-recruiters based on which data source they come from, rather than their actual user type. This causes misclassification when:
- A recruiter appears in the "recents" section (from conversations) - incorrectly marked as NOT a recruiter
- A non-recruiter appears in the "recruteurs" section (from published jobs) - incorrectly marked as a recruiter

The backend provides a `role` field (via `user.role` property) that returns `'candidat'` or `'recruteur'`, but the frontend ignores this information and hardcodes the `isRecruiter` flag based on the data source.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a contact is fetched from conversations (recents section) THEN the system hardcodes `isRecruiter: false` regardless of the contact's actual role

1.2 WHEN a contact is fetched from published jobs (recruteurs section) THEN the system hardcodes `isRecruiter: true` regardless of the contact's actual role

1.3 WHEN the backend returns `contact_role` field from GET /api/v1/conversations THEN the frontend does not use this field to determine if the contact is a recruiter

1.4 WHEN a recruiter has a conversation with the user THEN they appear in "recents" with `isRecruiter: false` even though they are actually a recruiter

### Expected Behavior (Correct)

2.1 WHEN a contact is fetched from conversations THEN the system SHALL determine `isRecruiter` based on the `contact_role` field returned by the API

2.2 WHEN a contact is fetched from published jobs THEN the system SHALL determine `isRecruiter` based on the actual user role, not assume all are recruiters

2.3 WHEN the backend returns `contact_role` with value `'recruteur'` THEN the frontend SHALL set `isRecruiter: true`

2.4 WHEN the backend returns `contact_role` with value `'candidat'` or any other value THEN the frontend SHALL set `isRecruiter: false`

2.5 WHEN a recruiter has a conversation with the user THEN they SHALL appear in "recents" with `isRecruiter: true` if their role is 'recruteur'

### Unchanged Behavior (Regression Prevention)

3.1 WHEN contacts are displayed in the UI THEN the system SHALL CONTINUE TO show them in their respective sections (recents, suggestions, recruiters)

3.2 WHEN a contact is selected for group creation THEN the system SHALL CONTINUE TO track selections correctly regardless of which section they came from

3.3 WHEN the "recruteurs" section is populated from published jobs THEN the system SHALL CONTINUE TO extract recruiter information from job data

3.4 WHEN the "recents" section is populated from conversations THEN the system SHALL CONTINUE TO extract contact information from conversation data

3.5 WHEN a contact has no role information available THEN the system SHALL CONTINUE TO default to `isRecruiter: false`

3.6 WHEN the ContactItem widget displays a contact THEN the system SHALL CONTINUE TO render the contact's name, role, avatar, and online status correctly
