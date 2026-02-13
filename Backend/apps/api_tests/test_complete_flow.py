# backend/apps/api_tests/test_complete_flow.py
"""
Complete end-to-end API tests for JanSewa MVP
Tests the full circular economy loop
"""
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from django.urls import reverse
from django.utils import timezone
from datetime import timedelta

from apps.users.models import User
from apps.municipalities.models import Municipality
from apps.providers.models import ProviderProfile
from apps.bookings.models import Booking
from apps.reviews.models import Review


class JanSewaCompleteFlowTest(APITestCase):
    """Test complete user journey through JanSewa system"""
    
    def setUp(self):
        """Set up test data"""
        # Create municipality
        self.municipality = Municipality.objects.create(
            name="Kathmandu Metropolitan",
            district="Kathmandu",
            province="Bagmati"
        )
        
        self.client = APIClient()
    
    def test_01_municipality_listing(self):
        """Test 01: Public can view municipalities"""
        print("\n[TEST 01] Testing municipality listing...")
        
        url = reverse('municipalities:list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreater(len(response.data), 0)
        self.assertEqual(response.data[0]['name'], "Kathmandu Metropolitan")
        print("✓ Municipality listing works")
    
    def test_02_citizen_registration_flow(self):
        """Test 02: Citizen registration with OTP"""
        print("\n[TEST 02] Testing citizen registration...")
        
        # Step 1: Send OTP
        send_otp_url = reverse('users:send-otp')
        response = self.client.post(send_otp_url, {
            'phone': '9841234567'
        })
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('message', response.data)
        print("✓ OTP sent successfully")
        
        # Step 2: Verify OTP and register
        verify_otp_url = reverse('users:verify-otp')
        response = self.client.post(verify_otp_url, {
            'phone': '9841234567',
            'otp': '123456',
            'name': 'Test Citizen',
            'role': 'citizen',
            'municipality': self.municipality.id
        })
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
        self.assertIn('user', response.data)
        self.assertEqual(response.data['user']['name'], 'Test Citizen')
        print("✓ Citizen registered and tokens received")
        
        # Save tokens for later tests
        self.citizen_token = response.data['access']
        self.citizen_user_id = response.data['user']['id']
        
        return response.data['access']
    
    def test_03_provider_registration_and_onboarding(self):
        """Test 03: Provider registration and profile creation"""
        print("\n[TEST 03] Testing provider registration and onboarding...")
        
        # Register provider user
        verify_otp_url = reverse('users:verify-otp')
        response = self.client.post(verify_otp_url, {
            'phone': '9842222222',
            'otp': '123456',
            'name': 'Test Provider',
            'role': 'provider',
            'municipality': self.municipality.id
        })
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        provider_token = response.data['access']
        print("✓ Provider user registered")
        
        # Create provider profile
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {provider_token}')
        
        register_url = reverse('providers:register')
        
        # Create mock files
        import io
        from PIL import Image
        
        citizenship_image = io.BytesIO()
        Image.new('RGB', (100, 100), color='red').save(citizenship_image, 'JPEG')
        citizenship_image.seek(0)
        citizenship_image.name = 'citizenship.jpg'
        
        response = self.client.post(register_url, {
            'skill_categories': '["electrician", "plumber"]',
            'bio': 'Experienced electrician with 5 years of work',
            'experience_years': 5,
            'citizenship_photo': citizenship_image,
            'ctevt_status': 'pending'
        }, format='multipart')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(len(response.data['skill_categories']), 2)
        self.assertFalse(response.data['municipality_verified'])
        print("✓ Provider profile created")
        
        self.provider_token = provider_token
        self.provider_id = response.data['id']
        self.provider_user_id = response.data['user']
        
        return provider_token, response.data['id']
    
    def test_04_municipality_admin_verification(self):
        """Test 04: Municipality admin verifies provider"""
        print("\n[TEST 04] Testing municipality admin verification...")
        
        # Create admin user
        verify_otp_url = reverse('users:verify-otp')
        response = self.client.post(verify_otp_url, {
            'phone': '9840000000',
            'otp': '123456',
            'name': 'Municipal Admin',
            'role': 'municipality_admin',
            'municipality': self.municipality.id
        })
        
        admin_token = response.data['access']
        print("✓ Admin user created")
        
        # Create provider first
        provider_token, provider_id = self.test_03_provider_registration_and_onboarding()
        
        # Admin verifies provider
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {admin_token}')
        verify_url = reverse('providers:verify', kwargs={'pk': provider_id})
        
        response = self.client.patch(verify_url, {
            'municipality_verified': True,
            'verification_notes': 'All documents verified',
            'ctevt_status': 'certified'
        })
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['municipality_verified'])
        self.assertEqual(response.data['ctevt_status'], 'certified')
        print("✓ Provider verified by admin")
        
        self.admin_token = admin_token
        
        return admin_token, provider_id
    
    def test_05_provider_search(self):
        """Test 05: Citizen searches for verified providers"""
        print("\n[TEST 05] Testing provider search...")
        
        # Setup: Create verified provider
        admin_token, provider_id = self.test_04_municipality_admin_verification()
        
        # Citizen searches for providers
        citizen_token = self.test_02_citizen_registration_flow()
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {citizen_token}')
        
        search_url = reverse('providers:search')
        
        # Test 1: Search all
        response = self.client.get(search_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreater(len(response.data['results']), 0)
        print("✓ Basic search works")
        
        # Test 2: Search by skill
        response = self.client.get(f'{search_url}?skill=electrician')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        print("✓ Skill filter works")
        
        # Test 3: Verified only
        response = self.client.get(f'{search_url}?verified_only=true')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        for provider in response.data['results']:
            self.assertTrue(provider['municipality_verified'])
        print("✓ Verified filter works")
        
        return provider_id
    
    def test_06_booking_creation_and_payment(self):
        """Test 06: Citizen creates booking and completes payment"""
        print("\n[TEST 06] Testing booking creation and payment...")
        
        # Setup
        provider_id = self.test_05_provider_search()
        citizen_token = self.test_02_citizen_registration_flow()
        
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {citizen_token}')
        
        # Create booking
        create_url = reverse('bookings:create')
        scheduled_time = (timezone.now() + timedelta(days=2)).isoformat()
        
        response = self.client.post(create_url, {
            'provider': self.provider_user_id,
            'skill_category': 'electrician',
            'scheduled_time': scheduled_time,
            'description': 'Fix electrical wiring',
            'location_address': 'House #123, Ward 5',
            'amount': '1500.00'
        })
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['status'], 'pending')
        booking_id = response.data['id']
        print("✓ Booking created")
        
        # Initiate payment
        payment_url = reverse('payments:initiate')
        response = self.client.post(payment_url, {
            'booking_id': booking_id
        })
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('reference_id', response.data)
        reference_id = response.data['reference_id']
        print("✓ Payment initiated")
        
        # Simulate payment callback (success)
        callback_url = reverse('payments:callback')
        response = self.client.get(f'{callback_url}?reference={reference_id}&status=success')
        
        # Check booking updated
        booking = Booking.objects.get(id=booking_id)
        self.assertEqual(booking.status, 'confirmed')
        self.assertEqual(booking.payment_status, 'success')
        print("✓ Payment completed, booking confirmed")
        
        return booking_id
    
    def test_07_provider_completes_job(self):
        """Test 07: Provider marks booking as completed"""
        print("\n[TEST 07] Testing job completion...")
        
        # Setup
        booking_id = self.test_06_booking_creation_and_payment()
        provider_token, _ = self.test_03_provider_registration_and_onboarding()
        
        # Get initial earnings
        provider_profile = ProviderProfile.objects.get(user_id=self.provider_user_id)
        initial_earnings = provider_profile.total_earnings
        initial_jobs = provider_profile.jobs_completed
        
        # Provider completes booking
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {provider_token}')
        complete_url = reverse('bookings:complete', kwargs={'pk': booking_id})
        
        response = self.client.patch(complete_url, {
            'completion_notes': 'Work completed successfully'
        })
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'completed')
        print("✓ Booking marked as completed")
        
        # Check earnings updated
        provider_profile.refresh_from_db()
        self.assertGreater(provider_profile.total_earnings, initial_earnings)
        self.assertEqual(provider_profile.jobs_completed, initial_jobs + 1)
        print(f"✓ Earnings updated: NPR {provider_profile.total_earnings}")
        
        return booking_id
    
    def test_08_citizen_submits_review(self):
        """Test 08: Citizen reviews completed booking"""
        print("\n[TEST 08] Testing review submission...")
        
        # Setup
        booking_id = self.test_07_provider_completes_job()
        citizen_token = self.test_02_citizen_registration_flow()
        
        # Get initial rating
        provider_profile = ProviderProfile.objects.get(user_id=self.provider_user_id)
        initial_rating = provider_profile.avg_rating
        
        # Submit review
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {citizen_token}')
        review_url = reverse('reviews:create')
        
        response = self.client.post(review_url, {
            'booking': booking_id,
            'rating': 5,
            'comment': 'Excellent work! Very professional.'
        })
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['rating'], 5)
        print("✓ Review submitted")
        
        # Check provider rating updated
        provider_profile.refresh_from_db()
        self.assertGreater(provider_profile.avg_rating, initial_rating)
        print(f"✓ Provider rating updated: {provider_profile.avg_rating}")
    
    def test_09_provider_dashboard(self):
        """Test 09: Provider views dashboard"""
        print("\n[TEST 09] Testing provider dashboard...")
        
        # Setup - need completed booking
        self.test_07_provider_completes_job()
        provider_token, _ = self.test_03_provider_registration_and_onboarding()
        
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {provider_token}')
        dashboard_url = reverse('governance:provider-dashboard')
        
        response = self.client.get(dashboard_url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('stats', response.data)
        self.assertIn('total_earnings', response.data['stats'])
        self.assertIn('jobs_completed', response.data['stats'])
        self.assertIn('monthly_earnings', response.data)
        print("✓ Provider dashboard loaded")
        print(f"  - Earnings: NPR {response.data['stats']['total_earnings']}")
        print(f"  - Jobs: {response.data['stats']['jobs_completed']}")
    
    def test_10_municipal_dashboard(self):
        """Test 10: Municipal admin views dashboard"""
        print("\n[TEST 10] Testing municipal dashboard...")
        
        # Setup - need completed booking and verified provider
        self.test_07_provider_completes_job()
        admin_token, _ = self.test_04_municipality_admin_verification()
        
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {admin_token}')
        dashboard_url = reverse('governance:municipal-dashboard')
        
        response = self.client.get(dashboard_url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('providers', response.data)
        self.assertIn('bookings', response.data)
        self.assertIn('earnings', response.data)
        self.assertIn('top_skills', response.data)
        
        print("✓ Municipal dashboard loaded")
        print(f"  - Verified providers: {response.data['providers']['verified']}")
        print(f"  - Completed bookings: {response.data['bookings']['completed']}")
        print(f"  - Local earnings: {response.data['earnings']['formatted']}")
    
    def test_11_circular_loop_validation(self):
        """Test 11: Validate complete circular economy loop"""
        print("\n[TEST 11] Validating circular economy loop...")
        
        # Run complete flow
        self.test_10_municipal_dashboard()
        
        # Verify loop metrics
        provider = ProviderProfile.objects.get(user_id=self.provider_user_id)
        bookings = Booking.objects.filter(municipality=self.municipality)
        
        print("\n✓ CIRCULAR LOOP VALIDATION:")
        print(f"  1. Skill Layer: Provider has {len(provider.skill_categories)} skills")
        print(f"  2. Trust Layer: Municipality verified = {provider.municipality_verified}")
        print(f"  3. Market Layer: {bookings.filter(status='completed').count()} completed bookings")
        print(f"  4. Governance Layer: NPR {provider.total_earnings} retained locally")
        print(f"  5. Feedback Loop: Avg rating = {provider.avg_rating}")
        
        # Assert loop is working
        self.assertTrue(provider.municipality_verified, "Trust layer not working")
        self.assertGreater(provider.jobs_completed, 0, "Market layer not working")
        self.assertGreater(provider.total_earnings, 0, "Earnings not tracked")
        
        print("\n✓✓✓ CIRCULAR ECONOMY LOOP COMPLETE! ✓✓✓")


class AuthenticationAPITest(APITestCase):
    """Detailed authentication tests"""
    
    def setUp(self):
        self.municipality = Municipality.objects.create(
            name="Test City",
            district="Test District",
            province="Test Province"
        )
    
    def test_send_otp_valid_phone(self):
        """Test OTP send with valid phone"""
        url = reverse('users:send-otp')
        response = self.client.post(url, {'phone': '9841234567'})
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('message', response.data)
    
    def test_send_otp_invalid_phone(self):
        """Test OTP send with invalid phone"""
        url = reverse('users:send-otp')
        response = self.client.post(url, {'phone': '1234567890'})
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_verify_otp_new_user_missing_data(self):
        """Test OTP verify for new user without required fields"""
        url = reverse('users:verify-otp')
        response = self.client.post(url, {
            'phone': '9841234567',
            'otp': '123456'
        })
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_token_refresh(self):
        """Test JWT token refresh"""
        # Register user and get tokens
        verify_url = reverse('users:verify-otp')
        response = self.client.post(verify_url, {
            'phone': '9841234567',
            'otp': '123456',
            'name': 'Test User',
            'role': 'citizen',
            'municipality': self.municipality.id
        })
        
        refresh_token = response.data['refresh']
        
        # Refresh token
        refresh_url = reverse('users:token-refresh')
        response = self.client.post(refresh_url, {
            'refresh': refresh_token
        })
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)


class ProviderAPITest(APITestCase):
    """Provider-specific API tests"""
    
    def setUp(self):
        self.municipality = Municipality.objects.create(
            name="Test City",
            district="Test District",
            province="Test Province"
        )
        
        self.provider_user = User.objects.create_user(
            phone='9842222222',
            name='Test Provider',
            municipality=self.municipality,
            role='provider'
        )
        
        self.citizen_user = User.objects.create_user(
            phone='9841111111',
            name='Test Citizen',
            municipality=self.municipality,
            role='citizen'
        )
    
    def test_citizen_cannot_create_provider_profile(self):
        """Test that citizens cannot create provider profiles"""
        self.client.force_authenticate(user=self.citizen_user)
        
        url = reverse('providers:register')
        response = self.client.post(url, {
            'skill_categories': '["electrician"]',
            'bio': 'Test',
            'experience_years': 5,
            'ctevt_status': 'pending'
        })
        
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_provider_search_filters(self):
        """Test provider search filters work correctly"""
        # Create verified provider
        profile = ProviderProfile.objects.create(
            user=self.provider_user,
            skill_categories=['electrician'],
            bio='Test provider',
            citizenship_photo='citizenship/test.jpg',
            municipality_verified=True,
            avg_rating=4.5
        )
        
        self.client.force_authenticate(user=self.citizen_user)
        url = reverse('providers:search')
        
        # Test skill filter
        response = self.client.get(f'{url}?skill=electrician')
        self.assertEqual(len(response.data['results']), 1)
        
        # Test rating filter
        response = self.client.get(f'{url}?min_rating=4.0')
        self.assertEqual(len(response.data['results']), 1)
        
        # Test verified filter
        response = self.client.get(f'{url}?verified_only=true')
        self.assertEqual(len(response.data['results']), 1)


class BookingAPITest(APITestCase):
    """Booking-specific API tests"""
    
    def setUp(self):
        self.municipality = Municipality.objects.create(
            name="Test City",
            district="Test District",
            province="Test Province"
        )
        
        self.citizen = User.objects.create_user(
            phone='9841111111',
            name='Test Citizen',
            municipality=self.municipality,
            role='citizen'
        )
        
        self.provider_user = User.objects.create_user(
            phone='9842222222',
            name='Test Provider',
            municipality=self.municipality,
            role='provider'
        )
        
        self.provider_profile = ProviderProfile.objects.create(
            user=self.provider_user,
            skill_categories=['electrician'],
            citizenship_photo='citizenship/test.jpg',
            municipality_verified=True
        )
    
    def test_booking_validation_past_time(self):
        """Test booking with past scheduled time fails"""
        self.client.force_authenticate(user=self.citizen)
        
        url = reverse('bookings:create')
        past_time = (timezone.now() - timedelta(days=1)).isoformat()
        
        response = self.client.post(url, {
            'provider': self.provider_user.id,
            'skill_category': 'electrician',
            'scheduled_time': past_time,
            'description': 'Test',
            'location_address': 'Test',
            'amount': '1000.00'
        })
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_booking_requires_verified_provider(self):
        """Test booking requires verified provider"""
        # Create unverified provider
        unverified_provider = User.objects.create_user(
            phone='9843333333',
            name='Unverified Provider',
            municipality=self.municipality,
            role='provider'
        )
        
        ProviderProfile.objects.create(
            user=unverified_provider,
            skill_categories=['plumber'],
            citizenship_photo='citizenship/test2.jpg',
            municipality_verified=False
        )
        
        self.client.force_authenticate(user=self.citizen)
        url = reverse('bookings:create')
        
        response = self.client.post(url, {
            'provider': unverified_provider.id,
            'skill_category': 'plumber',
            'scheduled_time': (timezone.now() + timedelta(days=1)).isoformat(),
            'description': 'Test',
            'location_address': 'Test',
            'amount': '1000.00'
        })
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


# Run tests with: python manage.py test apps.api_tests