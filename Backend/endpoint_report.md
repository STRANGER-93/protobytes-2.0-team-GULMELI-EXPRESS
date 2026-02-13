| METHOD | FULL URL | AUTH REQUIRED | SERIALIZER | PERMISSIONS |
|---|---|---|---|---|
| GET | http://127.0.0.1:8000/api/v1/bookings/ | JWT | BookingListSerializer | IsAuthenticated |
| POST | http://127.0.0.1:8000/api/v1/bookings/create/ | JWT | BookingCreateSerializer | IsAuthenticated, IsCitizen |
| GET | http://127.0.0.1:8000/api/v1/bookings/<int:pk>/ | JWT | BookingSerializer | IsAuthenticated, IsBookingParticipant |
| GET | http://127.0.0.1:8000/api/v1/bookings/<int:pk>/confirm/ | None | - | None |
| GET | http://127.0.0.1:8000/api/v1/bookings/<int:pk>/complete/ | None | - | None |
| GET | http://127.0.0.1:8000/api/v1/bookings/<int:pk>/cancel/ | None | - | None |
| GET | http://127.0.0.1:8000/api/v1/governance/dashboard/ | None | - | None |
| GET | http://127.0.0.1:8000/api/v1/governance/provider/dashboard/ | None | - | None |
| GET | http://127.0.0.1:8000/api/v1/municipalities/ | None | MunicipalitySerializer | AllowAny |
| GET | http://127.0.0.1:8000/api/v1/municipalities/<int:pk>/ | None | MunicipalitySerializer | AllowAny |
| GET | http://127.0.0.1:8000/api/v1/payments/mock/initiate/ | None | - | None |
| GET | http://127.0.0.1:8000/api/v1/payments/mock/callback/ | None | - | None |
| GET | http://127.0.0.1:8000/api/v1/payments/status/<str:reference_id>/ | None | - | None |
| POST | http://127.0.0.1:8000/api/v1/providers/register/ | JWT | ProviderRegistrationSerializer | IsAuthenticated, IsProviderUser |
| GET | http://127.0.0.1:8000/api/v1/providers/me/ | JWT | - | IsAuthenticated, IsProviderUser |
| GET | http://127.0.0.1:8000/api/v1/providers/search/ | JWT | ProviderListSerializer | IsAuthenticated |
| GET | http://127.0.0.1:8000/api/v1/providers/<int:pk>/ | JWT | ProviderProfileSerializer | IsAuthenticated |
| GET | http://127.0.0.1:8000/api/v1/providers/<int:pk>/stats/ | None | - | None |
| GET | http://127.0.0.1:8000/api/v1/providers/<int:pk>/verify/ | JWT | ProviderVerificationSerializer | IsAuthenticated, CanVerifyProvider |
| GET | http://127.0.0.1:8000/api/v1/providers/pending-verification/ | JWT | ProviderListSerializer | IsAuthenticated, CanVerifyProvider |
| GET | http://127.0.0.1:8000/api/v1/reviews/ | JWT | ReviewListSerializer | IsAuthenticated |
| POST | http://127.0.0.1:8000/api/v1/reviews/create/ | JWT | ReviewCreateSerializer | IsAuthenticated, IsCitizen |
| GET | http://127.0.0.1:8000/api/v1/reviews/<int:pk>/ | JWT | ReviewSerializer | IsAuthenticated |
| GET | http://127.0.0.1:8000/api/v1/auth/send-otp/ | None | - | None |
| GET | http://127.0.0.1:8000/api/v1/auth/verify-otp/ | None | - | None |
| GET | http://127.0.0.1:8000/api/v1/auth/token/refresh/ | None | api_settings | None |
| GET | http://127.0.0.1:8000/api/v1/auth/me/ | JWT | UserSerializer | IsAuthenticated |
| GET | http://127.0.0.1:8000/api/v1/auth/profile/ | JWT | UserSerializer | IsAuthenticated |
| GET | http://127.0.0.1:8000/swagger/ | None | - | None |
| GET | http://127.0.0.1:8000/redoc/ | None | - | None |
| GET | http://127.0.0.1:8000/admin/ | None | - | None |
| GET | http://127.0.0.1:8000/login/ | None | - | None |
| GET | http://127.0.0.1:8000/logout/ | None | - | None |
| GET | http://127.0.0.1:8000/password_change/ | None | - | None |
| GET | http://127.0.0.1:8000/password_change/done/ | None | - | None |
| GET | http://127.0.0.1:8000/password_reset/ | None | - | None |
| GET | http://127.0.0.1:8000/password_reset/done/ | None | - | None |
| GET | http://127.0.0.1:8000/reset/<uidb64>/<token>/ | None | - | None |
| GET | http://127.0.0.1:8000/reset/done/ | None | - | None |
| GET | http://127.0.0.1:8000/<path:url> | None | - | None |