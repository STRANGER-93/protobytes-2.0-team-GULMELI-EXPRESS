# backend/apps/reviews/models.py
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator


class Review(models.Model):
    """Trust feedback loop - Post-booking reviews"""
    
    booking = models.OneToOneField(
        'bookings.Booking',
        on_delete=models.CASCADE,
        related_name='review'
    )
    provider = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        related_name='reviews_received',
        limit_choices_to={'role': 'provider'}
    )
    reviewer = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        related_name='reviews_given',
        limit_choices_to={'role': 'citizen'}
    )
    
    rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        help_text="Rating from 1 to 5 stars"
    )
    comment = models.TextField(blank=True)
    
    # Response from provider (future feature)
    provider_response = models.TextField(blank=True)
    responded_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'reviews'
        indexes = [
            models.Index(fields=['provider', '-created_at']),
            models.Index(fields=['-created_at']),
            models.Index(fields=['rating']),
        ]
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Review for {self.provider.name} - {self.rating}★"