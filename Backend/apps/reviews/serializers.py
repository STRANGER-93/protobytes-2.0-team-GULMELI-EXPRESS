# backend/apps/reviews/serializers.py
from rest_framework import serializers
from .models import Review
from apps.users.serializers import UserSerializer


class ReviewSerializer(serializers.ModelSerializer):
    """Main review serializer"""
    reviewer_detail = UserSerializer(source='reviewer', read_only=True)
    provider_name = serializers.CharField(source='provider.name', read_only=True)
    
    class Meta:
        model = Review
        fields = [
            'id', 'booking', 'provider', 'provider_name', 'reviewer',
            'reviewer_detail', 'rating', 'comment', 'provider_response',
            'responded_at', 'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'provider', 'reviewer', 'provider_response',
            'responded_at', 'created_at', 'updated_at'
        ]


class ReviewCreateSerializer(serializers.ModelSerializer):
    """Review creation serializer"""
    
    class Meta:
        model = Review
        fields = ['booking', 'rating', 'comment']
    
    def validate_booking(self, value):
        """Validate booking is completed and belongs to user"""
        user = self.context['request'].user
        
        # Check if user is the citizen
        if value.citizen != user:
            raise serializers.ValidationError("You can only review your own bookings")
        
        # Check booking is completed
        if value.status != 'completed':
            raise serializers.ValidationError("Can only review completed bookings")
        
        # Check if review already exists
        if hasattr(value, 'review'):
            raise serializers.ValidationError("Review already exists for this booking")
        
        return value
    
    def validate_rating(self, value):
        """Validate rating is 1-5"""
        if value < 1 or value > 5:
            raise serializers.ValidationError("Rating must be between 1 and 5")
        return value
    
    def create(self, validated_data):
        """Create review with provider from booking"""
        booking = validated_data['booking']
        validated_data['provider'] = booking.provider
        validated_data['reviewer'] = self.context['request'].user
        return super().create(validated_data)


class ReviewListSerializer(serializers.ModelSerializer):
    """Lightweight review serializer for lists"""
    reviewer_name = serializers.CharField(source='reviewer.name', read_only=True)
    
    class Meta:
        model = Review
        fields = [
            'id', 'rating', 'comment', 'reviewer_name', 'created_at'
        ]