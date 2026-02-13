# backend/apps/governance/views.py
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Sum, Count, Q
from django.utils import timezone
from datetime import timedelta

from apps.users.permissions import IsMunicipalityAdmin
from apps.providers.models import ProviderProfile
from apps.bookings.models import Booking


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsMunicipalityAdmin])
def municipal_dashboard(request):
    """
    Municipal dashboard showing circular economy loop metrics
    Only accessible by municipality admins
    """
    municipality = request.user.municipality
    
    # Time period filters
    period = request.query_params.get('period', 'all')  # all, month, year
    
    # Base queryset for bookings in this municipality
    bookings_qs = Booking.objects.filter(municipality=municipality)
    
    if period == 'month':
        start_date = timezone.now() - timedelta(days=30)
        bookings_qs = bookings_qs.filter(created_at__gte=start_date)
    elif period == 'year':
        start_date = timezone.now() - timedelta(days=365)
        bookings_qs = bookings_qs.filter(created_at__gte=start_date)
    
    # 1. Verified Providers Count
    verified_providers = ProviderProfile.objects.filter(
        user__municipality=municipality,
        municipality_verified=True
    ).count()
    
    total_providers = ProviderProfile.objects.filter(
        user__municipality=municipality
    ).count()
    
    pending_verification = total_providers - verified_providers
    
    # 2. Completed Bookings
    completed_bookings = bookings_qs.filter(status='completed').count()
    total_bookings = bookings_qs.count()
    
    # 3. Total Local Earnings (money retained in municipality)
    local_earnings = bookings_qs.filter(status='completed').aggregate(
        total=Sum('amount')
    )['total'] or 0
    
    # 4. Top Active Skills
    top_skills = bookings_qs.filter(status='completed').values('skill_category').annotate(
        count=Count('id')
    ).order_by('-count')[:5]
    
    # 5. Provider Performance Stats
    active_providers = ProviderProfile.objects.filter(
        user__municipality=municipality,
        municipality_verified=True,
        jobs_completed__gt=0
    ).count()
    
    # 6. CTEVT Certification Stats
    ctevt_certified = ProviderProfile.objects.filter(
        user__municipality=municipality,
        ctevt_status='certified'
    ).count()
    
    # 7. Recent Activity
    recent_bookings = bookings_qs.order_by('-created_at')[:5].values(
        'id', 'skill_category', 'status', 'amount', 'created_at'
    )
    
    # 8. Monthly Trend (last 6 months)
    monthly_stats = []
    for i in range(6):
        month_start = timezone.now() - timedelta(days=30 * (i + 1))
        month_end = timezone.now() - timedelta(days=30 * i)
        
        month_bookings = Booking.objects.filter(
            municipality=municipality,
            created_at__gte=month_start,
            created_at__lt=month_end,
            status='completed'
        )
        
        monthly_stats.append({
            'month': month_start.strftime('%b %Y'),
            'bookings': month_bookings.count(),
            'earnings': float(month_bookings.aggregate(total=Sum('amount'))['total'] or 0)
        })
    
    monthly_stats.reverse()  # Oldest to newest
    
    # 9. Retention Rate (providers with repeat customers)
    # Simple metric: providers with 3+ jobs
    retained_providers = ProviderProfile.objects.filter(
        user__municipality=municipality,
        jobs_completed__gte=3
    ).count()
    
    retention_rate = (retained_providers / verified_providers * 100) if verified_providers > 0 else 0
    
    return Response({
        'municipality': {
            'id': municipality.id,
            'name': municipality.name,
            'district': municipality.district,
        },
        'period': period,
        'providers': {
            'total': total_providers,
            'verified': verified_providers,
            'pending_verification': pending_verification,
            'active': active_providers,
            'ctevt_certified': ctevt_certified,
            'retention_rate': round(retention_rate, 1),
        },
        'bookings': {
            'total': total_bookings,
            'completed': completed_bookings,
            'completion_rate': round((completed_bookings / total_bookings * 100) if total_bookings > 0 else 0, 1),
        },
        'earnings': {
            'total': float(local_earnings),
            'formatted': f"NPR {local_earnings:,.2f}",
        },
        'top_skills': list(top_skills),
        'recent_activity': list(recent_bookings),
        'monthly_trend': monthly_stats,
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def provider_dashboard(request):
    """
    Provider dashboard showing earnings, jobs, and performance
    Only accessible by providers with profiles
    """
    if request.user.role != 'provider':
        return Response({'error': 'Only providers can access this endpoint'}, status=403)
    
    try:
        profile = request.user.provider_profile
    except:
        return Response({'error': 'Provider profile not found'}, status=404)
    
    # Basic stats
    stats = {
        'total_earnings': float(profile.total_earnings),
        'jobs_completed': profile.jobs_completed,
        'avg_rating': float(profile.avg_rating),
        'trust_score': profile.trust_score,
    }
    
    # Verification status
    verification = {
        'municipality_verified': profile.municipality_verified,
        'verified_at': profile.verified_at.isoformat() if profile.verified_at else None,
        'ctevt_status': profile.ctevt_status,
    }
    
    # Recent bookings
    recent_bookings = Booking.objects.filter(
        provider=request.user
    ).order_by('-created_at')[:5].values(
        'id', 'skill_category', 'status', 'amount', 'scheduled_time', 'created_at'
    )
    
    # Pending bookings count
    pending_count = Booking.objects.filter(
        provider=request.user,
        status='confirmed'
    ).count()
    
    # Monthly earnings (last 6 months)
    monthly_earnings = []
    for i in range(6):
        month_start = timezone.now() - timedelta(days=30 * (i + 1))
        month_end = timezone.now() - timedelta(days=30 * i)
        
        month_bookings = Booking.objects.filter(
            provider=request.user,
            status='completed',
            completed_at__gte=month_start,
            completed_at__lt=month_end
        )
        
        monthly_earnings.append({
            'month': month_start.strftime('%b %Y'),
            'earnings': float(month_bookings.aggregate(total=Sum('amount'))['total'] or 0),
            'jobs': month_bookings.count()
        })
    
    monthly_earnings.reverse()
    
    # Skill breakdown
    skill_stats = Booking.objects.filter(
        provider=request.user,
        status='completed'
    ).values('skill_category').annotate(
        count=Count('id'),
        earnings=Sum('amount')
    ).order_by('-count')
    
    return Response({
        'profile': {
            'id': profile.id,
            'user': {
                'name': request.user.name,
                'municipality': request.user.municipality.name,
            },
            'skills': profile.get_skill_display_names(),
            'experience_years': profile.experience_years,
        },
        'stats': stats,
        'verification': verification,
        'pending_bookings': pending_count,
        'recent_bookings': list(recent_bookings),
        'monthly_earnings': monthly_earnings,
        'skill_breakdown': list(skill_stats),
    })