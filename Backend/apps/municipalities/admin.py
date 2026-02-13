# backend/apps/municipalities/admin.py
from django.contrib import admin
from .models import Municipality


@admin.register(Municipality)
class MunicipalityAdmin(admin.ModelAdmin):
    list_display = ['name', 'district', 'province', 'created_at']
    list_filter = ['province', 'district']
    search_fields = ['name', 'district']
    ordering = ['name']