#!/usr/bin/env python
"""
Test script for recruiter endpoints.
Run with: python test_recruiter_endpoints.py

This script tests all recruiter-side endpoints to verify:
1. Field names are snake_case
2. Status values are correctly mapped
3. Query parameters work correctly
4. POST/PUT accept snake_case field names
"""

import requests
import json
from datetime import datetime, timedelta

# Configuration
BASE_URL = "http://localhost:8000/api/v1"
TOKEN = None  # Will be set after login

# ANSI color codes for output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'


def print_test(name, passed, details=""):
    """Print test result with color."""
    status = f"{GREEN}✓ PASS{RESET}" if passed else f"{RED}✗ FAIL{RESET}"
    print(f"{status} - {name}")
    if details:
        print(f"  {details}")


def print_section(name):
    """Print section header."""
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}{name}{RESET}")
    print(f"{BLUE}{'='*60}{RESET}\n")


def login_as_recruiter(email="recruiter@test.com", password="password123"):
    """Login and get token."""
    global TOKEN
    response = requests.post(
        f"{BASE_URL}/auth/login",
        json={"email": email, "password": password}
    )
    if response.status_code == 200:
        TOKEN = response.json().get('access_token')
        print_test("Login as recruiter", True, f"Token: {TOKEN[:20]}...")
        return True
    else:
        print_test("Login as recruiter", False, f"Status: {response.status_code}")
        return False


def get_headers():
    """Get authorization headers."""
    return {"Authorization": f"Bearer {TOKEN}"}


def test_jobs_mine():
    """Test GET /jobs/mine endpoint."""
    print_section("Testing GET /jobs/mine")
    
    # Test basic endpoint
    response = requests.get(f"{BASE_URL}/jobs/mine", headers=get_headers())
    passed = response.status_code == 200
    print_test("GET /jobs/mine - Basic", passed, f"Status: {response.status_code}")
    
    if passed:
        data = response.json()
        results = data.get('results', [])
        
        if results:
            job = results[0]
            
            # Check snake_case field names
            required_fields = [
                'id', 'title', 'company_name', 'recruiter_id', 'recruiter_name',
                'recruiter_role', 'recruiter_avatar_asset', 'department',
                'contract_type', 'posted_at', 'status', 'candidate_count',
                'view_count', 'logo_asset', 'is_published'
            ]
            
            missing_fields = [f for f in required_fields if f not in job]
            if missing_fields:
                print_test("Field names check", False, f"Missing: {missing_fields}")
            else:
                print_test("Field names check", True, "All required fields present")
            
            # Check no camelCase fields
            camel_case_fields = [k for k in job.keys() if any(c.isupper() for c in k)]
            if camel_case_fields:
                print_test("No camelCase check", False, f"Found: {camel_case_fields}")
            else:
                print_test("No camelCase check", True)
    
    # Test with filters
    response = requests.get(
        f"{BASE_URL}/jobs/mine?status=searching&posted_within=30d&department=IT",
        headers=get_headers()
    )
    print_test("GET /jobs/mine - With filters", response.status_code == 200)


def test_jobs_detail():
    """Test GET /jobs/:id endpoint."""
    print_section("Testing GET /jobs/:id")
    
    # First get a job ID
    response = requests.get(f"{BASE_URL}/jobs/mine", headers=get_headers())
    if response.status_code == 200:
        results = response.json().get('results', [])
        if results:
            job_id = results[0]['id']
            
            # Test detail endpoint
            response = requests.get(f"{BASE_URL}/jobs/{job_id}", headers=get_headers())
            passed = response.status_code == 200
            print_test(f"GET /jobs/{job_id}", passed)
            
            if passed:
                job = response.json()
                
                # Check for candidates and comments arrays
                has_candidates = 'candidates' in job
                has_comments = 'comments' in job
                
                print_test("Has candidates array", has_candidates)
                print_test("Has comments array", has_comments)
                
                if has_candidates and job['candidates']:
                    candidate = job['candidates'][0]
                    required = ['initials', 'name', 'role', 'rating', 'avatar_url']
                    missing = [f for f in required if f not in candidate]
                    print_test("Candidate structure", len(missing) == 0, 
                             f"Missing: {missing}" if missing else "All fields present")


