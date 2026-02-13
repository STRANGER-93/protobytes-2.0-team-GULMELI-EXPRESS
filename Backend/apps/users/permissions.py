# backend/apps/users/permissions.py
from rest_framework.permissions import BasePermission


class IsCitizen(BasePermission):
    """Allow only citizens"""
    
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.role == 'citizen'


class IsProvider(BasePermission):
    """Allow only providers"""
    
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.role == 'provider'


class IsMunicipalityAdmin(BasePermission):
    """Allow only municipality admins"""
    
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.role == 'municipality_admin'


class IsOwnerOrAdmin(BasePermission):
    """Allow owner of object or municipality admin"""
    
    def has_object_permission(self, request, view, obj):
        if request.user.role == 'municipality_admin':
            return True
        # Check if object has 'user' attribute
        if hasattr(obj, 'user'):
            return obj.user == request.user
        # For User objects
        return obj == request.user