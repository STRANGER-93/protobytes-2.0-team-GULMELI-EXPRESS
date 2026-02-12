# backend/apps/payments/urls.py
from django.urls import path
from . import views

app_name = 'payments'

urlpatterns = [
    # Mock payment endpoints
    path('mock/initiate/', views.initiate_payment, name='initiate'),
    path('mock/callback/', views.payment_callback, name='callback'),
    path('status/<str:reference_id>/', views.payment_status, name='status'),
]