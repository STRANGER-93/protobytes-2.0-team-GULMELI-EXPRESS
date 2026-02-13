# backend/apps/reviews/tests.py
from django.test import TestCase
from django.utils import timezone
from datetime import timedelta
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse

from apps.users.models import User
from apps.municipalities.models import Municipality
from apps.providers.models import ProviderProfile
from apps.bookings.models import Booking
from .models import Review


class ReviewModelTest(TestCase):
    """Test Review model"""
    
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
        
        self.booking = Booking.objects.create(
            citizen=self.citizen,
            provider=self.provider_user,
            municipality=self.municipality,
            skill_category='electrician',
            scheduled_time=timezone.now() + timedelta(days=1),
            description='Test',
            location_address='Test',
            amount=1000.00,
            status='completed',
            completed_at=timezone.now()
        )
    
    def test_create_review(self):
        """Test creating a review"""
        review = Review.objects.create(
            booking=self.booking,
            provider=self.provider_user,
            reviewer=self.citizen,
            rating=5,
            comment='Excellent service'
        )
        
        self.assertEqual(review.rating, 5)
        self.assertEqual(review.provider, self.provider_user)
        
        # Check provider rating updated
        self.provider_profile.refresh_from_db()
        self.assertEqual(self.provider_profile.avg_rating, 5.00)