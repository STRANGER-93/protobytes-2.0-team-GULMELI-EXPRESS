# backend/apps/providers/tests.py
from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from apps.users.models import User
from apps.municipalities.models import Municipality
from .models import ProviderProfile


class ProviderProfileModelTest(TestCase):
    """Test ProviderProfile model"""
    
    def setUp(self):
        self.municipality = Municipality.objects.create(
            name="Kathmandu Metropolitan",
            district="Kathmandu",
            province="Bagmati"
        )
        self.provider_user = User.objects.create_user(
            phone='9841234567',
            name='Test Provider',
            municipality=self.municipality,
            role='provider'
        )
    
    def test_create_provider_profile(self):
        """Test creating a provider profile"""
        profile = ProviderProfile.objects.create(
            user=self.provider_user,
            skill_categories=['electrician', 'plumber'],
            bio='Experienced provider',
            experience_years=5,
            citizenship_photo='citizenship/test.jpg'
        )
        self.assertEqual(profile.user, self.provider_user)
        self.assertEqual(len(profile.skill_categories), 2)
        self.assertEqual(profile.trust_score, 0)  # Not verified yet
    
    def test_trust_score_calculation(self):
        """Test trust score calculation"""
        profile = ProviderProfile.objects.create(
            user=self.provider_user,
            skill_categories=['electrician'],
            citizenship_photo='citizenship/test.jpg',
            municipality_verified=True,
            ctevt_status='certified',
            avg_rating=4.5,
            jobs_completed=15
        )
        # 40 (verified) + 30 (ctevt) + 20 (rating) + 10 (jobs) = 100
        self.assertEqual(profile.trust_score, 100)


class ProviderAPITest(APITestCase):
    """Test provider API endpoints"""
    
    def setUp(self):
        self.municipality = Municipality.objects.create(
            name="Kathmandu Metropolitan",
            district="Kathmandu",
            province="Bagmati"
        )
        
        # Create provider user
        self.provider_user = User.objects.create_user(
            phone='9841234567',
            name='Test Provider',
            municipality=self.municipality,
            role='provider'
        )
        
        # Create citizen user
        self.citizen_user = User.objects.create_user(
            phone='9849999999',
            name='Test Citizen',
            municipality=self.municipality,
            role='citizen'
        )
        
        # Create admin user
        self.admin_user = User.objects.create_user(
            phone='9841111111',
            name='Test Admin',
            municipality=self.municipality,
            role='municipality_admin'
        )
        
        self.register_url = reverse('providers:register')
    
    def test_provider_registration(self):
        """Test provider can register profile"""
        self.client.force_authenticate(user=self.provider_user)
        
        data = {
            'skill_categories': ['electrician', 'plumber'],
            'bio': 'Experienced service provider',
            'experience_years': 5,
            'citizenship_photo': 'citizenship/test.jpg',
            'ctevt_status': 'pending'
        }
        
        response = self.client.post(self.register_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verify profile created
        profile = ProviderProfile.objects.get(user=self.provider_user)
        self.assertEqual(len(profile.skill_categories), 2)
        self.assertFalse(profile.municipality_verified)
    
    def test_citizen_cannot_register_provider(self):
        """Test citizen cannot create provider profile"""
        self.client.force_authenticate(user=self.citizen_user)
        
        data = {
            'skill_categories': ['electrician'],
            'bio': 'Test',
            'citizenship_photo': 'citizenship/test.jpg'
        }
        
        response = self.client.post(self.register_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_search_providers(self):
        """Test provider search"""
        # Create provider profile
        ProviderProfile.objects.create(
            user=self.provider_user,
            skill_categories=['electrician'],
            bio='Test provider',
            citizenship_photo='citizenship/test.jpg',
            municipality_verified=True
        )
        
        self.client.force_authenticate(user=self.citizen_user)
        
        search_url = reverse('providers:search')
        response = self.client.get(search_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
    
    def test_admin_can_verify_provider(self):
        """Test municipality admin can verify provider"""
        # Create provider profile
        profile = ProviderProfile.objects.create(
            user=self.provider_user,
            skill_categories=['electrician'],
            citizenship_photo='citizenship/test.jpg'
        )
        
        self.client.force_authenticate(user=self.admin_user)
        
        verify_url = reverse('providers:verify', kwargs={'pk': profile.id})
        data = {
            'municipality_verified': True,
            'verification_notes': 'Verified citizenship and skills'
        }
        
        response = self.client.patch(verify_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify profile updated
        profile.refresh_from_db()
        self.assertTrue(profile.municipality_verified)
        self.assertEqual(profile.verified_by, self.admin_user)