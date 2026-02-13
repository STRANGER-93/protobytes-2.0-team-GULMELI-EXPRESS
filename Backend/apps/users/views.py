# backend/apps/users/views.py
from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.conf import settings
from django.utils import timezone

from .models import User
from .serializers import (
    UserSerializer, SendOTPSerializer, VerifyOTPSerializer,
    UserUpdateSerializer
)
from apps.municipalities.models import Municipality


@api_view(['POST'])
@permission_classes([AllowAny])
def send_otp(request):
    """
    Mock OTP sending endpoint
    In production, this would integrate with SMS gateway
    """
    serializer = SendOTPSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    phone = serializer.validated_data['phone']
    
    # Mock: Log OTP (in production, send via SMS)
    if settings.MOCK_OTP_ENABLED:
        print(f"[MOCK OTP] Phone: {phone}, OTP: {settings.MOCK_OTP}")
        return Response({
            'message': 'OTP sent successfully',
            'mock_otp': settings.MOCK_OTP if settings.DEBUG else None
        }, status=status.HTTP_200_OK)
    
    return Response({
        'message': 'OTP sent successfully'
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def verify_otp(request):
    """
    Mock OTP verification and JWT token generation
    Creates user if doesn't exist (registration flow)
    """
    serializer = VerifyOTPSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    phone = serializer.validated_data['phone']
    otp = serializer.validated_data['otp']
    
    # Mock OTP verification
    if settings.MOCK_OTP_ENABLED:
        if otp != settings.MOCK_OTP:
            return Response({
                'error': 'Invalid OTP'
            }, status=status.HTTP_400_BAD_REQUEST)
    
    # Get or create user
    user = User.objects.filter(phone=phone).first()
    
    if not user:
        # Registration flow - need additional fields
        name = serializer.validated_data.get('name')
        role = serializer.validated_data.get('role', 'citizen')
        municipality_id = serializer.validated_data.get('municipality')
        
        if not all([name, municipality_id]):
            return Response({
                'error': 'Name and municipality required for new users',
                'is_new_user': True
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            municipality = Municipality.objects.get(id=municipality_id)
        except Municipality.DoesNotExist:
            return Response({
                'error': 'Municipality not found'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        user = User.objects.create_user(
            phone=phone,
            name=name,
            municipality=municipality,
            role=role
        )
    
    # Update last login
    user.last_login = timezone.now()
    user.save(update_fields=['last_login'])
    
    # Generate JWT tokens
    refresh = RefreshToken.for_user(user)
    
    return Response({
        'access': str(refresh.access_token),
        'refresh': str(refresh),
        'user': UserSerializer(user).data
    }, status=status.HTTP_200_OK)


class CurrentUserView(generics.RetrieveUpdateAPIView):
    """Get and update current user profile"""
    permission_classes = [IsAuthenticated]
    serializer_class = UserSerializer
    
    def get_object(self):
        return self.request.user
    
    def get_serializer_class(self):
        if self.request.method == 'PATCH':
            return UserUpdateSerializer
        return UserSerializer
    
class UserProfileView(generics.RetrieveUpdateAPIView):
    """Complete user profile with photo upload"""
    permission_classes = [IsAuthenticated]
    serializer_class = UserSerializer
    
    def get_object(self):
        return self.request.user
    
    def get_serializer_class(self):
        if self.request.method in ['PATCH', 'PUT']:
            return UserUpdateSerializer
        return UserSerializer