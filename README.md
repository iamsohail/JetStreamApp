# JetStream

iOS flight tracking app with real-time status, flight search, and personal aviation analytics.

## Architecture

- **iOS**: SwiftUI + Firebase Auth (Email, Google, Apple) — all data from backend API
- **Backend**: Node.js/TypeScript microservices + PostgreSQL + Redis + Nginx gateway
- **External APIs**: AviationStack (flight search & real-time status), Amadeus (airport/flight reference data)

## Project Structure

```
JetStreamApp/
├── ios/                          # iOS app (SwiftUI, iOS 17+)
│   ├── project.yml               # XcodeGen config
│   ├── JetStream/
│   │   ├── App/                  # Entry point, ContentView, config
│   │   ├── Models/               # SwiftData models (local cache)
│   │   ├── Views/
│   │   │   ├── Auth/             # SignInView (Email, Google, Apple)
│   │   │   ├── Dashboard/        # DashboardView (stats + upcoming flights)
│   │   │   ├── Flights/          # FlightList, FlightDetail, AddFlight, FlightSearch
│   │   │   ├── Analytics/        # AnalyticsView (charts, records)
│   │   │   ├── Profile/          # ProfileView
│   │   │   └── Components/       # FlightCard, StatCard
│   │   ├── Services/             # AuthenticationService, FlightService
│   │   ├── Core/Network/         # APIClient (auto token refresh), Endpoints, Keychain
│   │   ├── Utilities/            # Theme, Constants, Extensions
│   │   └── Resources/            # Assets, LaunchScreen
│   ├── JetStreamTests/
│   └── JetStreamUITests/
├── backend/
│   ├── docker-compose.yml        # Postgres, Redis, Nginx, 2 services
│   ├── gateway/nginx.conf        # API gateway routing
│   ├── shared/database/          # Connection pool, migrations (auto-run on startup)
│   └── services/
│       ├── user-service/         # Auth (Firebase Admin), profiles (port 3001)
│       └── flight-service/       # Flight CRUD, search, analytics (port 3002)
└── .env.example
```

## Setup

### Prerequisites
1. **Firebase project**: Enable Email/Password + Google + Apple sign-in, download `GoogleService-Info.plist`
2. **AviationStack API key**: Free at aviationstack.com (100 calls/month)
3. **Amadeus API keys**: Free at developers.amadeus.com (500 calls/month)

### iOS
```bash
cd ios
xcodegen generate
open JetStream.xcodeproj
# Add GoogleService-Info.plist to ios/JetStream/
# Build and run (iOS 17+)
```

### Backend
```bash
cd backend
cp .env.example .env
# Fill in: FIREBASE_PROJECT_ID, AVIATIONSTACK_API_KEY, AMADEUS_CLIENT_ID, AMADEUS_CLIENT_SECRET
docker-compose up --build -d
# Verify: curl http://localhost:3000/health
```

Database tables are created automatically on first startup via mounted migration files.

## API Endpoints

| Service | Port | Routes |
|---------|------|--------|
| Gateway | 3000 | Nginx reverse proxy |
| User | 3001 | `/api/v1/auth/*`, `/api/v1/users/*` |
| Flight | 3002 | `/api/v1/flights/*`, `/api/v1/analytics/*`, `/api/v1/airports/*`, `/api/v1/airlines/*` |

### Key Endpoints
- `POST /api/v1/auth/social` — Firebase token → backend JWT exchange
- `POST /api/v1/flights/search-by-number` — Search flights by number + date
- `GET /api/v1/flights` — List user's flights (paginated)
- `POST /api/v1/flights` — Add flight (manual or from search)
- `GET /api/v1/flights/:id/status` — Real-time flight status
- `GET /api/v1/analytics/summary` — Total flights, distance, hours
- `GET /api/v1/analytics/airlines` — Breakdown by airline
- `GET /api/v1/analytics/airports` — Most visited airports
- `GET /api/v1/analytics/records` — Longest/shortest/most frequent routes

## Auth Flow
1. User signs in via Firebase Auth (Email, Google, or Apple) on iOS
2. iOS exchanges Firebase ID token for backend JWT pair (`POST /auth/social`)
3. JWT access + refresh tokens stored in Keychain
4. APIClient auto-refreshes expired tokens on 401 responses

## Current Status

- [x] Project scaffold (iOS + Backend)
- [x] Database schema & auto-migration on Docker startup
- [x] Docker build with shared module support
- [x] Firebase Auth (Email, Google, Apple) on iOS
- [x] Firebase Admin SDK token verification on backend
- [x] iOS ↔ Backend JWT auth flow with auto token refresh
- [x] Flight search by number (AviationStack)
- [x] Flight CRUD (create, list, detail, delete) wired to backend API
- [x] Manual flight entry
- [x] Dashboard with live stats from backend analytics
- [x] Analytics with airline charts (Swift Charts), top airports, records
- [x] Profile view wired to backend
- [x] Loading, error, and empty states across all views
- [x] Pull-to-refresh on all data views
- [x] Airport & airline search endpoints

## Bundle ID
`com.iamsohail.JetStream`

## Min iOS Version
17.0
