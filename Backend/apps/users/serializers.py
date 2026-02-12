# backend/apps/users/serializers.py
from rest_framework import serializers
from .models import User
from apps.municipalities.serializers import MunicipalitySerializer


class UserSerializer(serializers.ModelSerializer):
    """Main user serializer"""
    municipality_detail = MunicipalitySerializer(source='municipality', read_only=True)
    
    class Meta:
        model = User
        fields = [
            'id', 'phone', 'name', 'role', 'municipality', 'municipality_detail',
            'photo', 'date_joined', 'last_login'
        ]
        read_only_fields = ['id', 'date_joined', 'last_login']


class UserRegistrationSerializer(serializers.Serializer):
    """Registration serializer"""
    phone = serializers.CharField(max_length=15)
    name = serializers.CharField(max_length=150)
    role = serializers.ChoiceField(choices=User.ROLE_CHOICES)
    municipality = serializers.IntegerField()
    photo = serializers.ImageField(required=False, allow_null=True)
    
    def validate_phone(self, value):
        """Validate phone format"""
        if not value.startswith('98') or len(value) != 10:
            raise serializers.ValidationError("Phone must be 10 digits starting with 98")
        return value
    
    def validate_municipality(self, value):
        """Validate municipality exists"""
        from apps.municipalities.models import Municipality
        if not Municipality.objects.filter(id=value).exists():
            raise serializers.ValidationError("Municipality does not exist")
        return value


class SendOTPSerializer(serializers.Serializer):
    """OTP send request serializer"""
    phone = serializers.CharField(max_length=15)
    
    def validate_phone(self, value):
        """Validate phone format"""
        if not value.startswith('98') or len(value) != 10:
            raise serializers.ValidationError("Phone must be 10 digits starting with 98")
        return value


class VerifyOTPSerializer(serializers.Serializer):
    """OTP verification serializer"""
    phone = serializers.CharField(max_length=15)
    otp = serializers.CharField(max_length=6)
    name = serializers.CharField(max_length=150, required=False)
    role = serializers.ChoiceField(choices=User.ROLE_CHOICES, required=False, default='citizen')
    municipality = serializers.IntegerField(required=False)
    
    def validate_phone(self, value):
        """Validate phone format"""
        if not value.startswith('98') or len(value) != 10:
            raise serializers.ValidationError("Phone must be 10 digits starting with 98")
        return value


class UserUpdateSerializer(serializers.ModelSerializer):
    """Profile update serializer"""
    
    class Meta:
        model = User
        fields = ['name', 'photo']