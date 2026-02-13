# backend/apps/courses/admin.py
from django.contrib import admin
from .models import Course, Enrollment


@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ['title', 'municipality', 'start_date', 'end_date', 'capacity', 'status', 'created_at']
    list_filter = ['status', 'municipality', 'start_date']
    search_fields = ['title', 'description']
    readonly_fields = ['created_at', 'updated_at', 'created_by']
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('title', 'description', 'municipality')
        }),
        ('Schedule', {
            'fields': ('start_date', 'end_date')
        }),
        ('Capacity & Status', {
            'fields': ('capacity', 'status')
        }),
        ('Metadata', {
            'fields': ('created_by', 'created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )


@admin.register(Enrollment)
class EnrollmentAdmin(admin.ModelAdmin):
    list_display = ['provider', 'course', 'status', 'enrolled_at']
    list_filter = ['status', 'course__municipality', 'enrolled_at']
    search_fields = ['provider__name', 'provider__phone', 'course__title']
    readonly_fields = ['enrolled_at', 'updated_at']
    
    fieldsets = (
        ('Enrollment Details', {
            'fields': ('course', 'provider', 'status')
        }),
        ('Notes', {
            'fields': ('notes', 'admin_notes')
        }),
        ('Timestamps', {
            'fields': ('enrolled_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
