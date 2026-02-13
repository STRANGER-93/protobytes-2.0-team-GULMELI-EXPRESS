TEAM INFORMATION:

TEAM NAME: GULEMELI EXPRESS


TEAM MEMBERS:

Prashant Nayak - prashant.080bct49@acem.edu.np - https://github.com/Debugger-Eeinstein
Saksham Bhujel - bsaksham17@gmail.com - https://github.com/STRANGER-93
Abdesh Shah - abdheshshah111@gmail.com - https://github.com/abdhesh369
Suwash Adhikari -suwash.080bct80@acem.edu.np - https://github.com/suwash99


PROJECT DETAILS:

Project Name: JanSewa
Category: Open Innovation


Problem Statement: 

In Nepal's municipalities, high youth unemployment (around 19-21%) fuels frustration and drives mass out-migration due to persistent skill gaps and a lack of viable local opportunities. The predominance of informal labor (84-90% of employment) erodes trust through unverified providers, unreliable services, and low earnings, while municipalities suffer from zero economic visibility—unable to track local income flows, skill demands, or policy impacts—resulting in fragmented growth and value leakage to urban or foreign markets.


Solution Overview: 

JanSewa is a Municipal Economic Infrastructure Platform that builds a circular local labor economy through a 4-layer system: 

    (1) Skill Layer for training, certifying, and upgrading youth abilities; 
    (2) Trust Layer for verifying, rating, and badging providers to foster safety and reliability; 
    (3) Market Layer for connecting, booking, paying, and repeating local services; and 
    (4) Governance Layer for measuring, analyzing, and improving policies via data-driven insights.

This closed-loop model (training → certified work → local earnings → analytics → targeted upgrades) retains income locally, formalizes informal labor, closes skill gaps, and provides municipalities with dashboards for economic planning—empowering youth, building community trust, and driving sustainable growth.


TECHNICAL STACK:

Frontend            :   React
Backend             :   Django
Database            :   postgresql
Other Technologies  :   


INSTALLATION & SETUP:

# JanSewa Phase 1: Foundation

## Features Implemented
- ✅ Custom User model with phone-based authentication
- ✅ Mocked OTP authentication (OTP: 123456)
- ✅ JWT token authentication with auto-refresh
- ✅ Role-based access (citizen, provider, municipality_admin)
- ✅ Municipality master data
- ✅ User profile management
- ✅ Complete API service layer
- ✅ Auth context for global state
- ✅ Minimal CSS design system

## Backend Setup

1. Create virtual environment:
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Create PostgreSQL database:
```bash
createdb jansewa_db
```

4. Configure environment:
```bash
cp .env.example .env
# Edit .env with your settings
```

5. Run migrations:
```bash
python manage.py makemigrations
python manage.py migrate
```

6. Load municipality fixtures:
```bash
python manage.py loaddata apps/municipalities/fixtures/municipalities.json
```

7. Create superuser:
```bash
python manage.py createsuperuser
```

8. Run server:
```bash
python manage.py runserver
```

## Frontend Setup

1. Install dependencies:
```bash
cd frontend
npm install
```

2. Configure environment:
```bash
cp .env.example .env
# Default should work: VITE_API_BASE_URL=http://localhost:8000/api/v1
```

3. Run development server:
```bash
npm run dev
```

Visit: http://localhost:5173

## Testing Phase 1

1. Register new user:
   - Phone: 9841234567
   - Name: Test User
   - Role: Citizen
   - Municipality: Kathmandu Metropolitan
   - OTP: 123456

2. Login with phone and OTP

3. View profile at /profile

4. Test token refresh (JWT auto-refreshes on 401)

## API Endpoints

- POST /api/v1/auth/send-otp/
- POST /api/v1/auth/verify-otp/
- POST /api/v1/auth/token/refresh/
- GET /api/v1/auth/me/
- PATCH /api/v1/auth/me/
- GET /api/v1/municipalities/

# JanSewa Phase 2: Trust Layer

## New Features
- ✅ Provider profile with skills and documents
- ✅ Municipal verification workflow
- ✅ Trust badges (verification, CTEVT, ratings, jobs)
- ✅ Provider search with filters
- ✅ Provider detail pages
- ✅ Admin verification interface
- ✅ Trust score calculation

## Setup (from Phase 1)

1. Copy Phase 1 to Phase 2 folder
2. Add new files (see file list above)
3. Run migrations:
```bash
cd backend
python manage.py makemigrations providers
python manage.py migrate
```

4. Create test admin user:
```bash
python manage.py shell
```
```python
from apps.users.models import User
from apps.municipalities.models import Municipality

muni = Municipality.objects.first()
admin = User.objects.create_user(
    phone='9840000000',
    name='Municipality Admin',
    municipality=muni,
    role='municipality_admin'
)
admin.set_password('admin123')
admin.is_staff = True
admin.save()
```

## Testing Phase 2

1. Register as provider
2. Complete onboarding with skills and citizenship photo
3. Login as admin (phone: 9840000000, OTP: 123456)
4. Verify the provider at /admin/providers
5. Login as citizen
6. Search providers at /providers/search
7. View verified provider with trust badges

## New API Endpoints

