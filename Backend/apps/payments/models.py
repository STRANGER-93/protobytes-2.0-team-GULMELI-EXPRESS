# backend/apps/payments/models.py
from django.db import models
import uuid


class PaymentTransaction(models.Model):
    """Mock payment tracking for MVP"""
    
    STATUS_CHOICES = [
        ('initiated', 'Initiated'),
        ('processing', 'Processing'),
        ('success', 'Success'),
        ('failed', 'Failed'),
    ]
    
    booking = models.OneToOneField(
        'bookings.Booking',
        on_delete=models.CASCADE,
        related_name='payment'
    )
    reference_id = models.CharField(max_length=100, unique=True, db_index=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='initiated')
    
    # Mock payment metadata
    mock_gateway = models.CharField(max_length=50, default='MockPay')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'payment_transactions'
        indexes = [
            models.Index(fields=['reference_id']),
            models.Index(fields=['status', '-created_at']),
        ]
    
    def __str__(self):
        return f"Payment {self.reference_id} - {self.status}"
    
    @classmethod
    def generate_reference(cls):
        """Generate unique payment reference"""
        return f"PAY-{uuid.uuid4().hex[:12].upper()}"