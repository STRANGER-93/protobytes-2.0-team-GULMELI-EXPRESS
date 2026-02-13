# backend/apps/providers/urls.py
from django.urls import path
from . import views

app_name = 'providers'

urlpatterns = [
    # Provider onboarding and profile
    path('register/', views.ProviderRegisterView.as_view(), name='register'),
    path('me/', views.ProviderMeView.as_view(), name='me'),
    
    # Search and browse
    path('search/', views.ProviderSearchView.as_view(), name='search'),
    path('<int:pk>/', views.ProviderDetailView.as_view(), name='detail'),
    path('<int:pk>/stats/', views.provider_stats, name='stats'),
    
    # Municipality admin verification
    path('<int:pk>/verify/', views.ProviderVerifyView.as_view(), name='verify'),
    path('pending-verification/', views.ProviderListForVerificationView.as_view(), name='pending-verification'),
]