- POST /api/v1/providers/register/
- GET /api/v1/providers/me/
- PATCH /api/v1/providers/me/
- GET /api/v1/providers/search/
- GET /api/v1/providers/{id}/
- PATCH /api/v1/providers/{id}/verify/
- GET /api/v1/providers/pending-verification/

# JanSewa Phase 3: Market Layer

## New Features
- ✅ Booking creation with service details
- ✅ Mock payment flow with callbacks
- ✅ Booking lifecycle management
- ✅ Provider earnings tracking
- ✅ Booking completion workflow
- ✅ Cancellation with reasons
- ✅ Municipality tagging for local tracking

## Setup (from Phase 2)

1. Copy Phase 2 to Phase 3 folder
2. Add new booking and payment files
3. Run migrations:
```bash
cd backend
python manage.py makemigrations bookings payments
python manage.py migrate
```

## Testing Phase 3

### Complete Flow Test:

1. **Citizen creates booking**:
   - Search verified provider
   - Click "Book This Provider"
   - Fill service details and amount
   - Submit → Mock payment initiated
   - Auto-redirect → Payment success → Booking confirmed

2. **Provider completes job**:
   - View bookings (status: confirmed)
   - Mark as completed
   - Check earnings updated

3. **Verify circular loop**:
   - Booking tagged with municipality
   - Earnings retained locally
   - Jobs completed count updated

## New API Endpoints

### Bookings
- POST /api/v1/bookings/create/
- GET /api/v1/bookings/
- GET /api/v1/bookings/{id}/
- PATCH /api/v1/bookings/{id}/confirm/
- PATCH /api/v1/bookings/{id}/complete/
- PATCH /api/v1/bookings/{id}/cancel/

### Payments
- POST /api/v1/payments/mock/initiate/
- GET /api/v1/payments/mock/callback/
- GET /api/v1/payments/status/{reference_id}/

## Mock Payment Flow

1. Citizen submits booking with amount
2. Frontend calls `/payments/mock/initiate/`
3. Backend creates PaymentTransaction with unique reference
4. Frontend shows "Processing payment..." (1.5s delay)
5. Auto-redirect to `/payments/mock/callback/?reference=XXX&status=success`
6. Backend updates booking status to "confirmed"
7. Redirect to booking detail page

# JanSewa Phase 4: Feedback Loop - COMPLETE MVP

## New Features
- ✅ Review system with star ratings
- ✅ Automatic rating calculation
- ✅ Provider dashboard (earnings, trends, stats)
- ✅ Municipal dashboard (circular economy metrics)
- ✅ Admin verification interface
- ✅ Profile management
- ✅ Header/Footer layout
- ✅ Complete navigation system

## Setup (from Phase 3)

1. Copy Phase 3 to Phase 4 folder
2. Add review, governance, and UI files
3. Run migrations:
```bash
cd backend
python manage.py makemigrations reviews
python manage.py migrate
```

## Testing Complete System

### Full Circular Loop Verification:

1. **Skill Layer**:
   - Provider registers with skills
   - Uploads citizenship and CTEVT cert (optional)

2. **Trust Layer**:
   - Admin verifies provider
   - Trust badges display
   - Provider searchable by citizens

3. **Market Layer**:
   - Citizen books provider
   - Mock payment confirms booking
   - Provider completes service
   - Earnings auto-update

4. **Feedback Loop**:
   - Citizen reviews provider
   - Rating updates provider profile
   - Municipal dashboard shows metrics

5. **Governance Visibility**:
   - Admin dashboard shows:
     * Verified providers count
     * Completed bookings count
     * Total local earnings
     * Top skill categories
     * Monthly trends
     * Provider retention rate

## New API Endpoints

### Reviews
- POST /api/v1/reviews/create/
- GET /api/v1/reviews/
- GET /api/v1/reviews/{id}/

### Governance
- GET /api/v1/governance/dashboard/
- GET /api/v1/governance/provider/dashboard/

### Users
- GET /api/v1/auth/profile/
- PATCH /api/v1/auth/profile/

## Dashboard Metrics Explained

### Municipal Dashboard
- **Verified Providers**: Trust layer working
- **Completed Bookings**: Market transactions happening
- **Local Earnings**: Money retained in municipality
- **Top Skills**: Demand signals for training programs
- **Retention Rate**: Providers with 3+ jobs (sustainability)

### Provider Dashboard
- **Total Earnings**: Cumulative from completed jobs
- **Average Rating**: Trust feedback score
- **Trust Score**: 0-100 composite metric
- **Monthly Trend**: Earnings and jobs over time
- **Skill Breakdown**: Performance by service type

## Production Deployment Checklist

- [ ] Set DEBUG=False
- [ ] Configure production database
- [ ] Set strong SECRET_KEY
- [ ] Configure ALLOWED_HOSTS
- [ ] Setup real SMS OTP service
- [ ] Integrate real payment gateway
- [ ] Setup media file storage (S3/CDN)
- [ ] Configure SSL/HTTPS
- [ ] Setup logging
- [ ] Configure backups
- [ ] Performance optimization (caching, indexes)
- [ ] Security audit
- [ ] Load testing

## MVP Complete! 🎉

The JanSewa system is now fully functional as Municipal Economic Infrastructure:
- Circular economy loop working
- Traceability from skill → earnings
- Policy insights for evidence-based decisions
- Ready for pilot deployment

