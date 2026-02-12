# backend/apps/reviews/views.py
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import Review
from .serializers import ReviewSerializer, ReviewCreateSerializer, ReviewListSerializer
from apps.users.permissions import IsCitizen


class ReviewCreateView(generics.CreateAPIView):
    """Create review for completed booking (citizen only)"""
    serializer_class = ReviewCreateSerializer
    permission_classes = [IsAuthenticated, IsCitizen]


class ReviewListView(generics.ListAPIView):
    """List reviews for a provider"""
    serializer_class = ReviewListSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        provider_id = self.request.query_params.get('provider')
        
        queryset = Review.objects.select_related('reviewer', 'provider')
        
        if provider_id:
            queryset = queryset.filter(provider_id=provider_id)
        
        return queryset.order_by('-created_at')


class ReviewDetailView(generics.RetrieveAPIView):
    """Review detail view"""
    serializer_class = ReviewSerializer
    permission_classes = [IsAuthenticated]
    queryset = Review.objects.select_related('reviewer', 'provider', 'booking')