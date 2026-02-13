# backend/jansewa/swagger.py
from drf_yasg import openapi
from drf_yasg.views import get_schema_view
from rest_framework import permissions

schema_view = get_schema_view(
    openapi.Info(
        title="JanSewa API",
        default_version='v1',
        description="""
# JanSewa - Municipal Economic Infrastructure API

## Overview
JanSewa is a circular local labor economy system with a 4-layer closed loop:
1. **Skill Layer** → Mock certification linkage
2. **Trust Layer** → Municipal verification + CTEVT status + reviews
3. **Market Layer** → Local-first bookings with mock payment
4. **Governance Layer** → Loop health visibility

## Authentication
All protected endpoints require JWT Bearer token authentication.

### Getting Started
1. Send OTP to phone: `POST /api/v1/auth/send-otp/`
2. Verify OTP and get tokens: `POST /api/v1/auth/verify-otp/`
3. Use access token in header: `Authorization: Bearer {access_token}`
4. Refresh token when expired: `POST /api/v1/auth/token/refresh/`

## User Roles
- **citizen**: Can search providers and create bookings
- **provider**: Can receive bookings and manage profile
- **municipality_admin**: Can verify providers and view dashboard

## Mock Features (MVP)
- OTP is always `123456` for testing
- Payment gateway is simulated
- CTEVT status is manually toggled

## Base URL
Development: `http://localhost:8000/api/v1`
        """,
        terms_of_service="https://jansewa.example.com/terms/",
        contact=openapi.Contact(email="support@jansewa.example.com"),
        license=openapi.License(name="MIT License"),
    ),
    public=True,
    permission_classes=[permissions.AllowAny],
)
