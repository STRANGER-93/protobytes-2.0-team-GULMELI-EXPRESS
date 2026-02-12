from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator

# Create your models here.
# apps/reviews/models.py
class Review(models.Model):
    """Trust feedback loop"""
    booking = models.OneToOneField('bookings.Booking', on_delete=models.CASCADE, related_name='review')
    provider = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='reviews_received')
    reviewer = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='reviews_given')
    
    rating = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    comment = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        indexes = [models.Index(fields=['provider', '-created_at'])]