def test_create_job():
    """Test POST /jobs endpoint."""
    print_section("Testing POST /jobs")
    
    job_data = {
        "title": "Test Job",
        "contract_type": "cdi",
        "description": "Test job description",
        "candidate_count": 1,
        "salary": 50000.0,
        "is_published": False,
        "department": "IT",
        "location": "Paris",
        "schedule_label": "9h-17h"
    }
    
    response = requests.post(
        f"{BASE_URL}/jobs",
        headers=get_headers(),
        json=job_data
    )
    
    passed = response.status_code == 201
    print_test("POST /jobs - Create", passed, f"Status: {response.status_code}")
    
    if passed:
        job = response.json()
        print_test("Response has ID", 'id' in job)
        print_test("Title matches", job.get('title') == job_data['title'])
        print_test("Department matches", job.get('department') == job_data['department'])
        return job.get('id')
    
    return None


def test_update_job(job_id):
    """Test PUT /jobs/:id endpoint."""
    print_section(f"Testing PUT /jobs/{job_id}")
    
    update_data = {
        "title": "Updated Test Job",
        "status": "searching",
        "is_published": True
    }
    
    response = requests.put(
        f"{BASE_URL}/jobs/{job_id}",
        headers=get_headers(),
        json=update_data
    )
    
    passed = response.status_code == 200
    print_test("PUT /jobs/:id - Update", passed, f"Status: {response.status_code}")
    
    if passed:
        job = response.json()
        print_test("Title updated", job.get('title') == update_data['title'])
        print_test("Status updated", job.get('status') == update_data['status'])


def test_missions():
    """Test GET /missions endpoint."""
    print_section("Testing GET /missions")
    
    # Test basic endpoint
    response = requests.get(f"{BASE_URL}/missions", headers=get_headers())
    passed = response.status_code == 200
    print_test("GET /missions - Basic", passed)
    
    if passed:
        data = response.json()
        results = data.get('results', [])
        
        if results:
            mission = results[0]
            
            # Check status mapping
            status_value = mission.get('status')
            valid_statuses = ['unconfirmed', 'in_progress', 'completed', 'cancelled']
            print_test("Status mapping", status_value in valid_statuses,
                      f"Status: {status_value}")
            
            # Check required fields
            required_fields = [
                'id', 'job_id', 'job_title', 'company_name', 'department',
                'start_date', 'end_date', 'location', 'recruiter_name',
                'candidate_name', 'candidate_rating', 'recruiter_rating',
                'candidate_feedback', 'recruiter_feedback', 'status', 'team'
            ]
            
            missing = [f for f in required_fields if f not in mission]
            print_test("All required fields", len(missing) == 0,
                      f"Missing: {missing}" if missing else "All present")
    
    # Test with filters
    response = requests.get(
        f"{BASE_URL}/missions?status=in_progress&max_duration=30d",
        headers=get_headers()
    )
    print_test("GET /missions - With filters", response.status_code == 200)


def test_applications():
    """Test GET /applications endpoint."""
    print_section("Testing GET /applications")
    
    # Test basic endpoint
    response = requests.get(f"{BASE_URL}/applications", headers=get_headers())
    passed = response.status_code == 200
    print_test("GET /applications - Basic", passed)
    
    if passed:
        data = response.json()
        results = data.get('results', [])
        
        if results:
            app = results[0]
            
            # Check status mapping
            status_value = app.get('status')
            valid_statuses = ['pending', 'accepted', 'rejected']
            print_test("Status mapping", status_value in valid_statuses,
                      f"Status: {status_value}")
            
            # Check required fields
            required_fields = [
                'id', 'job_id', 'job_title', 'company_name', 'department',
                'logo_asset', 'status', 'applied_at', 'location',
                'contract_type', 'schedule_label', 'interview_date',
                'candidate_name', 'candidate_avatar', 'candidate_domain',
                'candidate_rating', 'motivation_letter'
            ]
            
            missing = [f for f in required_fields if f not in app]
            print_test("All required fields", len(missing) == 0,
                      f"Missing: {missing}" if missing else "All present")
            
            # Check applied_at is datetime (has time component)
            applied_at = app.get('applied_at', '')
            has_time = 'T' in applied_at or ' ' in applied_at
            print_test("applied_at is datetime", has_time,
                      f"Value: {applied_at}")
    
    # Test with filters
    response = requests.get(
        f"{BASE_URL}/applications?status=pending&applied_within=7d",
        headers=get_headers()
    )
    print_test("GET /applications - With filters", response.status_code == 200)


