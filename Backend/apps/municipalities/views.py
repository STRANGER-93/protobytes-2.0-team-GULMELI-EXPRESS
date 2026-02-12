# backend/apps/municipalities/views.py
from rest_framework import generics
from rest_framework.permissions import AllowAny
from .models import Municipality
from .serializers import MunicipalitySerializer


class MunicipalityListView(generics.ListAPIView):
    """List all municipalities - public endpoint for registration"""
    queryset = Municipality.objects.all()
    serializer_class = MunicipalitySerializer
    permission_classes = [AllowAny]
    pagination_class = None  # Return all municipalities


class MunicipalityDetailView(generics.RetrieveAPIView):
    """Municipality detail view"""
    queryset = Municipality.objects.all()
    serializer_class = MunicipalitySerializer
    permission_classes = [AllowAny]