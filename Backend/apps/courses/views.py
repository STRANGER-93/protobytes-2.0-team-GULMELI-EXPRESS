# backend/apps/courses/views.py
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.db.models import Q

from .models import Course, Enrollment
from .serializers import (
    CourseSerializer, CourseListSerializer, CourseCreateSerializer,
    EnrollmentSerializer, EnrollmentCreateSerializer, EnrollmentUpdateSerializer
)
from .permissions import IsMunicipalityAdmin, IsProvider, IsEnrollmentOwnerOrAdmin


class CourseViewSet(viewsets.ModelViewSet):
    """Course management viewset"""
    queryset = Course.objects.all()
    
    def get_serializer_class(self):
        if self.action == 'list':
            return CourseListSerializer
        elif self.action == 'create':
            return CourseCreateSerializer
        return CourseSerializer
    
    def get_permissions(self):
        """
        - list/retrieve: Anyone (for homepage)
        - create/update/destroy: Municipality admin only
        """
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAuthenticated(), IsMunicipalityAdmin()]
    
    def get_queryset(self):
        queryset = Course.objects.select_related('municipality', 'created_by')
        
        # Filter by municipality if provided
        municipality_id = self.request.query_params.get('municipality')
        if municipality_id:
            queryset = queryset.filter(municipality_id=municipality_id)
        
        # Filter by status
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        # Municipality admin sees only their courses
        if self.request.user.is_authenticated and self.request.user.role == 'municipality_admin':
            queryset = queryset.filter(municipality=self.request.user.municipality)
        
        return queryset
    
    def perform_create(self, serializer):
        """Ensure municipality matches admin's municipality"""
        user = self.request.user
        serializer.save(
            created_by=user,
            municipality=user.municipality
        )


class EnrollmentViewSet(viewsets.ModelViewSet):
    """Enrollment management viewset"""
    queryset = Enrollment.objects.all()
    
    def get_serializer_class(self):
        if self.action == 'create':
            return EnrollmentCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return EnrollmentUpdateSerializer
        return EnrollmentSerializer
    
    def get_permissions(self):
        """
        - list: Authenticated (providers see their own, admins see their courses)
        - create: Provider only
        - update: Municipality admin only
        - retrieve: Owner or admin
        """
        if self.action == 'create':
            return [IsAuthenticated(), IsProvider()]
        elif self.action in ['update', 'partial_update']:
            return [IsAuthenticated(), IsMunicipalityAdmin()]
        elif self.action == 'retrieve':
            return [IsAuthenticated(), IsEnrollmentOwnerOrAdmin()]
        return [IsAuthenticated()]
    
    def get_queryset(self):
        user = self.request.user
        queryset = Enrollment.objects.select_related('course', 'provider')
        
        if user.role == 'provider':
            # Providers see only their enrollments
            queryset = queryset.filter(provider=user)
        elif user.role == 'municipality_admin':
            # Admins see enrollments for their courses
            queryset = queryset.filter(course__municipality=user.municipality)
        else:
            # Citizens see nothing
            queryset = queryset.none()
        
        # Filter by course
        course_id = self.request.query_params.get('course')
        if course_id:
            queryset = queryset.filter(course_id=course_id)
        
        # Filter by status
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        return queryset
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated, IsProvider])
    def withdraw(self, request, pk=None):
        """Provider withdraws from course"""
        enrollment = self.get_object()
        
        if enrollment.provider != request.user:
            return Response(
                {'error': 'You can only withdraw your own enrollment'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if enrollment.status == 'withdrawn':
            return Response(
                {'error': 'Enrollment already withdrawn'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        enrollment.status = 'withdrawn'
        enrollment.save()
        
        serializer = self.get_serializer(enrollment)
        return Response(serializer.data)
