# backend/apps/payments/admin.py
from django.contrib import admin
from .models import PaymentTransaction


@admin.register(PaymentTransaction)
class PaymentTransactionAdmin(admin.ModelAdmin):
    list_display = [
        'reference_id', 'booking', 'amount', 'status',
        'created_at'
    ]
    list_filter = ['status', 'created_at']
    search_fields = ['reference_id', 'booking__id']
    readonly_fields = ['reference_id', 'created_at', 'updated_at']