# backend/apps/bookings/permissions.py
from rest_framework.permissions import BasePermission


class IsBookingParticipant(BasePermission):
    """Allow only citizen or provider involved in the booking"""
    
    def has_object_permission(self, request, view, obj):
        return obj.citizen == request.user or obj.provider == request.user


class IsBookingCitizen(BasePermission):
    """Allow only the citizen who created the booking"""
    
    def has_object_permission(self, request, view, obj):
        return obj.citizen == request.user


class IsBookingProvider(BasePermission):
    """Allow only the provider assigned to the booking"""
    
    def has_object_permission(self, request, view, obj):
        return obj.provider == request.user