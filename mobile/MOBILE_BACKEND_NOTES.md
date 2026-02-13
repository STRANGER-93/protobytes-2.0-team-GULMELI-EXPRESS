# Mobile ↔ Backend Integration Notes

This document lists backend / frontend changes (or verifications) required to fully support the mobile app.

## 1. CORS Configuration

The Django backend must allow requests from the mobile app's HTTP client. In `jansewa/settings.py`:

```python
CORS_ALLOW_ALL_ORIGINS = True   # or whitelist specific origins
CORS_ALLOW_HEADERS = ['*']
```

Ensure `django-cors-headers` is installed and `corsheaders` middleware is active.

## 2. API Base URL

The mobile app currently targets `http://127.0.0.1:8000/api/v1/` (Android emulator loopback to host). For physical‐device testing or production, update `ApiClient.baseUrl` in `lib/core/api_client.dart`.

## 3. Authentication Endpoints Used

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/users/send-otp/` | POST | Send OTP to phone |
| `/api/v1/users/verify-otp/` | POST | Verify OTP → returns JWT tokens + user |
| `/api/v1/users/token/refresh/` | POST | Refresh expired access token |
| `/api/v1/users/profile/` | GET / PATCH | Get / update current user profile |
| `/api/v1/users/profile/photo/` | PATCH (multipart) | Upload profile photo |
| `/api/v1/users/municipalities/` | GET | List municipalities for registration |

## 4. Provider Endpoints

| Endpoint | Method | Notes |
|---|---|---|
| `/api/v1/providers/` | GET | List with `?search=` and `?skill_category=` |
| `/api/v1/providers/{id}/` | GET | Provider detail |
| `/api/v1/providers/{id}/reviews/` | GET | Provider reviews |
| `/api/v1/providers/register/` | POST (multipart) | Register as provider; sends `citizenship_photo` |
| `/api/v1/providers/me/` | GET / PATCH | Current provider profile |
| `/api/v1/providers/me/stats/` | GET | Provider dashboard statistics |

**Verify** that `/providers/register/`, `/providers/me/`, and `/providers/me/stats/` exist in `apps/providers/urls.py` and return the expected shapes.

## 5. Booking Endpoints

| Endpoint | Method |
|---|---|
| `/api/v1/bookings/` | GET (list) / POST (create) |
| `/api/v1/bookings/{id}/` | GET (detail) |
| `/api/v1/bookings/{id}/accept/` | POST |
| `/api/v1/bookings/{id}/reject/` | POST |
| `/api/v1/bookings/{id}/complete/` | POST |
| `/api/v1/bookings/{id}/cancel/` | POST |

POST body fields: `provider`, `skill_category`, `description`, `location_address`, `scheduled_time`, `amount`.

## 6. Course & Enrollment Endpoints

| Endpoint | Method |
|---|---|
| `/api/v1/courses/` | GET / POST |
| `/api/v1/courses/{id}/` | GET / PATCH / DELETE |
| `/api/v1/courses/{id}/enroll/` | POST |
| `/api/v1/courses/{id}/enrollments/` | GET |
| `/api/v1/enrollments/{id}/approve/` | POST |
| `/api/v1/enrollments/{id}/reject/` | POST |
| `/api/v1/enrollments/my/` | GET |

## 7. Payment Endpoints

| Endpoint | Method |
|---|---|
| `/api/v1/payments/initiate/` | POST `{ booking_id }` |
| `/api/v1/payments/verify/` | POST `{ transaction_id, idx, amount, status }` |
| `/api/v1/payments/history/` | GET |
| `/api/v1/payments/booking/{id}/` | GET |

The web frontend redirects to an eSewa payment page. The mobile app should use an in‐app WebView or deep‐link for the payment flow, then poll `/payments/verify/` with the returned transaction details.

## 8. Review Endpoints

| Endpoint | Method |
|---|---|
| `/api/v1/reviews/` | POST `{ booking, rating, comment }` |
| `/api/v1/reviews/my/` | GET |
| `/api/v1/reviews/{id}/respond/` | POST `{ provider_response }` |

## 9. Governance Endpoints

| Endpoint | Method |
|---|---|
| `/api/v1/governance/dashboard/` | GET |
| `/api/v1/governance/providers/pending/` | GET |
| `/api/v1/governance/providers/{id}/verify/` | POST |

## 10. Media Files

Uploaded images (profile photos, citizenship docs) are served from Django's `MEDIA_URL`. Ensure:

- `MEDIA_URL = '/media/'` in settings
- `MEDIA_ROOT` is configured
- Media files are served in development via `urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)`

The mobile app prepends the base URL to relative image paths.

## 11. Android Permissions

Already configured in `AndroidManifest.xml`:
- `INTERNET` — API calls
- `CAMERA` — profile photo capture
- `android:usesCleartextTraffic="true"` — allows HTTP during development

## 12. Dev OTP

During development the backend accepts OTP `123456` for any phone number (configured in `apps/users/views.py`). Remove this before production.

---

## 13. Session 3 — New Screens & Wiring (Latest)

### New Files Created

| File | Purpose |
|---|---|
| `lib/features/citizen/screens/citizen_booking_detail_screen.dart` | Full booking lifecycle: view details, manage status (confirm/reject/complete/cancel), initiate & verify payment, submit review with 5-star rating |
| `lib/features/citizen/screens/provider_onboarding_screen.dart` | 3-step provider registration (skill selection → profile → document upload) via `ProviderService.registerProvider()` with multipart |

### Routes Added

| Route | Screen |
|---|---|
| `/citizen/booking-detail` | `CitizenBookingDetailScreen` — accepts booking ID or Booking object as argument |
| `/citizen/provider-onboarding` | `ProviderOnboardingScreen` — returns `true` on successful registration |

### Files Modified

| File | Changes |
|---|---|
| `citizen_bookings_screen.dart` | Booking cards wrapped in GestureDetector → navigates to booking detail, refreshes on return |
| `citizen_dashboard_screen.dart` | Booking tiles wrapped in GestureDetector → navigates to booking detail, refreshes on return |
| `citizen_profile_screen.dart` | Converted to StatefulWidget; added "Become a Provider" button → navigates to provider onboarding; dead buttons now show "coming soon" snackbar |
| `gov_training_management_screen.dart` | Replaced `MockData.courses` with `CourseService.getCourses()` API call; replaced `c.level` with `c.status`, `c.instructor` with date range; wired Edit (dialog + `updateCourse`), Delete (confirm dialog + `deleteCourse`), New Course FAB (create dialog + `createCourse`) |
| `gov_user_management_screen.dart` | Added loading state using `_isLoading` field |
| `routes.dart` | Added imports + route cases for booking-detail and provider-onboarding |

### Backend Endpoints Exercised by New Screens

| Endpoint | Used By |
|---|---|
| `GET /bookings/{id}/` | BookingDetailScreen — load booking |
| `POST /bookings/{id}/confirm/` | BookingDetailScreen — provider confirms |
| `POST /bookings/{id}/complete/` | BookingDetailScreen — provider completes |
| `POST /bookings/{id}/cancel/` | BookingDetailScreen — citizen cancels with reason |
| `GET /payments/booking/{id}/` | BookingDetailScreen — load payment status |
| `POST /payments/initiate/` | BookingDetailScreen — initiate payment |
| `POST /payments/verify/` | BookingDetailScreen — verify payment |
| `POST /reviews/` | BookingDetailScreen — submit review |
| `POST /providers/register/` (multipart) | ProviderOnboardingScreen — register as provider |
| `GET /courses/` | GovTrainingManagementScreen — list courses |
| `POST /courses/` | GovTrainingManagementScreen — create course |
| `PATCH /courses/{id}/` | GovTrainingManagementScreen — edit course |
| `DELETE /courses/{id}/` | GovTrainingManagementScreen — delete course |

### Backend Action Items

1. **Verify booking action endpoints** exist as `/bookings/{id}/confirm/`, `/bookings/{id}/complete/`, `/bookings/{id}/cancel/` (the mobile service posts `action` field to `/bookings/{id}/{action}/`)
2. **Verify `reject` action** — BookingDetailScreen calls `/bookings/{id}/reject/`; ensure the backend view handles this
3. **Payment mock gateway** — the mobile app simulates a 2-second payment gateway delay then calls verify; ensure `/payments/verify/` accepts `{ reference_id, status: 'success' }` shape
4. **Provider register multipart** — ensure `/providers/register/` accepts `skill_categories` (comma-separated), `bio`, `experience_years`, `citizenship_photo` (file), `ctevt_certificate` (file, optional), `ctevt_status`
