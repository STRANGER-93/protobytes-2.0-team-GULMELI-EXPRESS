# backend/apps/municipalities/serializers.py
from rest_framework import serializers
from .models import Municipality


class MunicipalitySerializer(serializers.ModelSerializer):
    """Municipality serializer"""
    
    class Meta:
        model = Municipality
        fields = ['id', 'name', 'district', 'province', 'created_at']
        read_only_fields = ['id', 'created_at']