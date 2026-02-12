# backend/apps/governance/urls.py
from django.urls import path
from . import views

app_name = 'governance'

urlpatterns = [
    path('dashboard/', views.municipal_dashboard, name='municipal-dashboard'),
    path('provider/dashboard/', views.provider_dashboard, name='provider-dashboard'),
]