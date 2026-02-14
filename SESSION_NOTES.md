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
- Add GoogleService-Info.plist from Firebase Console
- Register Amadeus & AviationStack API keys
- Firebase project setup
- Full auth flow testing
- PNR lookup integration
- Analytics charts with Swift Charts
- UI polish and loading states
