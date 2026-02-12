# backend/apps/bookings/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone
from django.db.models import Sum, Avg, Count
from .models import Booking


@receiver(post_save, sender=Booking)
def booking_post_save(sender, instance, created, **kwargs):
    """Handle booking status changes and update provider stats"""
    
    # If booking completed, update provider earnings and job count
    if instance.status == 'completed' and instance.completed_at:
        update_provider_stats(instance.provider)


def update_provider_stats(provider_user):
    """Recalculate provider's earnings and job count"""
    from apps.providers.models import ProviderProfile
    
    try:
        profile = ProviderProfile.objects.get(user=provider_user)
    except ProviderProfile.DoesNotExist:
        return
    
    # Calculate total earnings from completed bookings
    completed_bookings = Booking.objects.filter(
        provider=provider_user,
        status='completed'
    )
    
    total_earnings = completed_bookings.aggregate(
        total=Sum('amount')
    )['total'] or 0
    
    jobs_completed = completed_bookings.count()
    
    # Update profile
    profile.total_earnings = total_earnings
    profile.jobs_completed = jobs_completed
    profile.save(update_fields=['total_earnings', 'jobs_completed'])