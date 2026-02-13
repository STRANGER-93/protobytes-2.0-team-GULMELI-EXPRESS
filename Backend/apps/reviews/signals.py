# backend/apps/reviews/signals.py
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.db.models import Avg
from .models import Review


@receiver(post_save, sender=Review)
@receiver(post_delete, sender=Review)
def update_provider_rating(sender, instance, **kwargs):
    """Recalculate provider's average rating when review is added/updated/deleted"""
    from apps.providers.models import ProviderProfile
    
    try:
        profile = ProviderProfile.objects.get(user=instance.provider)
    except ProviderProfile.DoesNotExist:
        return
    
    # Calculate average rating
    avg_rating = Review.objects.filter(provider=instance.provider).aggregate(
        avg=Avg('rating')
    )['avg'] or 0.00
    
    profile.avg_rating = round(avg_rating, 2)
    profile.save(update_fields=['avg_rating'])