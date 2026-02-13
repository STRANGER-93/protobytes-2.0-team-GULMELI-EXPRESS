# backend/apps/providers/serializers.py
from rest_framework import serializers
from .models import ProviderProfile
from apps.users.serializers import UserSerializer


class ProviderProfileSerializer(serializers.ModelSerializer):
    """Main provider profile serializer"""
    user_detail = UserSerializer(source='user', read_only=True)
    skill_display_names = serializers.ReadOnlyField(source='get_skill_display_names')
    trust_score = serializers.ReadOnlyField()
    
    class Meta:
        model = ProviderProfile
        fields = [
            'id', 'user', 'user_detail', 'skill_categories', 'skill_display_names',
            'bio', 'experience_years', 'municipality_verified', 'verified_at',
            'verified_by', 'ctevt_status', 'ctevt_certificate_upload',
            'ctevt_certificate_link', 'citizenship_photo', 'avg_rating',
            'jobs_completed', 'total_earnings', 'is_active', 'trust_score',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'user', 'municipality_verified', 'verified_at', 'verified_by',
            'avg_rating', 'jobs_completed', 'total_earnings', 'created_at',
            'updated_at', 'trust_score'
        ]


class ProviderRegistrationSerializer(serializers.ModelSerializer):
    """Provider onboarding serializer"""
    
    class Meta:
        model = ProviderProfile
        fields = [
            'skill_categories', 'bio', 'experience_years',
            'citizenship_photo', 'ctevt_certificate_upload',
            'ctevt_certificate_link', 'ctevt_status'
        ]
    
    def validate_skill_categories(self, value):
        """Validate skill categories"""
        if not value or len(value) == 0:
            raise serializers.ValidationError("At least one skill category required")
        
        valid_skills = [choice[0] for choice in ProviderProfile.SKILL_CATEGORIES]
        for skill in value:
            if skill not in valid_skills:
                raise serializers.ValidationError(f"Invalid skill category: {skill}")
        
        return value
    
    def validate(self, data):
        """Validate CTEVT fields"""
        ctevt_status = data.get('ctevt_status', 'pending')
        
        # If claiming certified, must provide upload or link
        if ctevt_status == 'certified':
            if not data.get('ctevt_certificate_upload') and not data.get('ctevt_certificate_link'):
                raise serializers.ValidationError({
                    'ctevt_status': 'Certificate upload or link required for certified status'
                })
        
        return data


class ProviderUpdateSerializer(serializers.ModelSerializer):
    """Provider profile update serializer"""
    
    class Meta:
        model = ProviderProfile
        fields = [
            'skill_categories', 'bio', 'experience_years',
            'ctevt_certificate_upload', 'ctevt_certificate_link',
            'is_active'
        ]


class ProviderVerificationSerializer(serializers.ModelSerializer):
    """Municipality admin verification serializer"""
    
    class Meta:
        model = ProviderProfile
        fields = ['municipality_verified', 'verification_notes', 'ctevt_status']
    
    def validate(self, data):
        """Only municipality admins can verify"""
        user = self.context['request'].user
        if user.role != 'municipality_admin':
            raise serializers.ValidationError("Only municipality admins can verify providers")
        return data


class ProviderListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for provider listing"""
    user_detail = UserSerializer(source='user', read_only=True)
    skill_display_names = serializers.ReadOnlyField(source='get_skill_display_names')
    
    class Meta:
        model = ProviderProfile
        fields = [
            'id', 'user_detail', 'skill_categories', 'skill_display_names',
            'bio', 'municipality_verified', 'ctevt_status', 'avg_rating',
            'jobs_completed', 'experience_years'
        ]