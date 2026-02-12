# backend/apps/bookings/tests.py
from django.test import TestCase
from django.utils import timezone
from datetime import timedelta
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse

from apps.users.models import User
from apps.municipalities.models import Municipality
from apps.providers.models import ProviderProfile
from .models import Booking


class BookingModelTest(TestCase):
    """Test Booking model"""
    
    def setUp(self):
        self.municipality = Municipality.objects.create(
            name="Kathmandu",
            district="Kathmandu",
            province="Bagmati"
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
    
    def test_create_booking(self):
        """Test creating a booking"""
        booking = Booking.objects.create(
            citizen=self.citizen,
            provider=self.provider_user,
            municipality=self.municipality,
            skill_category='electrician',
            scheduled_time=timezone.now() + timedelta(days=1),
            description='Fix electrical issue',
            location_address='Test Address',
            amount=1000.00
        )
        
        self.assertEqual(booking.status, 'pending')
        self.assertEqual(booking.payment_status, 'pending')
        self.assertEqual(booking.municipality, self.municipality)


class BookingAPITest(APITestCase):
    """Test booking API endpoints"""
    
    def setUp(self):
        self.municipality = Municipality.objects.create(
            name="Kathmandu",
            district="Kathmandu",
            province="Bagmati"
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
        
        self.create_url = reverse('bookings:create')
        self.list_url = reverse('bookings:list')
    
    def test_citizen_create_booking(self):
        """Test citizen can create booking"""
        self.client.force_authenticate(user=self.citizen)
        
        data = {
            'provider': self.provider_user.id,
            'skill_category': 'electrician',
            'scheduled_time': (timezone.now() + timedelta(days=1)).isoformat(),
            'description': 'Need electrical work',
            'location_address': '123 Test Street',
            'amount': '1500.00'
        }
        
        response = self.client.post(self.create_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verify booking created
        booking = Booking.objects.get(id=response.data['id'])
        self.assertEqual(booking.citizen, self.citizen)
        self.assertEqual(booking.provider, self.provider_user)
        self.assertEqual(booking.municipality, self.municipality)
    
    def test_provider_cannot_create_booking(self):
        """Test provider cannot create booking"""
        self.client.force_authenticate(user=self.provider_user)
        
        data = {
            'provider': self.provider_user.id,
            'skill_category': 'electrician',
            'scheduled_time': (timezone.now() + timedelta(days=1)).isoformat(),
            'description': 'Test',
            'location_address': 'Test',
            'amount': '1000.00'
        }
        
        response = self.client.post(self.create_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)