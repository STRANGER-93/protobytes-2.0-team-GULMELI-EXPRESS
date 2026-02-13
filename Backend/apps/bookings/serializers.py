# backend/apps/bookings/serializers.py
from rest_framework import serializers
from django.utils import timezone
from .models import Booking
from apps.users.serializers import UserSerializer, SimpleUserSerializer
from apps.users.models import User
from apps.providers.serializers import ProviderListSerializer
from apps.municipalities.serializers import MunicipalitySerializer


class BookingSerializer(serializers.ModelSerializer):
    """Main booking serializer with full details"""
    citizen_detail = UserSerializer(source='citizen', read_only=True)
    provider_detail = UserSerializer(source='provider', read_only=True)
    municipality_detail = MunicipalitySerializer(source='municipality', read_only=True)
    
    class Meta:
        model = Booking
        fields = [
            'id', 'citizen', 'citizen_detail', 'provider', 'provider_detail',
            'municipality', 'municipality_detail', 'skill_category',
            'scheduled_time', 'description', 'location_address', 'status',
            'amount', 'payment_status', 'payment_reference', 'completed_at',
            'completion_notes', 'cancelled_at', 'cancellation_reason',
            'cancelled_by', 'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'citizen', 'municipality', 'status', 'payment_status',
            'payment_reference', 'completed_at', 'cancelled_at', 'cancelled_by',
            'created_at', 'updated_at'
        ]


class BookingCreateSerializer(serializers.ModelSerializer):
    """Booking creation serializer"""
    
    class Meta:
        model = Booking
        fields = [
            'id', 'provider', 'skill_category', 'scheduled_time',
            'description', 'location_address', 'amount', 'status'
        ]
        read_only_fields = ['id', 'status']
    
    def validate_provider(self, value):
        """Validate provider exists and has profile"""
        if value.role != 'provider':
            raise serializers.ValidationError("Selected user is not a provider")
        
        if not hasattr(value, 'provider_profile'):
            raise serializers.ValidationError("Provider profile not found")
        
        if not value.provider_profile.municipality_verified:
            raise serializers.ValidationError("Provider must be municipality verified")
        
        return value
    
    def validate_scheduled_time(self, value):
        """Validate scheduled time is in the future"""
        if value <= timezone.now():
            raise serializers.ValidationError("Scheduled time must be in the future")
        return value
    
    def validate_amount(self, value):
        """Validate amount is positive"""
        if value <= 0:
            raise serializers.ValidationError("Amount must be greater than 0")
        return value
    
    def create(self, validated_data):
        """Create booking with citizen and municipality from context"""
        user = self.context['request'].user
        provider = validated_data['provider']
        
        # Set citizen and municipality
        validated_data['citizen'] = user
        validated_data['municipality'] = provider.municipality
        validated_data['status'] = 'pending'
        validated_data['payment_status'] = 'pending'
        
        return super().create(validated_data)
        
    def to_representation(self, instance):
        """Use full BookingSerializer for response"""
        return BookingSerializer(instance).data


class BookingListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for booking lists"""
    citizen_detail = SimpleUserSerializer(source='citizen', read_only=True)
    provider_detail = SimpleUserSerializer(source='provider', read_only=True)
    municipality_detail = MunicipalitySerializer(source='municipality', read_only=True)
    
    class Meta:
        model = Booking
        fields = [
            'id', 'citizen_detail', 'provider_detail', 'municipality_detail',
            'skill_category', 'scheduled_time', 'description', 'location_address', 
            'status', 'amount', 'payment_status', 'created_at'
        ]


class BookingConfirmSerializer(serializers.Serializer):
    """Provider confirms booking"""
    pass


class BookingCompleteSerializer(serializers.Serializer):
    """Mark booking as completed"""
    completion_notes = serializers.CharField(required=False, allow_blank=True)


class BookingCancelSerializer(serializers.Serializer):
    """Cancel booking"""
    cancellation_reason = serializers.CharField(required=True)