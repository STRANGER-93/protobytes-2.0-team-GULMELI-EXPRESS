# backend/apps/bookings/urls.py
from django.urls import path
from . import views

app_name = 'bookings'

urlpatterns = [
    # Booking CRUD
    path('', views.BookingListView.as_view(), name='list'),
    path('create/', views.BookingCreateView.as_view(), name='create'),
    path('<int:pk>/', views.BookingDetailView.as_view(), name='detail'),
    
    # Booking actions
    path('<int:pk>/confirm/', views.confirm_booking, name='confirm'),
    path('<int:pk>/complete/', views.complete_booking, name='complete'),
    path('<int:pk>/cancel/', views.cancel_booking, name='cancel'),
]