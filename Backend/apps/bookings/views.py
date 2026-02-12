# backend/apps/bookings/views.py
from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.utils import timezone
from django.db.models import Q

from .models import Booking
from .serializers import (
    BookingSerializer, BookingCreateSerializer, BookingListSerializer,
    BookingConfirmSerializer, BookingCompleteSerializer, BookingCancelSerializer
)
from .permissions import IsBookingParticipant, IsBookingCitizen, IsBookingProvider
from apps.users.permissions import IsCitizen


class BookingCreateView(generics.CreateAPIView):
    """Create new booking (citizen only)"""
    serializer_class = BookingCreateSerializer
    permission_classes = [IsAuthenticated, IsCitizen]
    
    def perform_create(self, serializer):
        booking = serializer.save()
        return booking


class BookingListView(generics.ListAPIView):
    """List bookings (filtered by user role)"""
    serializer_class = BookingListSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        
        # Filter by role
        if user.role == 'citizen':
            queryset = Booking.objects.filter(citizen=user)
        elif user.role == 'provider':
            queryset = Booking.objects.filter(provider=user)
        elif user.role == 'municipality_admin':
            # Admin sees all bookings in their municipality
            queryset = Booking.objects.filter(municipality=user.municipality)
        else:
            queryset = Booking.objects.none()
        
        # Filter by status
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        # Filter by role parameter (for provider/citizen switching views)
        role_view = self.request.query_params.get('role')
        if role_view == 'provider' and user.role == 'provider':
            queryset = Booking.objects.filter(provider=user)
        elif role_view == 'citizen' and user.role == 'citizen':
            queryset = Booking.objects.filter(citizen=user)
        
        return queryset.select_related(
            'citizen', 'provider', 'municipality'
        ).order_by('-created_at')


class BookingDetailView(generics.RetrieveAPIView):
    """Booking detail view"""
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated, IsBookingParticipant]
    
    def get_queryset(self):
        user = self.request.user
        return Booking.objects.filter(
            Q(citizen=user) | Q(provider=user) | Q(municipality=user.municipality)
        ).select_related('citizen', 'provider', 'municipality')


@api_view(['PATCH'])
@permission_classes([IsAuthenticated, IsBookingProvider])
def confirm_booking(request, pk):
    """Provider confirms booking after payment success"""
    booking = get_object_or_404(Booking, pk=pk)
    
    # Check permission
    if booking.provider != request.user:
        return Response(
            {'error': 'Only the assigned provider can confirm this booking'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Validate booking state
    if booking.status != 'confirmed':
        return Response(
            {'error': 'Booking must be in confirmed status (payment successful)'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if booking.payment_status != 'success':
        return Response(
            {'error': 'Payment must be successful before confirmation'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Booking is already confirmed by payment, nothing to do
    # This endpoint can be used for future provider acceptance workflow
    
    serializer = BookingSerializer(booking)
    return Response(serializer.data)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated, IsBookingProvider])
def complete_booking(request, pk):
    """Provider marks booking as completed"""
    booking = get_object_or_404(Booking, pk=pk)
    
    # Check permission
    if booking.provider != request.user:
        return Response(
            {'error': 'Only the assigned provider can complete this booking'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Validate booking state
    if booking.status != 'confirmed':
        return Response(
            {'error': 'Only confirmed bookings can be marked as completed'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if booking.status == 'completed':
        return Response(
            {'error': 'Booking is already completed'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Mark as completed
    serializer = BookingCompleteSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    booking.status = 'completed'
    booking.completed_at = timezone.now()
    booking.completion_notes = serializer.validated_data.get('completion_notes', '')
    booking.save()
    
    # Signal will update provider stats
    
    return Response(BookingSerializer(booking).data)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def cancel_booking(request, pk):
    """Cancel booking (citizen or provider)"""
    booking = get_object_or_404(Booking, pk=pk)
    
    # Check permission
    if booking.citizen != request.user and booking.provider != request.user:
        return Response(
            {'error': 'Only booking participants can cancel'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Validate booking state
    if not booking.can_be_cancelled:
        return Response(
            {'error': f'Booking with status "{booking.status}" cannot be cancelled'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Cancel booking
    serializer = BookingCancelSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    booking.status = 'cancelled'
    booking.cancelled_at = timezone.now()
    booking.cancelled_by = request.user
    booking.cancellation_reason = serializer.validated_data['cancellation_reason']
    booking.save()
    
    return Response(BookingSerializer(booking).data)