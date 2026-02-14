# JetStream — Session Notes

## Session 1: Project Scaffold (2026-02-14)

### What was done
- Created full iOS app structure with 26 Swift files
  - SwiftUI views: SignIn, Dashboard, FlightList, FlightDetail, AddFlight, PNRLookup, Analytics, Profile
  - SwiftData model: Flight (with FlightStatus/CabinClass enums, computed properties)
  - Codable models: Airport, Airline
  - Services: AuthenticationService (Firebase Auth), FlightService (API calls)
  - Core: APIClient, APIEndpoints, KeychainManager (ported from MealMate patterns)
  - Utilities: Theme (aviation dark mode palette), Constants, Extensions
  - XcodeGen project.yml configured with Firebase 12.9.0 + GoogleSignIn 7.1.0
- Created full backend microservices structure with 38 files
  - Docker Compose: Nginx gateway, PostgreSQL 15, Redis 7, user-service, flight-service
  - Database: 3 migration files (users, airports/airlines with seed data, flights)
  - User service: Express + JWT auth, bcrypt password hashing, profile CRUD
  - Flight service: Flight CRUD, PNR lookup (Amadeus), live status (AviationStack), analytics queries
  - Shared database connection pool with transaction support

### Architecture decisions
- **No Firestore**: Unlike AutoLedger, JetStream uses PostgreSQL backend for profiles (not Firebase Firestore)
- **No phone auth**: Simplified to Email, Google, Apple sign-in only
- **Aviation theme**: Dark navy (#0A0E1A) background, sky blue (#0A84FF) primary, amber (#FFD60A) accent
- **Route ordering**: Flight routes put `/airports/search` and `/airlines/search` before `/:id` to prevent Express param conflicts

### Pending / Next Steps
- ~~PNR lookup integration~~ → Replaced with Flight Search (see Session 2)
- All other items completed in Session 2

## Session 2: Phase 2 — Make Everything Functional (2026-02-15)

### What was done

**Backend fixes:**
1. **Fixed DB init in Docker** — Mounted all migration SQL files into `docker-entrypoint-initdb.d/` with numeric prefixes so tables are created automatically on startup
2. **Fixed Docker build context** — Widened build context to backend root, updated both Dockerfiles to preserve directory structure for shared module imports, adjusted tsconfig rootDir to `"../.."`
3. **Fixed API routing** — Added top-level route registrations for `/api/v1/airports/search` and `/api/v1/airlines/search` in flight-service
4. **Implemented social auth** — Added Firebase Admin SDK to user-service, implemented `verifyFirebaseToken()`, replaced 501 placeholder in `socialAuth()` with full token verification + account creation/linking
5. **Pivoted PNR → Flight Search** — Amadeus Self-Service doesn't support PNR retrieval. Replaced with flight number search using AviationStack (`POST /search-by-number`)

**iOS wiring:**
6. **Wired auth to backend** — After Firebase sign-in, exchanges Firebase ID token for backend JWT pair via `/auth/social`, stores in Keychain. Auto token refresh on 401 in APIClient.
7. **Wired flight features** — All views now use backend API instead of local SwiftData. FlightResponse model with computed display properties. Full CRUD: list, create, delete, detail with live status.
8. **Wired dashboard & analytics** — DashboardView shows summary stats + upcoming flights from API. AnalyticsView shows airline bar chart (Swift Charts), top airports, records.
9. **Polish** — ProfileView wired to backend profile endpoint. Loading/error/empty states across all views. Pull-to-refresh everywhere.
10. **Build verified** — `xcodegen generate` + `xcodebuild build` → BUILD SUCCEEDED

### Key architectural changes
- **No more SwiftData @Query in views** — All data fetched from backend API via `FlightService`
- **PNR Lookup removed** — Replaced by `FlightSearchView` (search by flight number + optional date)
- **JWT auth flow**: Firebase Auth → get ID token → POST /auth/social → receive backend JWT pair → stored in Keychain → auto-refresh on 401
- **Firebase Admin SDK** on backend uses project ID only (no service account file needed for token verification)

### Files created
- `ios/JetStream/Views/Flights/FlightSearchView.swift` (replaced PNRLookupView)
- `backend/services/user-service/src/utils/firebase.ts`

### Files deleted
- `ios/JetStream/Views/Flights/PNRLookupView.swift`

### User actions required
1. Create Firebase project → enable Email/Password + Google + Apple sign-in → download `GoogleService-Info.plist` → place in `ios/JetStream/`
2. Get AviationStack API key (free at aviationstack.com)
3. Copy `backend/.env.example` → `backend/.env`, fill in `FIREBASE_PROJECT_ID` and `AVIATIONSTACK_API_KEY`
4. `cd backend && docker-compose up --build`
5. Build and run from Xcode
