# backend/apps/providers/permissions.py
from rest_framework.permissions import BasePermission


class IsProviderOwner(BasePermission):
    """Allow only the provider who owns the profile"""
    
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user


class CanVerifyProvider(BasePermission):
    """Allow municipality admin to verify providers in their municipality"""
    
    def has_permission(self, request, view):
        return request.user.role == 'municipality_admin'
    
    def has_object_permission(self, request, view, obj):
        # Admin can only verify providers in their municipality
        return (
            request.user.role == 'municipality_admin' and
            obj.user.municipality == request.user.municipality
        )


class IsProviderUser(BasePermission):
    """Allow only users with provider role"""
    
    def has_permission(self, request, view):
        return request.user.role == 'provider'