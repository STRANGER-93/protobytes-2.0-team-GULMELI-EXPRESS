# backend/apps/users/tests.py
from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from .models import User
from apps.municipalities.models import Municipality


class UserModelTest(TestCase):
    """Test User model"""
    
    def setUp(self):
        self.municipality = Municipality.objects.create(
            name="Kathmandu Metropolitan",
            district="Kathmandu",
            province="Bagmati"
        )
    
    def test_create_user(self):
        """Test creating a regular user"""
        user = User.objects.create_user(
            phone='9841234567',
            name='Test User',
            municipality=self.municipality,
            role='citizen'
        )
        self.assertEqual(user.phone, '9841234567')
        self.assertEqual(user.name, 'Test User')
        self.assertEqual(user.role, 'citizen')
        self.assertTrue(user.is_active)
        self.assertFalse(user.is_staff)
    
    def test_create_superuser(self):
        """Test creating a superuser"""
        admin = User.objects.create_superuser(
            phone='9841111111',
            name='Admin User',
            municipality=self.municipality,
            password='admin123'
        )
        self.assertTrue(admin.is_staff)
        self.assertTrue(admin.is_superuser)
        self.assertEqual(admin.role, 'municipality_admin')


class AuthAPITest(APITestCase):
    """Test authentication endpoints"""
    
    def setUp(self):
        self.municipality = Municipality.objects.create(
            name="Kathmandu Metropolitan",
            district="Kathmandu",
            province="Bagmati"
        )
        self.send_otp_url = reverse('users:send-otp')
        self.verify_otp_url = reverse('users:verify-otp')
    
    def test_send_otp_success(self):
        """Test OTP send with valid phone"""
        data = {'phone': '9841234567'}
        response = self.client.post(self.send_otp_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('message', response.data)
    
    def test_send_otp_invalid_phone(self):
        """Test OTP send with invalid phone"""
        data = {'phone': '1234567890'}
        response = self.client.post(self.send_otp_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_verify_otp_new_user(self):
        """Test OTP verification for new user registration"""
        data = {
            'phone': '9841234567',
            'otp': '123456',
            'name': 'New User',
            'role': 'citizen',
            'municipality': self.municipality.id
        }
        response = self.client.post(self.verify_otp_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
        self.assertIn('user', response.data)
        
        # Verify user created
        user = User.objects.get(phone='9841234567')
        self.assertEqual(user.name, 'New User')
    
    def test_verify_otp_existing_user(self):
        """Test OTP verification for existing user login"""
        # Create user first
        user = User.objects.create_user(
            phone='9841234567',
            name='Existing User',
            municipality=self.municipality
        )
        
        data = {
            'phone': '9841234567',
            'otp': '123456'
        }
        response = self.client.post(self.verify_otp_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)