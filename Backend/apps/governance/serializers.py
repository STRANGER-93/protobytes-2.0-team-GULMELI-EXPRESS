# backend/apps/governance/serializers.py
from rest_framework import serializers


class MunicipalDashboardSerializer(serializers.Serializer):
    """Serializer for municipal dashboard data (documentation only)"""
    municipality = serializers.DictField()
    period = serializers.CharField()
    providers = serializers.DictField()
    bookings = serializers.DictField()
    earnings = serializers.DictField()
    top_skills = serializers.ListField()
    recent_activity = serializers.ListField()
    monthly_trend = serializers.ListField()


class ProviderDashboardSerializer(serializers.Serializer):
    """Serializer for provider dashboard data (documentation only)"""
    profile = serializers.DictField()
    stats = serializers.DictField()
    verification = serializers.DictField()
    pending_bookings = serializers.IntegerField()
    recent_bookings = serializers.ListField()
    monthly_earnings = serializers.ListField()
    skill_breakdown = serializers.ListField()