# backend/apps/bookings/admin.py
from django.contrib import admin
from django.utils.html import format_html
from .models import Booking


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = [
        'id', 'citizen', 'provider', 'municipality', 'skill_category',
        'status_badge', 'amount', 'payment_status', 'scheduled_time', 'created_at'
    ]
    list_filter = [
        'status', 'payment_status', 'municipality', 'skill_category', 'created_at'
    ]
    search_fields = [
        'citizen__name', 'provider__name', 'description', 'location_address'
    ]
    readonly_fields = [
        'created_at', 'updated_at', 'completed_at', 'cancelled_at'
    ]
    
    fieldsets = (
        ('Participants', {
            'fields': ('citizen', 'provider', 'municipality')
        }),
        ('Service Details', {
            'fields': ('skill_category', 'scheduled_time', 'description', 'location_address')
        }),
        ('Payment', {
            'fields': ('amount', 'payment_status', 'payment_reference')
        }),
        ('Status', {
            'fields': ('status',)
        }),
        ('Completion', {
            'fields': ('completed_at', 'completion_notes')
        }),
        ('Cancellation', {
            'fields': ('cancelled_at', 'cancelled_by', 'cancellation_reason')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )
    
    def status_badge(self, obj):
        colors = {
            'pending': 'orange',
            'payment_processing': 'blue',
            'confirmed': 'green',
            'completed': 'darkgreen',
            'cancelled': 'red',
        }
        color = colors.get(obj.status, 'gray')
        return format_html(
            '<span style="color: {}; font-weight: bold;">{}</span>',
            color, obj.get_status_display()
        )
    status_badge.short_description = 'Status'