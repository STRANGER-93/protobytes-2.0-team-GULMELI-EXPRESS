# backend/apps/courses/permissions.py
from rest_framework import permissions


class IsMunicipalityAdmin(permissions.BasePermission):
    """Allow only municipality admins"""
    
    def has_permission(self, request, view):
        return (
            request.user and
            request.user.is_authenticated and
            request.user.role == 'municipality_admin'
        )


class IsProvider(permissions.BasePermission):
    """Allow only providers"""
    
    def has_permission(self, request, view):
        return (
            request.user and
            request.user.is_authenticated and
            request.user.role == 'provider'
        )


class IsEnrollmentOwnerOrAdmin(permissions.BasePermission):
    """Allow enrollment owner (provider) or municipality admin"""
    
    def has_object_permission(self, request, view, obj):
        # Provider can view their own enrollment
        if request.user.role == 'provider':
            return obj.provider == request.user
        
        # Municipality admin can view enrollments for their courses
        if request.user.role == 'municipality_admin':
            return obj.course.municipality == request.user.municipality
        
        return False
