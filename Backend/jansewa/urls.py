# backend/jansewa/urls.py (UPDATE - replace existing)
from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.conf.urls.static import static
from rest_framework import permissions
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

urlpatterns = [
    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('swagger/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
    
    # Admin
    path('admin/', admin.site.urls),
    
    # API endpoints
    path('api/v1/auth/', include('apps.users.urls')),
    path('api/v1/municipalities/', include('apps.municipalities.urls')),
    path('api/v1/providers/', include('apps.providers.urls')),
    path('api/v1/bookings/', include('apps.bookings.urls')),
    path('api/v1/reviews/', include('apps.reviews.urls')),
    path('api/v1/payments/', include('apps.payments.urls')),
    path('api/v1/governance/', include('apps.governance.urls')),
    path('api/v1/', include('apps.courses.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)