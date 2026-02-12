# backend/apps/bookings/models.py
from django.db import models
from django.core.validators import MinValueValidator
from decimal import Decimal


class Booking(models.Model):
    """Market Layer - Local booking transactions"""
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('payment_processing', 'Payment Processing'),
        ('confirmed', 'Confirmed'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]
    
    citizen = models.ForeignKey(
        'users.User',
        on_delete=models.PROTECT,
        related_name='bookings',
        limit_choices_to={'role': 'citizen'}
    )
    provider = models.ForeignKey(
        'users.User',
        on_delete=models.PROTECT,
        related_name='provider_bookings',
        limit_choices_to={'role': 'provider'}
    )
    municipality = models.ForeignKey(
        'municipalities.Municipality',
        on_delete=models.PROTECT,
        help_text="Municipality where service is provided (for local tracking)"
    )
    
    # Service details
    skill_category = models.CharField(max_length=50)
    scheduled_time = models.DateTimeField()
    description = models.TextField(help_text="Description of work needed")
    location_address = models.TextField(help_text="Service location address")
    
    # Status
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    
    # Payment
    amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(Decimal('0.01'))],
        help_text="Service amount in NPR"
    )
    payment_status = models.CharField(max_length=20, default='pending')
    payment_reference = models.CharField(max_length=100, null=True, blank=True)
    
    # Completion
    completed_at = models.DateTimeField(null=True, blank=True)
    completion_notes = models.TextField(blank=True)
    
    # Cancellation
    cancelled_at = models.DateTimeField(null=True, blank=True)
    cancellation_reason = models.TextField(blank=True)
    cancelled_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='cancelled_bookings'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'bookings'
        indexes = [
            models.Index(fields=['municipality', 'status', '-created_at']),
            models.Index(fields=['provider', 'status']),
            models.Index(fields=['citizen', '-created_at']),
            models.Index(fields=['-completed_at']),
            models.Index(fields=['status', '-scheduled_time']),
        ]
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Booking #{self.id} - {self.citizen.name} → {self.provider.name}"
    
    @property
    def can_be_confirmed(self):
        """Check if booking can be confirmed by provider"""
        return self.status == 'confirmed' and self.payment_status == 'success'
    
    @property
    def can_be_completed(self):
        """Check if booking can be marked as completed"""
        return self.status == 'confirmed'
    
    @property
    def can_be_cancelled(self):
        """Check if booking can be cancelled"""
        return self.status in ['pending', 'payment_processing', 'confirmed']