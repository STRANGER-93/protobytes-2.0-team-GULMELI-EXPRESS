# backend/apps/payments/serializers.py
from rest_framework import serializers
from .models import PaymentTransaction


class PaymentTransactionSerializer(serializers.ModelSerializer):
    """Payment transaction serializer"""
    
    class Meta:
        model = PaymentTransaction
        fields = [
            'id', 'booking', 'reference_id', 'amount', 'status',
            'mock_gateway', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'reference_id', 'created_at', 'updated_at']


class PaymentInitiateSerializer(serializers.Serializer):
    """Initiate mock payment"""
    booking_id = serializers.IntegerField()
    
    def validate_booking_id(self, value):
        """Validate booking exists and belongs to user"""
        from apps.bookings.models import Booking
        
        try:
            booking = Booking.objects.get(id=value)
        except Booking.DoesNotExist:
            raise serializers.ValidationError("Booking not found")
        
        # Check if user is the citizen
        user = self.context['request'].user
        if booking.citizen != user:
            raise serializers.ValidationError("You can only pay for your own bookings")
        
        # Check booking status
        if booking.status != 'pending':
            raise serializers.ValidationError("Booking must be in pending status")
        
        # Check if payment already exists
        if hasattr(booking, 'payment'):
            if booking.payment.status == 'success':
                raise serializers.ValidationError("Booking already paid")
        
        return value