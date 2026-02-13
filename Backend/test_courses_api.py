# backend/test_courses_api.py
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'jansewa.settings')
django.setup()

from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken
from apps.users.models import User
from apps.municipalities.models import Municipality
from apps.providers.models import ProviderProfile
from apps.courses.models import Course, Enrollment
from django.utils import timezone
from datetime import timedelta

def run_tests():
    print("=" * 60)
    print("COURSES API VERIFICATION TEST")
    print("=" * 60)
    
    # Setup test data
    print("\n[SETUP] Creating test data...")
    muni, _ = Municipality.objects.get_or_create(
        name="Test Municipality",
        defaults={"province": "Bagmati", "district": "Kathmandu"}
    )
    
    # Create Municipality Admin
    admin_phone = "9800000001"
    admin, _ = User.objects.get_or_create(phone=admin_phone, defaults={
        "name": "Test Admin",
        "role": "municipality_admin",
        "municipality": muni
    })
    
    # Create Provider
    provider_phone = "9800000002"
    provider, _ = User.objects.get_or_create(phone=provider_phone, defaults={
        "name": "Test Provider",
        "role": "provider",
        "municipality": muni
    })
    
    if not hasattr(provider, 'provider_profile'):
        ProviderProfile.objects.create(
            user=provider,
            municipality_verified=True,
            skill_categories=['plumber'],
            experience_years=5
        )
    
    # Create Citizen
    citizen_phone = "9800000003"
    citizen, _ = User.objects.get_or_create(phone=citizen_phone, defaults={
        "name": "Test Citizen",
        "role": "citizen",
        "municipality": muni
    })
    
    print(f"✓ Created Admin: {admin.phone}")
    print(f"✓ Created Provider: {provider.phone}")
    print(f"✓ Created Citizen: {citizen.phone}")
    
    # Test 1: Municipality Admin Creates Course
    print("\n" + "=" * 60)
    print("[TEST 1] Municipality Admin Creates Course")
    print("=" * 60)
    
    admin_client = APIClient()
    admin_client.force_authenticate(user=admin)
    
    course_data = {
        "title": "Advanced Plumbing Training",
        "description": "Learn advanced plumbing techniques",
        "municipality": muni.id,
        "start_date": (timezone.now().date() + timedelta(days=7)).isoformat(),
        "end_date": (timezone.now().date() + timedelta(days=14)).isoformat(),
        "capacity": 20,
        "status": "open"
    }
    
    response = admin_client.post('/api/v1/courses/', course_data, format='json')
    print(f"Status: {response.status_code}")
    
    if response.status_code == 201:
        print("✓ Course created successfully")
        course_id = response.data['id']
        print(f"  Course ID: {course_id}")
        print(f"  Title: {response.data['title']}")
    else:
        print(f"✗ Failed: {response.content}")
        return
    
    # Test 2: Citizen Attempts to Create Course (Should Fail)
    print("\n" + "=" * 60)
    print("[TEST 2] Citizen Attempts to Create Course (Should Fail 403)")
    print("=" * 60)
    
    citizen_client = APIClient()
    citizen_client.force_authenticate(user=citizen)
    
    response = citizen_client.post('/api/v1/courses/', course_data, format='json')
    print(f"Status: {response.status_code}")
    
    if response.status_code == 403:
        print("✓ Correctly denied (403 Forbidden)")
    else:
        print(f"✗ Expected 403, got {response.status_code}")
    
    # Test 3: Provider Lists Courses
    print("\n" + "=" * 60)
    print("[TEST 3] Provider Lists Available Courses")
    print("=" * 60)
    
    provider_client = APIClient()
    provider_client.force_authenticate(user=provider)
    
    response = provider_client.get('/api/v1/courses/?status=open')
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        print(f"✓ Found {len(response.data)} courses")
        if len(response.data) > 0:
            print(f"  First course: {response.data[0]['title']}")
    else:
        print(f"✗ Failed: {response.content}")
    
    # Test 4: Provider Enrolls in Course
    print("\n" + "=" * 60)
    print("[TEST 4] Provider Enrolls in Course")
    print("=" * 60)
    
    enrollment_data = {
        "course": course_id,
        "notes": "I am interested in improving my plumbing skills"
    }
    
    response = provider_client.post('/api/v1/enrollments/', enrollment_data, format='json')
    print(f"Status: {response.status_code}")
    
    if response.status_code == 201:
        print("✓ Enrollment created successfully")
        enrollment_id = response.data['id']
        print(f"  Enrollment ID: {enrollment_id}")
        print(f"  Status: {response.data['status']}")
    else:
        print(f"✗ Failed: {response.content}")
        return
    
    # Test 5: Citizen Attempts to Enroll (Should Fail)
    print("\n" + "=" * 60)
    print("[TEST 5] Citizen Attempts to Enroll (Should Fail 403)")
    print("=" * 60)
    
    response = citizen_client.post('/api/v1/enrollments/', enrollment_data, format='json')
    print(f"Status: {response.status_code}")
    
    if response.status_code == 403:
        print("✓ Correctly denied (403 Forbidden)")
    else:
        print(f"✗ Expected 403, got {response.status_code}")
    
    # Test 6: Provider Views Their Enrollments
    print("\n" + "=" * 60)
    print("[TEST 6] Provider Views Their Enrollments")
    print("=" * 60)
    
    response = provider_client.get('/api/v1/enrollments/')
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        print(f"✓ Found {len(response.data)} enrollments")
        if len(response.data) > 0:
            print(f"  Course: {response.data[0]['course_detail']['title']}")
            print(f"  Status: {response.data[0]['status']}")
    else:
        print(f"✗ Failed: {response.content}")
    
    # Test 7: Admin Views Enrollments for Their Courses
    print("\n" + "=" * 60)
    print("[TEST 7] Admin Views Enrollments for Their Courses")
    print("=" * 60)
    
    response = admin_client.get(f'/api/v1/enrollments/?course={course_id}')
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        print(f"✓ Found {len(response.data)} enrollments")
        if len(response.data) > 0:
            print(f"  Provider: {response.data[0]['provider_detail']['name']}")
            print(f"  Status: {response.data[0]['status']}")
    else:
        print(f"✗ Failed: {response.content}")
    
    # Test 8: Admin Updates Enrollment Status
    print("\n" + "=" * 60)
    print("[TEST 8] Admin Approves Enrollment")
    print("=" * 60)
    
    update_data = {
        "status": "approved",
        "admin_notes": "Approved - meets requirements"
    }
    
    response = admin_client.patch(f'/api/v1/enrollments/{enrollment_id}/', update_data, format='json')
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        print("✓ Enrollment approved successfully")
        print(f"  New Status: {response.data['status']}")
    else:
        print(f"✗ Failed: {response.content}")
    
    print("\n" + "=" * 60)
    print("ALL TESTS COMPLETED")
    print("=" * 60)

if __name__ == '__main__':
    run_tests()
