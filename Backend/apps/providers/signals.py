# backend/apps/providers/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone
from .models import ProviderProfile


@receiver(post_save, sender=ProviderProfile)
def provider_profile_post_save(sender, instance, created, **kwargs):
    """Handle provider profile post-save actions"""
    if created:
        # New provider profile created
        # Future: Send notification to municipality admin for verification
        pass
    
    # Check if verification status changed
    if instance.municipality_verified and not instance.verified_at:
        instance.verified_at = timezone.now()
        instance.save(update_fields=['verified_at'])