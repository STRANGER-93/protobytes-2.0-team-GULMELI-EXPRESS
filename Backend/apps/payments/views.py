# backend/apps/payments/views.py
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.shortcuts import get_object_or_404, redirect
from django.conf import settings

from .models import PaymentTransaction
from .serializers import PaymentInitiateSerializer, PaymentTransactionSerializer
from apps.bookings.models import Booking


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def initiate_payment(request):
    """Initiate mock payment for booking"""
    serializer = PaymentInitiateSerializer(data=request.data, context={'request': request})
    serializer.is_valid(raise_exception=True)
    
    booking_id = serializer.validated_data['booking_id']
    booking = get_object_or_404(Booking, id=booking_id)
    
    # Create or get payment transaction
    payment, created = PaymentTransaction.objects.get_or_create(
        booking=booking,
        defaults={
            'reference_id': PaymentTransaction.generate_reference(),
            'amount': booking.amount,
            'status': 'initiated'
        }
    )
    
    # Update booking status
    booking.status = 'payment_processing'
    booking.payment_status = 'processing'
    booking.payment_reference = payment.reference_id
    booking.save()
    
    # In real implementation, this would redirect to payment gateway
    # For MVP, return mock redirect URL
    callback_url = f"{settings.ALLOWED_HOSTS[0] if not settings.DEBUG else 'http://localhost:5173'}/api/v1/payments/mock/callback/?reference={payment.reference_id}"
    
    return Response({
        'payment_id': payment.id,
        'reference_id': payment.reference_id,
        'amount': str(payment.amount),
        'redirect_url': callback_url,
        'message': 'Payment initiated. Redirect to payment gateway.',
        'mock': True
    }, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([AllowAny])
def payment_callback(request):
    """Mock payment callback - simulates payment gateway response"""
    reference = request.query_params.get('reference')
    mock_status = request.query_params.get('status', 'success')  # Default to success for MVP
    
    if not reference:
        return Response({'error': 'Missing reference'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        payment = PaymentTransaction.objects.get(reference_id=reference)
    except PaymentTransaction.DoesNotExist:
        return Response({'error': 'Payment not found'}, status=status.HTTP_404_NOT_FOUND)
    
    # Update payment status (mock)
    payment.status = mock_status
    payment.save()
    
    # Update booking
    booking = payment.booking
    
    if mock_status == 'success':
        booking.status = 'confirmed'
        booking.payment_status = 'success'
    else:
        booking.status = 'pending'
        booking.payment_status = 'failed'
    
    booking.save()
    
    # Redirect to frontend with status
    frontend_url = f"http://localhost:5173/bookings/{booking.id}?payment={mock_status}"
    return redirect(frontend_url)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def payment_status(request, reference_id):
    """Check payment status"""
    payment = get_object_or_404(PaymentTransaction, reference_id=reference_id)
    
    # Verify user has access
    if payment.booking.citizen != request.user and payment.booking.provider != request.user:
        return Response(
            {'error': 'Access denied'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    serializer = PaymentTransactionSerializer(payment)
    return Response(serializer.data)