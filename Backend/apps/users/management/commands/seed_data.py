"""
Management command to seed the database with test data for JanSewa
"""
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.municipalities.models import Municipality
from apps.providers.models import ProviderProfile

User = get_user_model()


class Command(BaseCommand):
    help = 'Seeds the database with test data for development'

    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding database...')

        # Create municipalities if they don't exist
        municipalities_data = [
            {'name': 'Kathmandu Metropolitan City', 'district': 'Kathmandu', 'province': 'Bagmati'},
            {'name': 'Lalitpur Metropolitan City', 'district': 'Lalitpur', 'province': 'Bagmati'},
            {'name': 'Bhaktapur Municipality', 'district': 'Bhaktapur', 'province': 'Bagmati'},
        ]

        municipalities = []
        for mun_data in municipalities_data:
            mun, created = Municipality.objects.get_or_create(
                name=mun_data['name'],
                defaults=mun_data
            )
            municipalities.append(mun)
            if created:
                self.stdout.write(self.style.SUCCESS(f'✓ Created municipality: {mun.name}'))
            else:
                self.stdout.write(f'  Municipality already exists: {mun.name}')

        # Create test users
        users_data = [
            {
                'phone': '9841234567',
                'name': 'Ram Sharma',
                'role': 'citizen',
                'municipality': municipalities[0],
            },
            {
                'phone': '9851234567',
                'name': 'Sita Thapa',
                'role': 'citizen',
                'municipality': municipalities[1],
            },
            {
                'phone': '9861234567',
                'name': 'Hari Electrician',
                'role': 'provider',
                'municipality': municipalities[0],
            },
            {
                'phone': '9871234567',
                'name': 'Krishna Plumber',
                'role': 'provider',
                'municipality': municipalities[0],
            },
            {
                'phone': '9881234567',
                'name': 'Gita Carpenter',
                'role': 'provider',
                'municipality': municipalities[1],
            },
            {
                'phone': '9891234567',
                'name': 'Admin User',
                'role': 'municipality_admin',
                'municipality': municipalities[0],
            },
        ]

        for user_data in users_data:
            user, created = User.objects.get_or_create(
                phone=user_data['phone'],
                defaults=user_data
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'✓ Created user: {user.name} ({user.role})'))
            else:
                self.stdout.write(f'  User already exists: {user.name}')

        # Create provider profiles
        providers_data = [
            {
                'user_phone': '9861234567',
                'skill_categories': ['electrician', 'appliance_repair'],
                'bio': 'Experienced electrician with 10 years of experience. Specialized in home wiring and appliance repair.',
                'experience_years': 10,
                'municipality_verified': True,
                'ctevt_status': 'certified',
            },
            {
                'user_phone': '9871234567',
                'skill_categories': ['plumber'],
                'bio': 'Professional plumber. Expert in pipe fitting, leak repairs, and bathroom installations.',
                'experience_years': 8,
                'municipality_verified': True,
                'ctevt_status': 'pending',
            },
            {
                'user_phone': '9881234567',
                'skill_categories': ['carpenter', 'painter'],
                'bio': 'Skilled carpenter and painter. Quality furniture making and home painting services.',
                'experience_years': 5,
                'municipality_verified': False,
                'ctevt_status': 'not_applicable',
            },
        ]

        for provider_data in providers_data:
            user = User.objects.get(phone=provider_data['user_phone'])
            profile, created = ProviderProfile.objects.get_or_create(
                user=user,
                defaults={
                    'skill_categories': provider_data['skill_categories'],
                    'bio': provider_data['bio'],
                    'experience_years': provider_data['experience_years'],
                    'municipality_verified': provider_data['municipality_verified'],
                    'ctevt_status': provider_data['ctevt_status'],
                }
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'✓ Created provider profile: {user.name}'))
            else:
                self.stdout.write(f'  Provider profile already exists: {user.name}')

        self.stdout.write(self.style.SUCCESS('\n✅ Database seeding complete!'))
        self.stdout.write('\nTest accounts created:')
        self.stdout.write('  Citizens:')
        self.stdout.write('    - Phone: 9841234567 (Ram Sharma)')
        self.stdout.write('    - Phone: 9851234567 (Sita Thapa)')
        self.stdout.write('  Providers:')
        self.stdout.write('    - Phone: 9861234567 (Hari Electrician) - Verified')
        self.stdout.write('    - Phone: 9871234567 (Krishna Plumber) - Verified')
        self.stdout.write('    - Phone: 9881234567 (Gita Carpenter) - Pending')
        self.stdout.write('  Admin:')
        self.stdout.write('    - Phone: 9891234567 (Admin User)')
        self.stdout.write('\nOTP for all accounts: 123456')
