# backend/apps/reviews/admin.py
from django.contrib import admin
from .models import Review


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = [
        'id', 'provider', 'reviewer', 'rating', 'created_at'
    ]
    list_filter = ['rating', 'created_at']
    search_fields = ['provider__name', 'reviewer__name', 'comment']
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Review Info', {
            'fields': ('booking', 'provider', 'reviewer', 'rating', 'comment')
        }),
        ('Provider Response', {
            'fields': ('provider_response', 'responded_at')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )