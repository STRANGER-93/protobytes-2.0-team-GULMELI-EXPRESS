import os
import django
import json
import re
import sys

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'jansewa.settings')
django.setup()

from django.conf import settings
settings.ALLOWED_HOSTS = ['testserver', 'localhost', '127.0.0.1']

from django.test import Client
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken
from apps.users.models import User
from apps.municipalities.models import Municipality
from apps.providers.models import ProviderProfile
from apps.bookings.models import Booking
from django.utils import timezone

def run_tests():
    print("Setting up test environment...")
    
    # 1. Create Municipality if needed
    muni, created = Municipality.objects.get_or_create(
        name="Test Municipality",
        defaults={
            "province": "Bagmati",
            "district": "Kathmandu"
        }
    )
    
    # 2. Create User
    phone = "9841234567"
    try:
        user = User.objects.get(phone=phone)
    except User.DoesNotExist:
        user = User.objects.create_user(
            phone=phone,
            name="Test User",
            municipality=muni,
            role="citizen",
            password="password123"
        )
    
    # 3. Generate Token
    refresh = RefreshToken.for_user(user)
    access_token = str(refresh.access_token)
    
    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
    
    # Create Provider User
    provider_phone = "9800000000"
    provider, _ = User.objects.get_or_create(phone=provider_phone, defaults={
        "name": "Test Provider",
        "role": "provider",
        "municipality": muni,
        "password": "password123"
    })
    
    # Create Provider Profile
    if not hasattr(provider, 'provider_profile'):
        ProviderProfile.objects.create(
            user=provider,
            municipality_verified=True,
            skill_categories=['plumber'],
            experience_years=5
        )
    else:
        # Ensure verified
        profile = provider.provider_profile
        profile.municipality_verified = True
        profile.save()

    print(f"Created Provider: {provider.phone}")

    print("\n--- Testing Booking Flow ---")
    
    # 1. Create Booking
    print("1. Creating Booking...")
    # Use the client authenticated as the citizen user
    client.force_authenticate(user=user)
    
    create_data = {
        "provider": provider.id,
        "skill_category": "plumber", # Must match provider skill
        "scheduled_time": (timezone.now() + timezone.timedelta(days=1)).isoformat(),
        "description": "Fix leaking tap",
        "location_address": "Kathmandu, Nepal",
        "amount": 500
    }
    
    response = client.post('/api/v1/bookings/create/', create_data, format='json')
    print(f"Create Status: {response.status_code}")
    if response.status_code >= 400:
        print(f"Create Error: {response.content}")
    else:
        booking_id = response.data['id']
        print(f"Booking ID: {booking_id}")
        
        # 2. Initiate Payment
        print("2. Initiating Payment...")
        pay_data = {"booking_id": booking_id}
        pay_resp = client.post('/api/v1/payments/mock/initiate/', pay_data, format='json')
        print(f"Init Payment Status: {pay_resp.status_code}")
        
        if pay_resp.status_code == 200:
            payment_ref = pay_resp.data['reference_id']
            print(f"Payment Ref: {payment_ref}")
            
            # 3. Callback (Success)
            print("3. Payment Callback...")
            # Callback is AllowAny, verify status update
            call_resp = client.get(f'/api/v1/payments/mock/callback/?reference={payment_ref}&status=success')
            print(f"Callback Status: {call_resp.status_code}") # Should be 302 redirect
            
            # Refresh booking check
            booking = Booking.objects.get(id=booking_id)
            print(f"Booking Status after payment: {booking.status}") # Should be confirmed!
            print(f"Payment Status: {booking.payment_status}")
            
            # 4. Provider Confirm (Optional check)
            print("4. Provider Confirm (as Provider)...")
            client.force_authenticate(user=provider)
            conf_resp = client.patch(f'/api/v1/bookings/{booking_id}/confirm/')
            print(f"Confirm Status: {conf_resp.status_code}")
            if conf_resp.status_code >= 400:
                print(f"Confirm Error: {conf_resp.content}")
            else:
                print("Booking Confirmed by Provider API (Redundant but tested)")

    print("\n--- End Booking Flow ---\n")

    # Re-authenticate client as the original user for general API tests
    client.force_authenticate(user=user)

    # 4. Read URLs
    endpoints = []
    try:
        with open('urls.txt', 'r', encoding='utf-16le') as f:
            for line in f:
                parts = line.split()
                if len(parts) >= 3:
                    url = parts[0]
                    view = parts[1]
                    name = parts[2]
                    if url.startswith('/api/v1/'):
                        endpoints.append({'url': url, 'view': view, 'name': name})
    except Exception as e:
        print(f"Error reading urls.txt: {e}")
        return

    print(f"Found {len(endpoints)} API endpoints.")
    
    results = []
    
    for ep in endpoints:
        url = ep['url']
        # Replace params
        url = re.sub(r'<int:[^>]+>', '1', url)
        url = re.sub(r'<str:[^>]+>', 'mock-ref', url)
        url = re.sub(r'<path:[^>]+>', 'mock/path', url)
        url = re.sub(r'<[^>]+>', '1', url) # Catch all
        
        # Decide method
        method = 'GET'
        if 'create' in ep['view'].lower() or 'register' in ep['view'].lower():
            method = 'POST'
        
        print(f"Testing {method} {url} ...", end=" ")
        
        try:
            if method == 'GET':
                response = client.get(url)
            else:
                response = client.post(url, {}, format='json')
            
            status = response.status_code
            print(f"[{status}]")
            
            error_detail = None
            if status >= 400:
                error_detail = str(response.content)
            
            results.append({
                'url': url,
                'method': method,
                'status': status,
                'view': ep['view'],
                'error': error_detail
            })
            
        except Exception as e:
            print(f"[EXCEPTION] {e}")
            results.append({
                'url': url,
                'method': method,
                'status': 'EXCEPTION',
                'view': ep['view'],
                'error': str(e)
            })

    # 5. Save Results
    with open('test_results.json', 'w') as f:
        json.dump(results, f, indent=4)
        
    # 6. Summary
    failures = [r for r in results if r['status'] == 'EXCEPTION' or (isinstance(r['status'], int) and r['status'] >= 500)]
    print(f"\nTest Complete. {len(results)} endpoints tested.")
    print(f"Failures: {len(failures)}")
    
    if failures:
        print("\nTOP FAILURES:")
        for f in failures[:5]:
            print(f"{f['method']} {f['url']} -> {f['status']}")

if __name__ == "__main__":
    run_tests()
