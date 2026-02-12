from django.db import models

# Create your models here.
# apps/bookings/models.py
class Booking(models.Model):
    """Market Layer - Local booking transactions"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]
    
    citizen = models.ForeignKey('users.User', on_delete=models.PROTECT, related_name='bookings')
    provider = models.ForeignKey('users.User', on_delete=models.PROTECT, related_name='provider_bookings')
    municipality = models.ForeignKey('municipalities.Municipality', on_delete=models.PROTECT)  # For local tracking
    
    skill_category = models.CharField(max_length=50)
    scheduled_time = models.DateTimeField()
    description = models.TextField()
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    amount = models.DecimalField(max_digits=10, decimal_places=2)  # Mock payment amount
    
    # Payment tracking
    payment_status = models.CharField(max_length=20, default='pending')
    payment_reference = models.CharField(max_length=100, null=True, blank=True)
    
    completed_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        indexes = [
            models.Index(fields=['municipality', 'status', '-created_at']),
            models.Index(fields=['provider', 'status']),
            models.Index(fields=['citizen', '-created_at']),
            models.Index(fields=['-completed_at'])
        ]