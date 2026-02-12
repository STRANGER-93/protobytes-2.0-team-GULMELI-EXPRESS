from django.db import models

# Create your models here.
class PaymentTransaction(models.Model):
    """Mock payment tracking"""
    booking = models.OneToOneField('bookings.Booking', on_delete=models.CASCADE, related_name='payment')
    reference_id = models.CharField(max_length=100, unique=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, default='initiated')  # initiated, success, failed
    created_at = models.DateTimeField(auto_now_add=True)