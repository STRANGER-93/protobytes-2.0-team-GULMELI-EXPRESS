from rest_framework.permissions import BasePermission

#permissions.py

class IsCitizen(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'citizen'

class IsProvider(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'provider'

class IsMunicipalityAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'municipality_admin'

class IsOwnerOrAdmin(BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.user.role == 'municipality_admin':
            return True
        return obj.user == request.user