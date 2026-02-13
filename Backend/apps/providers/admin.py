# backend/apps/providers/admin.py
from django.contrib import admin
from django.utils.html import format_html
from .models import ProviderProfile


@admin.register(ProviderProfile)
class ProviderProfileAdmin(admin.ModelAdmin):
    list_display = [
        'user', 'get_municipality', 'municipality_verified',
        'ctevt_status', 'avg_rating', 'jobs_completed', 'created_at'
    ]
    list_filter = [
        'municipality_verified', 'ctevt_status', 'is_active',
        'user__municipality', 'created_at'
    ]
    search_fields = ['user__name', 'user__phone', 'bio']
    readonly_fields = [
        'avg_rating', 'jobs_completed', 'total_earnings',
        'verified_at', 'created_at', 'updated_at', 'trust_score_display'
    ]
    
    fieldsets = (
        ('User Info', {
            'fields': ('user',)
        }),
        ('Skills & Experience', {
            'fields': ('skill_categories', 'bio', 'experience_years')
        }),
        ('Documents', {
            'fields': ('citizenship_photo', 'ctevt_certificate_upload', 'ctevt_certificate_link')
        }),
        ('Verification (Municipal)', {
            'fields': ('municipality_verified', 'verified_at', 'verified_by', 'verification_notes')
        }),
        ('CTEVT Status', {
            'fields': ('ctevt_status',)
        }),
        ('Performance Metrics', {
            'fields': ('avg_rating', 'jobs_completed', 'total_earnings', 'trust_score_display')
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )
    
    actions = ['mark_as_verified', 'mark_as_ctevt_certified']
    
    def get_municipality(self, obj):
        return obj.user.municipality.name
    get_municipality.short_description = 'Municipality'
    
    def trust_score_display(self, obj):
        score = obj.trust_score
        if score >= 80:
            color = 'green'
        elif score >= 50:
            color = 'orange'
        else:
            color = 'red'
        return format_html(
            '<span style="color: {}; font-weight: bold;">{}/100</span>',
            color, score
        )
    trust_score_display.short_description = 'Trust Score'
    
    def mark_as_verified(self, request, queryset):
        """Admin action to verify providers"""
        updated = queryset.update(
            municipality_verified=True,
            verified_by=request.user
        )
        self.message_user(request, f'{updated} provider(s) marked as verified.')
    mark_as_verified.short_description = 'Mark as Municipality Verified'
    
    def mark_as_ctevt_certified(self, request, queryset):
        """Admin action to mark as CTEVT certified"""
        updated = queryset.update(ctevt_status='certified')
        self.message_user(request, f'{updated} provider(s) marked as CTEVT Certified.')
    mark_as_ctevt_certified.short_description = 'Mark as CTEVT Certified'