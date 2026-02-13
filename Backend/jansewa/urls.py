# backend/jansewa/urls.py (UPDATE - replace existing)
from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.conf.urls.static import static
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

# Swagger/OpenAPI Schema
schema_view = get_schema_view(
    openapi.Info(
        title="JanSewa API",
        default_version='v1',
        description="""
# JanSewa - Municipal Economic Infrastructure API

## Overview
JanSewa is a circular local labor economy system addressing youth unemployment, skills mismatch, 
and informal sector distrust in Nepal through a 4-layer closed loop:

1. **Skill Layer** → Certification tracking (mock CTEVT)
2. **Trust Layer** → Municipal verification + reviews + job history
3. **Market Layer** → Local bookings with mock payment
4. **Governance Layer** → Dashboard metrics for policy insights

## Authentication Flow
```
1. POST /auth/send-otp/ → {phone: "9841234567"}
2. POST /auth/verify-otp/ → {phone, otp: "123456", name, role, municipality}
3. Receive {access, refresh, user}
4. Use: Authorization: Bearer {access}
5. Refresh: POST /auth/token/refresh/ → {refresh}
```

## User Roles
- **citizen**: Search providers, create bookings, submit reviews
- **provider**: Receive bookings, complete jobs, track earnings
- **municipality_admin**: Verify providers, view economic loop metrics

## Key Endpoints by Role

### Citizens
- GET /providers/search/ - Find verified providers
- POST /bookings/create/ - Book a service
- POST /reviews/create/ - Review completed service

### Providers
- POST /providers/register/ - Complete onboarding
- GET /governance/provider/dashboard/ - View earnings & stats
- PATCH /bookings/{id}/complete/ - Mark job done

### Municipality Admins
- PATCH /providers/{id}/verify/ - Verify provider
- GET /governance/dashboard/ - View loop metrics
- GET /providers/pending-verification/ - Review pending providers

## Mock Features (MVP)
- **OTP**: Always `123456` in development
- **Payment**: Simulated gateway with auto-success
- **CTEVT**: Manual status toggle (pending/certified/not_applicable)

## Circular Economy Tracking
All bookings are tagged with `municipality_id` to track:
- Local earnings retention
- Provider job counts
- Skill demand patterns
- Verification-to-employment pipeline
        """,
        contact=openapi.Contact(email="support@jansewa.example.com"),
        license=openapi.License(name="MIT License"),
    ),
    public=True,
    permission_classes=[permissions.AllowAny],
)

urlpatterns = [
    # API Documentation
    re_path(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
    
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
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)