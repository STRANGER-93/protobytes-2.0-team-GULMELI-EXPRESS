# backend/apps/providers/views.py
from rest_framework import generics, status, filters
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from django.shortcuts import get_object_or_404

from .models import ProviderProfile
from .serializers import (
    ProviderProfileSerializer, ProviderRegistrationSerializer,
    ProviderUpdateSerializer, ProviderVerificationSerializer,
    ProviderListSerializer
)
from .permissions import IsProviderOwner, CanVerifyProvider, IsProviderUser
from apps.users.models import User


class ProviderRegisterView(generics.CreateAPIView):
    """Provider onboarding - create profile"""
    serializer_class = ProviderRegistrationSerializer
    permission_classes = [IsAuthenticated, IsProviderUser]
    
    def perform_create(self, serializer):
        # Check if user already has provider profile
        if hasattr(self.request.user, 'provider_profile'):
            raise serializers.ValidationError("Provider profile already exists")
        
        # Create provider profile linked to current user
        serializer.save(user=self.request.user)


class ProviderMeView(generics.RetrieveUpdateAPIView):
    """Get and update own provider profile"""
    permission_classes = [IsAuthenticated, IsProviderUser]
    
    def get_serializer_class(self):
        if self.request.method == 'PATCH':
            return ProviderUpdateSerializer
        return ProviderProfileSerializer
    
    def get_object(self):
        # Get provider profile for current user
        return get_object_or_404(ProviderProfile, user=self.request.user)


class ProviderSearchView(generics.ListAPIView):
    """Search providers with filters"""
    serializer_class = ProviderListSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        queryset = ProviderProfile.objects.select_related(
            'user', 'user__municipality'
        ).filter(is_active=True)
        
        # Filter by municipality (default to user's municipality)
        municipality_id = self.request.query_params.get('municipality')
        if municipality_id:
            queryset = queryset.filter(user__municipality_id=municipality_id)
        else:
            # Default: prioritize user's own municipality
            queryset = queryset.filter(user__municipality=self.request.user.municipality)
        
        # Filter by skill category
        skill = self.request.query_params.get('skill')
        if skill:
            queryset = queryset.filter(skill_categories__contains=[skill])
        
        # Filter by minimum rating
        min_rating = self.request.query_params.get('min_rating')
        if min_rating:
            try:
                queryset = queryset.filter(avg_rating__gte=float(min_rating))
            except ValueError:
                pass
        
        # Filter by verification status
        verified_only = self.request.query_params.get('verified_only')
        if verified_only and verified_only.lower() == 'true':
            queryset = queryset.filter(municipality_verified=True)
        
        # Filter by CTEVT status
        ctevt_status = self.request.query_params.get('ctevt_status')
        if ctevt_status:
            queryset = queryset.filter(ctevt_status=ctevt_status)
        
        # Search by name
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(user__name__icontains=search) |
                Q(bio__icontains=search)
            )
        
        return queryset.order_by('-municipality_verified', '-avg_rating', '-jobs_completed')


class ProviderDetailView(generics.RetrieveAPIView):
    """Provider detail view with full info"""
    serializer_class = ProviderProfileSerializer
    permission_classes = [IsAuthenticated]
    queryset = ProviderProfile.objects.select_related(
        'user', 'user__municipality', 'verified_by'
    )


class ProviderVerifyView(generics.UpdateAPIView):
    """Municipality admin verifies provider"""
    serializer_class = ProviderVerificationSerializer
    permission_classes = [IsAuthenticated, CanVerifyProvider]
    queryset = ProviderProfile.objects.select_related('user')
    
    def perform_update(self, serializer):
        # Set verified_by to current admin
        serializer.save(verified_by=self.request.user)


class ProviderListForVerificationView(generics.ListAPIView):
    """List providers pending verification (municipality admin only)"""
    serializer_class = ProviderListSerializer
    permission_classes = [IsAuthenticated, CanVerifyProvider]
    
    def get_queryset(self):
        # Only providers in admin's municipality
        return ProviderProfile.objects.select_related(
            'user', 'user__municipality'
        ).filter(
            user__municipality=self.request.user.municipality
        ).order_by('-created_at')


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def provider_stats(request, pk):
    """Get provider statistics"""
    provider = get_object_or_404(ProviderProfile, pk=pk)
    
    # Calculate additional stats
    stats = {
        'total_earnings': float(provider.total_earnings),
        'jobs_completed': provider.jobs_completed,
        'avg_rating': float(provider.avg_rating),
        'trust_score': provider.trust_score,
        'municipality': provider.user.municipality.name,
        'active_since': provider.created_at.isoformat(),
    }
    
    return Response(stats)