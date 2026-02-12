# backend/apps/municipalities/urls.py
from django.urls import path
from . import views

app_name = 'municipalities'

urlpatterns = [
    path('', views.MunicipalityListView.as_view(), name='list'),
    path('<int:pk>/', views.MunicipalityDetailView.as_view(), name='detail'),
]