def test_interviews():
    """Test GET /interviews endpoint."""
    print_section("Testing GET /interviews")
    
    # Test basic endpoint
    response = requests.get(f"{BASE_URL}/interviews", headers=get_headers())
    passed = response.status_code == 200
    print_test("GET /interviews - Basic", passed)
    
    if passed:
        interviews = response.json()
        
        if interviews:
            interview = interviews[0]
            
            # Check required fields
            required_fields = [
                'id', 'candidate_id', 'candidate_name', 'candidate_avatar',
                'job_id', 'job_title', 'department', 'scheduled_date',
                'status', 'notes'
            ]
            
            missing = [f for f in required_fields if f not in interview]
            print_test("All required fields", len(missing) == 0,
                      f"Missing: {missing}" if missing else "All present")
            
            # Check no camelCase
            camel_case = [k for k in interview.keys() if any(c.isupper() for c in k)]
            print_test("No camelCase fields", len(camel_case) == 0,
                      f"Found: {camel_case}" if camel_case else "All snake_case")
    
    # Test with filters
    response = requests.get(
        f"{BASE_URL}/interviews?upcoming=true&status=scheduled",
        headers=get_headers()
    )
    print_test("GET /interviews - With filters", response.status_code == 200)


def test_job_candidates():
    """Test GET /jobs/:jobId/candidates endpoint."""
    print_section("Testing GET /jobs/:jobId/candidates")
    
    # First get a job ID
    response = requests.get(f"{BASE_URL}/jobs/mine", headers=get_headers())
    if response.status_code == 200:
        results = response.json().get('results', [])
        if results:
            job_id = results[0]['id']
            
            # Test candidates endpoint
            response = requests.get(
                f"{BASE_URL}/jobs/{job_id}/candidates",
                headers=get_headers()
            )
            passed = response.status_code == 200
            print_test(f"GET /jobs/{job_id}/candidates", passed)
            
            if passed:
                data = response.json()
                results = data.get('results', [])
                
                if results:
                    candidate = results[0]
                    
                    # Check required fields (snake_case)
                    required_fields = [
                        'id', 'name', 'title', 'photo_url', 'rating',
                        'reviews_count', 'is_top_rated', 'cover_letter', 'status'
                    ]
                    
                    missing = [f for f in required_fields if f not in candidate]
                    print_test("All required fields", len(missing) == 0,
                              f"Missing: {missing}" if missing else "All present")
                    
                    # Check no camelCase
                    camel_case = [k for k in candidate.keys() if any(c.isupper() for c in k)]
                    print_test("No camelCase fields", len(camel_case) == 0,
                              f"Found: {camel_case}" if camel_case else "All snake_case")
            
            # Test with filters
            response = requests.get(
                f"{BASE_URL}/jobs/{job_id}/candidates?status=nouveau&sort=best",
                headers=get_headers()
            )
            print_test("GET /jobs/:id/candidates - With filters", response.status_code == 200)


def main():
    """Run all tests."""
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}Recruiter API Endpoint Tests{RESET}")
    print(f"{BLUE}{'='*60}{RESET}\n")
    
    # Login first
    if not login_as_recruiter():
        print(f"\n{RED}Failed to login. Cannot continue tests.{RESET}")
        print(f"{YELLOW}Make sure the server is running and you have a recruiter account.{RESET}")
        return
    
    # Run tests
    test_jobs_mine()
    test_jobs_detail()
    
    # Create and update job
    job_id = test_create_job()
    if job_id:
        test_update_job(job_id)
    
    test_missions()
    test_applications()
    test_interviews()
    test_job_candidates()
    
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}Tests completed!{RESET}")
    print(f"{BLUE}{'='*60}{RESET}\n")
    
    print(f"{YELLOW}Note: Some tests may fail if there's no data in the database.{RESET}")
    print(f"{YELLOW}Create some test data first if needed.{RESET}\n")


if __name__ == "__main__":
    main()
